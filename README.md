# sango
Tool for processing common app constants and assets for iOS and Android. Takes a source JSON and copies files, and outputs a Swift and Java file for use.

![Sango Pipeline](images/sango_pipeline.png)

We have a need to share constants, and assets between iOS, Android and web projects. One solution that has worked well has a 3rd git depot that contains shared assets, and a source JSON file that is parsed by a tool for each platform.

Sango standardizes localization by using the iOS key/value format, and when writing out, transforms the source into XML for Android, and copies for iOS. For web a JSON format.

```json

Basic data spec:
{
	"schemaVersion": 1,
	"java": {
		"package": "io.afero.example",
		"launcher_icon_name": "android_launcher_icon",
		"base": "Constants"
	},
	"swift": {
		"base": "Constants"
	},
	"javascript": {
		"base": "Constants"
	},
	"locale": {
		"default": "assets/locale/en.strings",
		"de": "assets/locale/de.strings",
		"it": "assets/locale/it.strings",
		"jp": "assets/locale/jp.strings"
	},
	"fonts": [
		"assets/GT-Walsheim-Black-Oblique.ttf",
		"assets/GT-Walsheim-Black.ttf"
	],
	"appIconAndroid": "assets/app_icons/android/release_app_icon.png",
	"appIconIos": "assets/app_icons/ios/release_app_icon.png",
	"imagesIos": [
		"assets/account_avatar2.png"
	],
	"layoutAndroid": [
		"assets/android/activity_object_detail.xml"
	],
	"imagesAndroid": [
		"assets/account_avatar1.png"
	],
	"images": [
		"assets/asr_1.png"
	],
	"copied": [
		"assets/file_data1",
		"assets/file_data2"
	],
	"imagesScaled": [
		"assets/vector_avatar.pdf",
		"assets/business_men.ai",
		"assets/green_guy.eps"
	],
	"Settings": {
		"UI_BASE_COLOR": "67,163,199,255",
		"UI_BASE_COLOR2": "67,163,199,20",
		"UI_SECONDARY_COLOR": "#431298",
		"UI_SECONDARY_COLOR_LOW": "#80431298",
		"DEFAULT_UI_FONT": "GT-Walsheim-Black.ttf",
		"DEFAULT_AVATAR": "account_avatar1",
		"PREF_ACCOUNT_NAME": "pref_account_display_name",
		"PREF_SERVICE": "pref_service_name",
		"DEFAULT_DISPLAY_UI_STYLE": 1,
		"SCALE": 1.5,
		"DEBUG_ENABLED": true,
		"SHOW_UI": false
	},
	"Empty": [
		""
	],
	"Hello": [
		"one",
		"two",
		"three"
	],
	"FloatyNumbers": [
		1,
		2,
		3.15,
		23,
		415.03
	],
	"InteryNumbers": [
		5,
		23,
		54,
		120,
		100
	],
	"RainbowColors": [
		"#535557",
		"#9D9C98",
		"#F2845B",
		"#F67D4B",
		"#EDAC93"
	],
	"Service": {
		"LOGIN_TYPE": "OAUTH2",
		"BROWSE_TYPE": "CARDS",
		"MENU_VIEW": "SETTINGS",
		"BASE_URL_PROD_USW2": "api.afero.io",
		"BASE_URL_STAGE": "api.dev.afero.io"
	},
	"Colors": {
		"GRAY01_50": "#F2EDEB",
		"GRAY02_50": "#D0CBC7",
		"GRAY03_50": "#A4A099",
		"GRAY04_50": "#7E7B77",
		"ORANGE01_50": "#F67D4B",
		"WHITE01_50": "#FFFFFF",
		"GRAY01": "#E1DFDC",
		"GRAY02": "#BFBCB7",
		"GRAY03": "#9D9C98",
		"GRAY04": "#85878A",
		"GRAY05": "#717375",
		"GRAY06": "#616264",
		"GRAY07": "#535557",
		"ORANGE06": "#F67D4B",
		"ORANGE05": "#F47344",
		"ORANGE04": "#F2845B",
		"ORANGE03": "#EF9471",
		"ORANGE02": "#EBA485",
		"ORANGE01": "#EDAC93",
		"WHITE01": "#FFFFFF"
	},
	"TemperatureUnits": [
		"FAHRENHEIT",
		"CELSIUS",
		"KELVIN"
	],
	"enums": {
		"TEMPERATURE_UNIT": [
			"CELSIUS",
			"FAHRENHEIT",
			"KELVIN"
		],
		"AUTH_TYPE": [
			"AFERO",
			"OAUTH2"
		],
		"MENU_VIEW_TYPE": [
			"CLASSIC",
			"SETTINGS"
		],
		"DEVICE_BROWSER_TYPE": [
			"HEX",
			"CARDS"
		],
		"DAY": [
			"MONDAY",
			"TUESDAY",
			"WEDNESDAY",
			"THURSDAY",
			"FRIDAY",
			"SATURDAY",
			"SUNDAY"
		],
		"TIME_OF_DAY": [
			"BREAKFAST",
			"LUNCH",
			"SNACK",
			"DINNER"
		],
		"SAFE_IMAGES": [
			"asr_1",
			"ac_icon_large"
		]
	}
}
```

