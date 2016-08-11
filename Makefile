TARGET = sango

all:
	@echo "Targets:"
	@echo "	distro"
	@echo " run"
	@echo " clean"

clean:
	@xcodebuild clean &>/dev/null
	@rm -rdf build
	@rm -f $(TARGET)
	@rm -f output.swift
	@rm -f output.java

distro: clean
	@xcodebuild
	@cp ./build/Release/Sango $(TARGET)
	@echo done!

run: distro
	@rm -f output.swift
	@rm -f output.java
	@./$(TARGET) -f example.json -swift -o output.swift
	@./$(TARGET) -f example.json -java -o output.java

