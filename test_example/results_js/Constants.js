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
	ASR_1: 'ASR_1', AC_ICON_LARGE: 'AC_ICON_LARGE'
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
		 BASE_URL_PROD_USW2: "api.afero.io",
		 BASE_URL_STAGE: "api.dev.afero.io",
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