Output:
Constants.swift

```swift

/* Generated with Sango, by Afero.io */

import UIKit
public struct Constants {
	public struct Colors {
		static let Gray01 = UIColor(red: 0.882, green: 0.875, blue: 0.863, alpha: 1.0) /* #E1DFDC */
		static let Gray01_50 = UIColor(red: 0.949, green: 0.929, blue: 0.922, alpha: 1.0) /* #F2EDEB */
		static let Gray02 = UIColor(red: 0.749, green: 0.737, blue: 0.718, alpha: 1.0) /* #BFBCB7 */
		static let Gray02_50 = UIColor(red: 0.816, green: 0.796, blue: 0.78, alpha: 1.0) /* #D0CBC7 */
		static let Gray03 = UIColor(red: 0.616, green: 0.612, blue: 0.596, alpha: 1.0) /* #9D9C98 */
		static let Gray03_50 = UIColor(red: 0.643, green: 0.627, blue: 0.6, alpha: 1.0) /* #A4A099 */
		static let Gray04 = UIColor(red: 0.522, green: 0.529, blue: 0.541, alpha: 1.0) /* #85878A */
		static let Gray04_50 = UIColor(red: 0.494, green: 0.482, blue: 0.467, alpha: 1.0) /* #7E7B77 */
		static let Gray05 = UIColor(red: 0.443, green: 0.451, blue: 0.459, alpha: 1.0) /* #717375 */
		static let Gray06 = UIColor(red: 0.38, green: 0.384, blue: 0.392, alpha: 1.0) /* #616264 */
		static let Gray07 = UIColor(red: 0.325, green: 0.333, blue: 0.341, alpha: 1.0) /* #535557 */
		static let Orange01 = UIColor(red: 0.929, green: 0.675, blue: 0.576, alpha: 1.0) /* #EDAC93 */
		static let Orange01_50 = UIColor(red: 0.965, green: 0.49, blue: 0.294, alpha: 1.0) /* #F67D4B */
		static let Orange02 = UIColor(red: 0.922, green: 0.643, blue: 0.522, alpha: 1.0) /* #EBA485 */
		static let Orange03 = UIColor(red: 0.937, green: 0.58, blue: 0.443, alpha: 1.0) /* #EF9471 */
		static let Orange04 = UIColor(red: 0.949, green: 0.518, blue: 0.357, alpha: 1.0) /* #F2845B */
		static let Orange05 = UIColor(red: 0.957, green: 0.451, blue: 0.267, alpha: 1.0) /* #F47344 */
		static let Orange06 = UIColor(red: 0.965, green: 0.49, blue: 0.294, alpha: 1.0) /* #F67D4B */
		static let White01 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) /* #FFFFFF */
		static let White01_50 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) /* #FFFFFF */
	}
	public static let Empty = [
			""
		]
	public static let FloatyNumbers = [
			1,
			2,
			3.15,
			23,
			415.03
		]
	public static let Hello = [
			"one",
			"two",
			"three"
		]
	public static let InteryNumbers = [
			5,
			23,
			54,
			120,
			100
		]
	public static let RainbowColors = [
			UIColor(red: 0.325, green: 0.333, blue: 0.341, alpha: 1.0) /* #535557 */,
			UIColor(red: 0.616, green: 0.612, blue: 0.596, alpha: 1.0) /* #9D9C98 */,
			UIColor(red: 0.949, green: 0.518, blue: 0.357, alpha: 1.0) /* #F2845B */,
			UIColor(red: 0.965, green: 0.49, blue: 0.294, alpha: 1.0) /* #F67D4B */,
			UIColor(red: 0.929, green: 0.675, blue: 0.576, alpha: 1.0) /* #EDAC93 */
		]
	public struct Service {
		static let BaseUrlProdUsw2 = "api.afero.io"
		static let BaseUrlStage = "api.dev.afero.io"
		static let BrowseType = DeviceBrowserType.Cards
		static let LoginType = AuthType.Oauth2
		static let MenuView = MenuViewType.Settings
	}
	public struct Settings {
		static let DebugEnabled = true
		static let DefaultAvatar = "account_avatar1"
		static let DefaultDisplayUiStyle = 1
		static let DefaultUiFont = "GT-Walsheim-Black.ttf"
		static let PrefAccountName = "pref_account_display_name"
		static let PrefService = "pref_service_name"
		static let Scale = 1.5
		static let ShowUi = false
		static let UiBaseColor = UIColor(red: 0.263, green: 0.639, blue: 0.78, alpha: 1.0) /* 67,163,199,255 */
		static let UiBaseColor2 = UIColor(red: 0.263, green: 0.639, blue: 0.78, alpha: 0.078) /* 67,163,199,20 */
		static let UiSecondaryColor = UIColor(red: 0.263, green: 0.071, blue: 0.596, alpha: 1.0) /* #431298 */
		static let UiSecondaryColorLow = UIColor(red: 0.263, green: 0.071, blue: 0.596, alpha: 0.502) /* #80431298 */
	}
	public static let TemperatureUnits = [
			TemperatureUnit.Fahrenheit,
			TemperatureUnit.Celsius,
			TemperatureUnit.Kelvin
		]
	public enum AuthType {
		case Afero
		case Oauth2
	}
	public enum Day {
		case Monday
		case Tuesday
		case Wednesday
		case Thursday
		case Friday
		case Saturday
		case Sunday
	}
	public enum DeviceBrowserType {
		case Hex
		case Cards
	}
	public enum MenuViewType {
		case Classic
		case Settings
	}
	public enum SafeImages {
		case Asr_1
		case AcIconLarge
	}
	public enum TemperatureUnit {
		case Celsius
		case Fahrenheit
		case Kelvin
	}
	public enum TimeOfDay {
		case Breakfast
		case Lunch
		case Snack
		case Dinner
	}
}
```

