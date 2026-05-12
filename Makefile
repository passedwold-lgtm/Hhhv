ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless
THEOS_LEAN_AND_MEAN = 1
THEOS_NO_DEFAULTS = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Hoangxuantu

# Cấu hình Flag biên dịch
$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -fvisibility=hidden
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -fvisibility=hidden

# Tắt cảnh báo nếu cần
ifeq ($(IGNORE_WARNINGS),1)
  $(TWEAK_NAME)_CFLAGS += -w
  $(TWEAK_NAME)_CCFLAGS += -w
endif

# Danh sách Frameworks
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

# Quét tệp tin nguồn
ESP_M_FILES := $(filter-out Esp/ImGuiLoad.m,$(wildcard Esp/*.m))
$(TWEAK_NAME)_FILES = ImGuiDrawView.mm $(wildcard Esp/*.mm) $(ESP_M_FILES) $(wildcard IMGUI/*.cpp) $(wildcard IMGUI/*.mm) $(wildcard Hosts/*.m)

# Thêm đường dẫn thư viện để tránh lỗi ld: library not found
$(TWEAK_NAME)_LDFLAGS += -L$(THEOS)/lib
# Chỉ định đường dẫn chứa file libzexis.a và libdobby_fixed.a
$(TWEAK_NAME)_LDFLAGS += -L./Zexishook
$(TWEAK_NAME)_LDFLAGS += -L./Other

# Chỉ định tên thư viện cần link (bỏ tiền tố 'lib' và hậu tố '.a')
$(TWEAK_NAME)_LDFLAGS += -lzexis
$(TWEAK_NAME)_LDFLAGS += -ldobby_fixed

include $(THEOS_MAKE_PATH)/tweak.mk
