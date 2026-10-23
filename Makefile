# Rootless Dopamine/ElleKit experimental Music.app-only tweak.
TARGET = iphone:clang:latest:17.0
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless

INSTALL_TARGET_PROCESSES = Music

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MusicCapture17
MusicCapture17_FILES = Tweak.xm
MusicCapture17_CFLAGS = -fobjc-arc
MusicCapture17_FRAMEWORKS = Foundation UIKit AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