Output
R.swift

```swift

/* Generated with Sango, by Afero.io */

import Foundation
public struct R {
	public struct String {
		static let AppName = "app_name"
		static let ButtonTitleCancel = "button_title_cancel"
		static let ButtonTitleCancelAllCaps = "button_title_cancel_all_caps"
		static let ButtonTitleOk = "button_title_ok"
		static let DeviceOffline = "device_offline"
		static let DialogMessageRemoveDevice = "dialog_message_remove_device"
		static let DialogTitleRemoveDevice = "dialog_title_remove_device"
		static let DialogTitleScheduleTime = "dialog_title_schedule_time"
		static let NoNetworkWarning = "no_network_warning"
		static let PrimaryAccountName = "primary_account_name"
	}
	public struct Images {
		static let AccountAvatar2 = "account_avatar2"
		static let Asr1 = "asr_1"
		static let BusinessMen = "business_men"
		static let GreenGuy = "green_guy"
		static let VectorAvatar = "vector_avatar"
	}
}
```

Output
Constants.java

```java

/* Generated with Sango, by Afero.io */

package io.afero.example;
public final class Constants {
	public static final String Empty[] = {

	};
	public static final double FloatyNumbers[] = {
		1,
		2,
		3.15,
		23,
		415.03
	};
	public static final String Hello[] = {
		"one",
		"two",
		"three"
	};
	public static final int InteryNumbers[] = {
		5,
		23,
		54,
		120,
		100
	};
	public static final class Service {
		public static final String BASE_URL_PROD_USW2 = "prod.example.com";
		public static final String BASE_URL_STAGE = "dev.example.com";
		public static final DeviceBrowserType BROWSE_TYPE = DeviceBrowserType.CARDS;
		public static final AuthType LOGIN_TYPE = AuthType.OAUTH2;
		public static final MenuViewType MENU_VIEW = MenuViewType.SETTINGS;
	}
	public static final class Settings {
		public static final Boolean DEBUG_ENABLED = true;
		public static final String DEFAULT_AVATAR = "account_avatar1";
		public static final int DEFAULT_DISPLAY_UI_STYLE = 1;
		public static final String DEFAULT_UI_FONT = "GT-Walsheim-Black.ttf";
		public static final String PREF_ACCOUNT_NAME = "pref_account_display_name";
		public static final String PREF_SERVICE = "pref_service_name";
		public static final double SCALE = 1.5;
		public static final Boolean SHOW_UI = false;
	}
	public static final TemperatureUnit TemperatureUnits[] = {
		TemperatureUnit.FAHRENHEIT,
		TemperatureUnit.CELSIUS,
		TemperatureUnit.KELVIN
	};
	public enum AuthType {
		AFERO, OAUTH2
	}
	public enum Day {
		MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
	}
	public enum DeviceBrowserType {
		HEX, CARDS
	}
	public enum MenuViewType {
		CLASSIC, SETTINGS
	}
	public enum SafeImages {
		ASR_1
	}
	public enum TemperatureUnit {
		CELSIUS, FAHRENHEIT, KELVIN
	}
	public enum TimeOfDay {
		BREAKFAST, LUNCH, SNACK, DINNER
	}
}
```

