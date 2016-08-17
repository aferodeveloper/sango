TARGET = sango

DATE := $(shell date "+%Y%m%d_%H%M%S")
DEST_PATH := $(shell pwd)

REVISION :=$(shell git log --pretty=format:'' | wc -l | sed 's/\ //g')

REVERT := git checkout
GIT_SHA1 := $(shell git log -1 --pretty=format:'%h')

all:
	@echo "Targets:"
	@echo "   distro"
	@echo "   install"
	@echo "   run"
	@echo "   clean"

_clean_temps:
	@rm -rdf temp
	@rm -rdf temp_ios
	@rm -rdf temp_android
	
clean: _clean_temps
	@xcodebuild clean &>/dev/null
	@rm -rdf build
	@rm -f $(TARGET)

distro: clean
	@xcodebuild
	@cp ./build/Release/Sango $(TARGET)
	@echo done!

install: distro
	@sudo cp $(TARGET) /usr/local/bin/$(TARGET)

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

