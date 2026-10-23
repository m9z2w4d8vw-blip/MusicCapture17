// MusicCapture17: experimental, Apple Music-only ReplayKit audio-mute workaround.
// Designed as a rootless Theos tweak for iOS 17. Not tested on a real device.
// Does not decrypt music or intercept protected PCM/audio samples.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static NSHashTable<AVPlayer *> *MC17Players(void) {
    static NSHashTable<AVPlayer *> *players = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        players = [NSHashTable weakObjectsHashTable];
    });
    return players;
}

static BOOL MC17IsCapturing(void) {
    UIScreen *screen = [UIScreen mainScreen];
    return screen != nil && screen.isCaptured;
}

static void MC17TrackPlayer(AVPlayer *player) {
    if (!player) return;
    NSHashTable<AVPlayer *> *players = MC17Players();
    @synchronized (players) {
        [players addObject:player];
    }
}

static void MC17UnmuteExistingPlayers(void) {
    if (!MC17IsCapturing()) return;
    NSHashTable<AVPlayer *> *players = MC17Players();
    NSArray<AVPlayer *> *snapshot;
    @synchronized (players) {
        snapshot = [players allObjects];
    }
    for (AVPlayer *player in snapshot) {
        // Dispatches through our hook, then calls the real setter with NO.
        [player setMuted:NO];
    }
    NSLog(@"[MusicCapture17] Capture started; requested unmute for %lu known AVPlayer(s)",
          (unsigned long)snapshot.count);
}

%hook AVPlayer

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item {
    AVPlayer *player = %orig(item);
    MC17TrackPlayer(player);
    return player;
}

- (instancetype)initWithURL:(NSURL *)URL {
    AVPlayer *player = %orig(URL);
    MC17TrackPlayer(player);
    return player;
}

- (BOOL)isMuted {
    if (MC17IsCapturing()) return NO;
    return %orig;
}

- (void)setMuted:(BOOL)muted {
    MC17TrackPlayer(self);
    if (muted && MC17IsCapturing()) {
        NSLog(@"[MusicCapture17] Suppressed AVPlayer mute during capture");
        %orig(NO);
    } else {
        %orig(muted);
    }
}

%end

%ctor {
    @autoreleasepool {
        // No SpringBoard or replayd injection. Only com.apple.Music is targeted.
        [[NSNotificationCenter defaultCenter]
            addObserverForName:UIScreenCapturedDidChangeNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(__unused NSNotification *note) {
                        MC17UnmuteExistingPlayers();
                    }];
        NSLog(@"[MusicCapture17] Loaded in %@", [[NSBundle mainBundle] bundleIdentifier]);
    }
}
