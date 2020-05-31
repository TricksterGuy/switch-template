#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------

ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>/devkitpro")
endif

TOPDIR ?= $(CURDIR)
include $(DEVKITPRO)/libnx/switch_rules

#---------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# DATA is a list of directories containing data files
# INCLUDES is a list of directories containing header files
# ROMFS is the directory containing data to be added to RomFS, relative to the Makefile (Optional)
# RESOURCES is the directory where App config files (icon json etc) are located
# OUTPUT is the directory where final executables will be placed
# SWITCH_IP is the ip address/hostname of your switch for nxlink target
#
# NO_ICON: if set to anything, do not use icon.
# NO_NACP: if set to anything, no .nacp file is generated.
# APP_TITLE is the name of the app stored in the .nacp file. 511 characters max. (Optional)
# APP_AUTHOR is the author of the app stored in the .nacp file. 255 characters max. (Optional)
# APP_VERSION is the version of the app stored in the .nacp file. It should be at most 15 characters. (Optional)
# APP_TITLEID is the titleID of the app stored in the .nacp file. It should be at most 16 hex characters. (Optional)
# ICON is the filename of the icon (.jpg), relative to the project folder.
#   If not set, it attempts to use one of the following (in this order):
#     - resources/icon.jpg
#     - <libnx folder>/default_icon.jpg
#
# CONFIG_JSON is the filename of the NPDM config file (.json), relative to the project folder.
#   If not set, it attempts to use one of the following (in this order):
#     - resources/config.json
#   If a JSON file is provided or autodetected, an ExeFS PFS0 (.nsp) is built instead
#   of a homebrew executable (.nro). This is intended to be used for sysmodules.
#   NACP building is skipped as well.
#---------------------------------------------------------------------------------
TARGET		:=	$(notdir $(CURDIR))
BUILD		:=	build
SOURCES		:=	source
DATA		:=	data
INCLUDES	:=	include
RESOURCES	:=	resources
OUTPUT		:=	output

SWITCH_IP	:= ""
APP_TITLE	:= "switch-template"
APP_AUTHOR	:= "no-name"
APP_VERSION	:= "0.1"
# APP_TITLEID := "title"

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
ARCH     := -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE
CFLAGS   :=	-Wall -O2 -ffunction-sections $(ARCH) $(DEFINES)
CFLAGS   +=	$(INCLUDE) -D__SWITCH__
CXXFLAGS := $(CFLAGS) -fno-rtti -fno-exceptions
ASFLAGS  := $(ARCH)
LDFLAGS  = -specs=$(DEVKITPRO)/libnx/switch.specs $(ARCH) -Wl,-Map,$(notdir $*.map)
LIBS     := -lnx

#---------------------------------------------------------------------------------
# list of directories containing libraries, this must be the top level containing
# include and lib
#---------------------------------------------------------------------------------
LIBDIRS	:= $(PORTLIBS) $(LIBNX)

#---------------------------------------------------------------------------------
# no real need to edit anything past this point unless you need to add additional
# rules for different file extensions
#---------------------------------------------------------------------------------
ifneq ($(BUILD),$(notdir $(CURDIR)))
#---------------------------------------------------------------------------------

export TOPDIR	:=	$(CURDIR)
export OUTPUT_DIR  := $(TOPDIR)/$(OUTPUT)
export OUTPUT_FILE := $(OUTPUT_DIR)/$(TARGET)

export VPATH	:=	$(foreach dir,$(SOURCES),$(CURDIR)/$(dir)) \
					$(foreach dir,$(DATA),$(CURDIR)/$(dir))

export DEPSDIR	:=	$(CURDIR)/$(BUILD)

CFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
SFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
BINFILES	:=	$(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))

#---------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#---------------------------------------------------------------------------------
ifeq ($(strip $(CPPFILES)),)
#---------------------------------------------------------------------------------
	export LD	:=	$(CC)
#---------------------------------------------------------------------------------
else
#---------------------------------------------------------------------------------
	export LD	:=	$(CXX)
#---------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------

export OFILES_BIN	:=	$(addsuffix .o,$(BINFILES))
export OFILES_SRC	:=	$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)
export OFILES 		:=	$(OFILES_BIN) $(OFILES_SRC)
export HFILES_BIN	:=	$(addsuffix .h,$(subst .,_,$(BINFILES)))

