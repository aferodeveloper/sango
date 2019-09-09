/* DO NOT MODIFY. Generated with Sango, by Afero.io */

package io.afero.example
object Constants {
	val Empty = arrayOf<String>(
		
	)
	val FloatyNumbers = doubleArrayOf(
		1.0,
		2.0,
		3.15,
		23.0,
		415.03
	)
	val Hello = arrayOf(
		"one",
		"two",
		"three"
	)
	val InteryNumbers = intArrayOf(
		5,
		23,
		54,
		120,
		100
	)
	object Service {
		const val BASE_URL_PROD_USW2 = "prod.example.com"
		const val BASE_URL_STAGE = "dev.example.com"
		const val BROWSE_TYPE = DeviceBrowserType.CARDS
		const val LOGIN_TYPE = AuthType.OAUTH2
		const val MENU_VIEW = MenuViewType.SETTINGS
	}
	object Settings {
		const val DEBUG_ENABLED = true
		const val DEFAULT_AVATAR = "account_avatar1"
		const val DEFAULT_DISPLAY_UI_STYLE = 1
		const val DEFAULT_UI_FONT = "GT-Walsheim-Black.ttf"
		const val PREF_ACCOUNT_NAME = "pref_account_display_name"
		const val PREF_SERVICE = "pref_service_name"
		const val SCALE = 1.5
		const val SHOW_UI = false
	}
	val TemperatureUnits = arrayOf(
		TemperatureUnit.FAHRENHEIT,
		TemperatureUnit.CELSIUS,
		TemperatureUnit.KELVIN
	)
	val TruthyBools = booleanArrayOf(
		true,
		true,
		false,
		true,
		false
	)
	enum class AuthType {
		AFERO, OAUTH2
	}
	enum class Day {
		MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
	}
	enum class DeviceBrowserType {
		HEX, CARDS
	}
	enum class MenuViewType {
		CLASSIC, SETTINGS
	}
	enum class SafeImages {
		ASR_1
	}
	enum class TemperatureUnit {
		CELSIUS, FAHRENHEIT, KELVIN
	}
	enum class TimeOfDay {
		BREAKFAST, LUNCH, SNACK, DINNER
	}
}
