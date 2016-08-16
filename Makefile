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
	@./$(TARGET) -i example.json -swift -o temp_ios/Constants.swift -a assets -ao temp_ios/Resources
	@./$(TARGET) -i example.json -java -o temp_android/Constants.java -a assets -ao temp_android