And for Android a colors.xml file is generated:

```xml

<?xml version="1.0" encoding="utf-8"?>
<!-- Generated with Sango, by Afero.io -->
<resources>
	<color name="colors_gray01">#E1DFDC</color>
	<color name="colors_gray01_50">#F2EDEB</color>
	<color name="colors_gray02">#BFBCB7</color>
	<color name="colors_gray02_50">#D0CBC7</color>
	<color name="colors_gray03">#9D9C98</color>
	<color name="colors_gray03_50">#A4A099</color>
	<color name="colors_gray04">#85878A</color>
	<color name="colors_gray04_50">#7E7B77</color>
	<color name="colors_gray05">#717375</color>
	<color name="colors_gray06">#616264</color>
	<color name="colors_gray07">#535557</color>
	<color name="colors_orange01">#EDAC93</color>
	<color name="colors_orange01_50">#F67D4B</color>
	<color name="colors_orange02">#EBA485</color>
	<color name="colors_orange03">#EF9471</color>
	<color name="colors_orange04">#F2845B</color>
	<color name="colors_orange05">#F47344</color>
	<color name="colors_orange06">#F67D4B</color>
	<color name="colors_white01">#FFFFFF</color>
	<color name="colors_white01_50">#FFFFFF</color>
	<color name="rainbowcolors_0">#535557</color>
	<color name="rainbowcolors_1">#9D9C98</color>
	<color name="rainbowcolors_2">#F2845B</color>
	<color name="rainbowcolors_3">#F67D4B</color>
	<color name="rainbowcolors_4">#EDAC93</color>
	<color name="settings_ui_base_color">#FF43A3C7</color>
	<color name="settings_ui_base_color2">#1443A3C7</color>
	<color name="settings_ui_secondary_color">#431298</color>
	<color name="settings_ui_secondary_color_low">#80431298</color>
</resources>
```

Output for javascript

