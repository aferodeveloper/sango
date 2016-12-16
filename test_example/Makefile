SANGO = sango
RESULTS_IOS = results_ios
RESULTS_ANDROID = results_android

all:
	@echo "Example to build sango data for iOS and Android, used for testing."
	@echo " build_android"
	@echo " build_ios"
	@echo " build_both"
	@echo " validate"

clean:
	@rm -rdf $(RESULTS_ANDROID)
	@rm -rdf $(RESULTS_IOS)

build_android:
	@rm -rdf $(RESULTS_ANDROID)
	$(SANGO) -config config_android.json -verbose
	
build_ios:
	@rm -rdf $(RESULTS_IOS)
	$(SANGO) -config config_ios.json -verbose

build_both:
	set -e
	@$(MAKE) build_android
	@$(MAKE) build_ios

validate:
	$(SANGO) -verbose -input_assets simple -validate simple/*.json
	