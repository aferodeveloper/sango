TARGET = sango

all:
	@echo "Targets:"
	@echo "   distro"
	@echo "   run"
	@echo "   clean"

clean:
	@xcodebuild clean &>/dev/null
	@rm -rdf build
	@rm -f $(TARGET)
	@rm -f Constants.swift
	@rm -f Constants.java

distro: clean
	@xcodebuild
	@cp ./build/Release/Sango $(TARGET)
	@echo done!

run: distro
	@rm -f Constants.swift
	@rm -f Constants.java
	@./$(TARGET) -i example.json -swift -o Constants.swift
	@./$(TARGET) -i example.json -java -o Constants.java

