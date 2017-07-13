TARGET = sango

DATE := $(shell date "+%Y%m%d_%H%M%S")
BUILD_DATE := $(shell date)

DEST_PATH := $(shell pwd)

REVISION :=$(shell git log --pretty=format:'' | wc -l | sed 's/\ //g')

REVERT := git checkout
GIT_SHA1 := $(shell git log -1 --pretty=format:'%h')

all:
	@echo "Targets:"
	@echo "   distro"
	@echo "   install"
	@echo "   version"
	@echo "   run"
	@echo "   clean"

version:
	@echo "Current build version: $(REVISION) sha1 $(GIT_SHA1)"

_clean_temps:
	@rm -rdf temp
	@rm -rdf temp_ios
	@rm -rdf temp_android
	
clean: _clean_temps clear_build
	@xcodebuild clean &>/dev/null
	@rm -rdf build
	@rm -f $(TARGET)

distro: clean set_build
	@xcodebuild -project Sango.xcodeproj
	@cp ./build/Release/Sango $(TARGET)
	@$(MAKE) clear_build
	@echo "Done!"

set_build:
	@echo "public let BUILD_DATE = "\"$(BUILD_DATE)\" > Source/Version.swift
	@echo "public let BUILD_REVISION = $(REVISION)" >> Source/Version.swift

clear_build:
	@$(REVERT) Source/Version.swift

install: distro
	@if [ -w /usr/local/bin ]; then \
	cp $(TARGET) /usr/local/bin/$(TARGET); \
	else \
	echo "/usr/local/bin not writable; need permission to install."; \
	sudo cp $(TARGET) /usr/local/bin/$(TARGET); \
	fi


test1: _clean_temps
	@./$(TARGET) -config brand1_config.json -verbose

test2: _clean_temps
	@./$(TARGET) -config brand2_config.json -verbose

test3: _clean_temps
	@./$(TARGET) -config brand1_android.json -verbose

run: distro
	@./$(TARGET) -input example/source.json \
				-swift \
				-out_source temp_ios/Constants.swift \
				-input_assets example/assets \
				-out_assets temp_ios/Resources
	@./$(TARGET) -input example/source.json \
				-java \
				-out_source temp_android/Constants.java \
				-input_assets example/assets \
				-out_assets temp_android

