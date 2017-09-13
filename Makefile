#
# Copyright 2016 Afero, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