```javascript

/* Generated with Sango, by Afero.io */

var AuthType = {
	AFERO: 'AFERO', OAUTH2: 'OAUTH2'
}
var Day = {
	MONDAY: 'MONDAY', TUESDAY: 'TUESDAY', WEDNESDAY: 'WEDNESDAY', THURSDAY: 'THURSDAY', FRIDAY: 'FRIDAY', SATURDAY: 'SATURDAY', SUNDAY: 'SUNDAY'
}
var DeviceBrowserType = {
	HEX: 'HEX', CARDS: 'CARDS'
}
var MenuViewType = {
	CLASSIC: 'CLASSIC', SETTINGS: 'SETTINGS'
}
var SafeImages = {
	ASR_1: 'ASR_1'
}
var TemperatureUnit = {
	CELSIUS: 'CELSIUS', FAHRENHEIT: 'FAHRENHEIT', KELVIN: 'KELVIN'
}
var TimeOfDay = {
	BREAKFAST: 'BREAKFAST', LUNCH: 'LUNCH', SNACK: 'SNACK', DINNER: 'DINNER'
}
var Constants = {
	Dimen: {
		 BUTTON_GROUP_SPACING: "10dp",
		 BUTTON_RADIUS: "400dp",
		 OFFLINE_SCHEDULE_DAY_EDITOR_RING_WIDTH: "35dp",
		 OOBE_ARROW_SIZE: "120dp",
		 OOBE_ICON_SIZE: "100dp",
		 OOBE_MADAL_HLINE: "40dp",
		 OOBE_MODAL_VLINE: "80dp",
		 VIEW_ONBOARDING_BOARD: "400dp",
		 VIEW_ONBOARDING_BOARD_MARGIN_TOP: "50dp",
		 VIEW_ONBOARDING_BOARD_WRAPPER: "600dp",
		 VIEW_ONBOARDING_LABEL_MARGIN_SIDE: "20dp",
		 VIEW_ONBOARDING_LABEL_MARGIN_TOP: "75dp",
	},
	Empty: [

	],
	FloatyNumbers: [
		1,
		2,
		3.15,
		23,
		415.03
	],
	Hello: [
		"one",
		"two",
		"three"
	],
	InteryNumbers: [
		5,
		23,
		54,
		120,
		100
	],
	Service: {
		 BASE_URL_PROD_USW2: "prod.example.com",
		 BASE_URL_STAGE: "dev.example.com",
		 BROWSE_TYPE: DeviceBrowserType.CARDS,
		 LOGIN_TYPE: AuthType.OAUTH2,
		 MENU_VIEW: MenuViewType.SETTINGS,
	},
	Settings: {
		 DEBUG_ENABLED: true,
		 DEFAULT_AVATAR: "account_avatar1",
		 DEFAULT_DISPLAY_UI_STYLE: 1,
		 DEFAULT_UI_FONT: "GT-Walsheim-Black.ttf",
		 PREF_ACCOUNT_NAME: "pref_account_display_name",
		 PREF_SERVICE: "pref_service_name",
		 SCALE: 1.5,
		 SHOW_UI: false,
	},
	TemperatureUnits: [
		TemperatureUnit.FAHRENHEIT,
		TemperatureUnit.CELSIUS,
		TemperatureUnit.KELVIN
	],
}
module.exports = Constants;

```
And a SCSS file is generated:

```SCSS

// Generated with Sango, by Afero.io

$COLORS_GRAY01: #E1DFDC;
$COLORS_GRAY01_50: #F2EDEB;
$COLORS_GRAY02: #BFBCB7;
$COLORS_GRAY02_50: #D0CBC7;
$COLORS_GRAY03: #9D9C98;
$COLORS_GRAY03_50: #A4A099;
$COLORS_GRAY04: #85878A;
$COLORS_GRAY04_50: #7E7B77;
$COLORS_GRAY05: #717375;
$COLORS_GRAY06: #616264;
$COLORS_GRAY07: #535557;
$COLORS_ORANGE01: #EDAC93;
$COLORS_ORANGE01_50: #F67D4B;
$COLORS_ORANGE02: #EBA485;
$COLORS_ORANGE03: #EF9471;
$COLORS_ORANGE04: #F2845B;
$COLORS_ORANGE05: #F47344;
$COLORS_ORANGE06: #F67D4B;
$COLORS_WHITE01: #FFFFFF;
$COLORS_WHITE01_50: #FFFFFF;
$RAINBOWCOLORS_0: #535557;
$RAINBOWCOLORS_1: #9D9C98;
$RAINBOWCOLORS_2: #F2845B;
$RAINBOWCOLORS_3: #F67D4B;
$RAINBOWCOLORS_4: #EDAC93;
$SETTINGS_UI_BASE_COLOR: rbga(67, 163, 199, 1.0);
$SETTINGS_UI_BASE_COLOR2: rbga(67, 163, 199, 0.0784313725490196);
$SETTINGS_UI_SECONDARY_COLOR: #431298;
$SETTINGS_UI_SECONDARY_COLOR_LOW: rbga(67, 18, 152, 0.501960784313725);
```

The parsing tool is run from the source platform depot, and the resulting files are copied or generated and put into the correct place, as defined by the JSON file. Those changes are then verified and checked in.

