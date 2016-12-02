SANGO = sango

all:
	@echo "Example to build sango data for iOS and Android"
	@echo " build_android"
	@echo " build_ios"
	@echo " build_both"
	@echo " validate"

clean:
	@rm -rdf temp_android
	@rm -rdf temp_ios

build_android:
	@rm -rdf temp_android
	sango -config config_android.json -verbose
	
build_ios:
	@rm -rdf temp_ios
	sango -config config_ios.json -verbose

build_both: clean
	set -e
	$(SANGO) -config config_android.json -verbose
	$(SANGO) -config config_ios.json -verbose

validate:
	$(SANGO) -verbose -input_assets simple -validate simple/*.json
	