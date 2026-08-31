export TARGET = iphone:clang:15.6:15.6
export ARCHS = arm64 arm64e
export SDKVERSION = 15.6

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AuraFlow
AuraFlow_FILES = Tweak.xm
AuraFlow_CFLAGS = -fobjc-arc
AuraFlow_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