Great thing about this process, is you can branch both the asset depot and the project depot to work on things in sync.

The ‘images’ key are tagged with @2, @3, etc that will be copied direct to drawable-hdpi, drawable-xhdpi, drawable-xxhdpi for equivalent. The ‘copied’ key are just copied into the resource tree of the target platform. The ‘fonts’ key are copied into the target platform for the specific place, and for iOS the bundle will be modified via UIAppFonts to add the fonts the application.

Sango command line options:
```

$ sango -help

Usage:
-asset_template        [basename]                      creates a json template, specifically for the assets
-config                [file.json]                     use config file for options, instead of command line
-config_template       [file.json]                     creates a json template, specifically for the app
-help_keys                                             display JSON keys and their use
-input                 [file.json]                     asset json file
-input_assets          [folder]                        asset source folder (read)
-input_assets_tag      [tag]                           optional git tag to pull repro at before processing
-inputs                [file1.json file2.json ...]     merges asset files and process
-java                                                  write java source
-javascript                                            write javascript source
-locale_only                                           when included, process localization files only
-nodejs                                                write nodejs source
-out_assets            [folder]                        asset root folder (write), typically iOS Resource, or Android app/src/main
-out_locales           [folder]                        locale folder to write results
-out_scss              [source.scss]                   when using javascript/node path to scss file
-out_source            [source.java|swift|js]          path to result of language
-swift                                                 write swift source
-swift3                                                write Swift 3 compatible Swift source (requires -swift)
-validate              [asset_file.json, ...]          validates asset JSON file(s), requires -input_assets
-validate_android      [asset_file.json, ...]          validates Android asset JSON file(s), requires -input_assets
-validate_ios          [asset_file.json, ...]          validates iOS asset JSON file(s), requires -input_assets
-validate_javascript   [asset_file.json, ...]          validates Javascript asset JSON file(s), requires -input_assets
-validate_nodejs       [asset_file.json, ...]          validates NodeJS asset JSON file(s), requires -input_assets
-verbose                                               be verbose in details
-version                                               version
```

```

$ sango -help_keys

JSON keys and their meaning:
appIcon                 string. path to app icon that is common and is scaled
appIconAndroid          string. path to app icon that is Android only and is scaled
appIconIos              string. path to app icon that is iOS  and is scaled
copied                  array. path to files that are common and are just copied
copiedAndroid           array. path to files that Android only and are just copied
copiedIos               array. path to files that are iOS only and are just copied
enums                   dictionary. keys are enum key:value name
fontRoot                path. Destination font root. Default is root of resources
fonts                   array. path to font files
globalTint              color. ie #F67D4B. apply as tint to all images saved
globalTintAndroid       color. ie #F67D4B. apply as tint to all images saved for Android
globalTintIos           color. ie #F67D4B. apply as tint to all images saved for iOS
images                  array. path to image files that are common.
imagesAndroid           array. path to image files that are Android only
imagesIos               array. path to image files that are iOS only
imagesScaled            array. path to image files that are common and will be scaled. Source is always scaled down
imagesScaledAndroid     array. path to image files that are Android only and will be scaled. Source is always scaled down
imagesScaledAndroidUp   array. path to image files that are Android only and will be scaled. Source is always scaled up
imagesScaledIos         array. path to image files that are iOS only and will be scaled. Source is always scaled down
imagesScaledIosUp       array. path to image files that are iOS only and will be scaled. Source is always scaled up
imagesScaledUp          array. path to image files that are common and will be scaled. Source is always scaled up
java                    dictionary. keys are base:class name, package:package name
javascript              dictionary. keys are base:class name
layoutAndroid           array. path to layout files that is Android only
locale                  dictionary. keys are IOS lang. Use 'default' for enUS, enES, path to strings file
nodejs                  dictionary. keys are base:class name
print                   debugging. value is a string and is printed to the console
schemaVersion           number. Version, which should be 1
swift                   dictionary. keys are base:class name
```

A complete example is located in this depot at:

```

$ cd test_example
$ ls
Makefile
config_android.json
config_ios.json
config_javascript.json
simple

Example to build sango data for iOS, Android, NodeJS, Javascript, used for testing.
 build_android
 build_ios
 build_js
 build_all
 validate
```
