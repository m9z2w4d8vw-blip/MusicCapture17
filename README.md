# MusicCapture17 (experimental source)

An **untested**, conservative Theos/Logos rootless iOS 17 tweak proof of concept for a jailbreak-installed iPhone, particularly iPhone 13 on iOS 17.0. It aims to stop **AVPlayer** in **Apple Music only** from muting itself when a screen recording is active. It also requests that previously seen AVPlayer instances be unmuted after the screen-capture status changes.

**Important limitations:** The tweak does NOT capture or decrypt DRM-protected audio, modify FairPlay, patch `replayd`, or guarantee that protected audio reaches the screen recording. If iOS/ReplayKit discards the protected stream later in its recording pipeline, this tweak cannot solve it. Merely obtaining a `.deb` does not establish that it works on iOS 17.0. A rootless .deb has **not** been compiled or tested in this environment.

## What is included

- `Tweak.xm`: modernized and narrowly scoped AVPlayer playback mute workaround.
- `MusicCapture17.plist`: injection restricted to `com.apple.Music`.
- `Makefile`, `control`: Theos rootless package configuration.
- `.github/workflows/build.yml`: manually triggered build using macOS GitHub Actions. No WSL needed.

## How to build using GitHub Actions (on Windows)

1. Create a new GitHub repository and upload all contents of this **MusicCapture17** directory, **including the hidden `.github` folder**, to the repository root. Keep `.github/workflows/build.yml` at its specified path.
2. In GitHub, choose **Actions → Build rootless tweak → Run workflow**.
3. When the run succeeds, download the **MusicCapture17-rootless-deb** artifact. Unzip that artifact to obtain `packages/*.deb`.
4. Transfer the `.deb` to your iPhone; on a compatible rootless Dopamine/ElleKit jailbreak, open it in Sileo/Zebra or install with `dpkg -i <filename>.deb` using a device terminal. Close/reopen Apple Music after installation.
5. Record a short clip of an Apple Music track using Control Center's built-in Screen Recording, then check whether the *saved recording* has sound. Compare against a baseline without the tweak.
6. If playback fails or behavior changes unexpectedly, uninstall **MusicCapture17 (Experimental)** using Sileo/Zebra and restart the Music app. The tweak doesn't patch on-disk iOS system files.

Local build with Theos on macOS/Linux/WSL: `make clean package FINALPACKAGE=1`. Reference: https://theos.dev/docs/rootless and https://theos.dev/docs/installation-linux.

## What a failed test tells us

If Music still plays on the phone but the saved video has no music audio, the block is most likely after the `AVPlayer` mute path (possibly in the recording daemon / protected audio path), or the Music app uses a different playback class. The next step would be read-only logging / runtime class inspection on that exact build before changing any system daemon hook. Do **not** blindly inject historic iOS 12–14 `replayd` hooks into iOS 17; they could crash the recording daemon.

If recorded video audio is muted but app sounds are fine, check microphone state and test with an unprotected local audio file to distinguish app/route bugs from DRM-specific exclusion.

## Related historical projects

- https://github.com/JoniVR/MusicScreenRecorder (2019; hooks `AVPlayer` mute state)
- https://github.com/ichitaso/ScreenRecordingMusic (2022; used ReplayKit and `AVPlayer`, documented iOS 12–14)

These are inspiration only, NOT evidence that this particular project works on iOS 17.

For authorized personal experiments; respect applicable rights and licensing.
