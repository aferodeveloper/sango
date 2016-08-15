TARGET = sango

all:
	@echo "Targets:"
	@echo "   distro"
	@echo "   run"
	@echo "   clean"

clean:
	@xcodebuild clean &>/dev/null
	@rm -rdf build
	@rm -rdf temp_ios
	@rm -rdf temp_android
	@rm -f $(TARGET)
	@rm -f Constants.swift
	@rm -f Constants.java

distro: clean
	@xcodebuild
	@cp ./build/Release/Sango $(TARGET)
	@echo done!

run: distro
	@rm -rdf temp_ios
	@rm -rdf temp_android
	@./$(TARGET) -i example.json -swift -o temp_ios/Constants.swift -a assets -ao temp_ios
	@./$(TARGET) -i example.json -java -o temp_android/Constants.java -a assets -ao temp_android

