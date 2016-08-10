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

distro: clean
	@xcodebuild
	@cp ./build/Release/Sango $(TARGET)
	@echo done!

run: distro
	@./$(TARGET) -f example.json