export INCLUDE		:=	$(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
						$(foreach dir,$(LIBDIRS),-I$(dir)/include) \
						-I$(CURDIR)/$(BUILD)

export LIBPATHS		:=	$(foreach dir,$(LIBDIRS),-L$(dir)/lib)

ifeq ($(strip $(CONFIG_JSON)),)
	jsons := $(wildcard $(RESOURCES)/*.json)
	ifneq (,$(findstring config.json,$(jsons)))
		export APP_JSON := $(TOPDIR)/$(RESOURCES)/config.json
	endif
else
	export APP_JSON := $(TOPDIR)/$(CONFIG_JSON)
endif

ifeq ($(strip $(ICON)),)
	icons := $(wildcard $(RESOURCES)/*.jpg)
	ifneq (,$(findstring $(RESOURCES)/icon.jpg,$(icons)))
		export APP_ICON := $(TOPDIR)/$(RESOURCES)/icon.jpg
	endif
else
	export APP_ICON := $(TOPDIR)/$(ICON)
endif

ifeq ($(strip $(NO_ICON)),)
	export NROFLAGS += --icon=$(APP_ICON)
endif

ifeq ($(strip $(NO_NACP)),)
	export NROFLAGS += --nacp=$(OUTPUT_FILE).nacp
endif

ifneq ($(APP_TITLEID),)
	export NACPFLAGS += --titleid=$(APP_TITLEID)
endif

ifneq ($(ROMFS),)
	export NROFLAGS += --romfsdir=$(CURDIR)/$(ROMFS)
endif

.PHONY: $(BUILD) $(OUTPUT_DIR) clean all bootstrap elf nro nso nsp

#---------------------------------------------------------------------------------

all: bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

elf : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

nro : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

nso : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

nsp : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

nxlink : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

yuzu : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

bootstrap : $(BUILD) $(OUTPUT_DIR)
	@[ -d $(BUILD) ] || mkdir -p $(BUILD)
	@[ -d $(OUTPUT_DIR) ] || mkdir -p $(OUTPUT_DIR)

clean:
	@echo clean ...
	@rm -rf $(BUILD) $(OUTPUT_DIR)

#---------------------------------------------------------------------------------
else
.PHONY:	all nro nsp nso nxlink

DEPENDS	:=	$(OFILES:.o=.d)

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
ifeq ($(strip $(APP_JSON)),)

ifeq ($(OS),Windows_NT)
	NXLINK = nxlink.exe
	YUZU = yuzu-cmd.exe
else
	NXLINK = nxlink
	YUZU = yuzu-cmd
endif


all	:	$(OUTPUT_FILE).nro

ifeq ($(strip $(NO_NACP)),)
$(OUTPUT_FILE).nro	:	$(OUTPUT_FILE).elf $(OUTPUT_FILE).nacp
else
$(OUTPUT_FILE).nro	:	$(OUTPUT_FILE).elf
endif

nro : $(OUTPUT_FILE).nro
nsp :
	@echo "$(RESOURCES)/config.json missing so not building an nsp file."
nso :
	@echo "$(RESOURCES)/config.json missing so not building an nso file."

nxlink : nro
	@$(NXLINK) -a $(SWITCH_IP) $(OUTPUT_FILE).nro

yuzu : nro
	@$(YUZU) $(OUTPUT_FILE).nro

else

all	:	$(OUTPUT_FILE).nsp

$(OUTPUT_FILE).nsp	:	$(OUTPUT_FILE).nso $(OUTPUT_FILE).npdm

$(OUTPUT_FILE).nso	:	$(OUTPUT_FILE).elf

nro :
	@echo "$(RESOURCES)/config.json is present so not building an nro file."
nxlink :
	@echo "$(RESOURCES)/config.json is present so not running nxlink."
nsp : $(OUTPUT_FILE).nsp
nso : $(OUTPUT_FILE).nso

yuzu : nso
	@$(YUZU) $(OUTPUT_FILE).nso

endif

$(OUTPUT_FILE).elf	:	$(OFILES)

$(OFILES_SRC)	: $(HFILES_BIN)

elf : $(OUTPUT_FILE).elf



#---------------------------------------------------------------------------------
# you need a rule like this for each extension you use as binary data
#---------------------------------------------------------------------------------
%.bin.o	%_bin.h :	%.bin
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(bin2o)

-include $(DEPENDS)

#---------------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------------
