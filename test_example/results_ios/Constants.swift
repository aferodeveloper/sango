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
	public struct Dimen {
		static let ButtonGroupSpacing = "10dp"
		static let ButtonRadius = "400dp"
		static let OfflineScheduleDayEditorRingWidth = "35dp"
		static let OobeArrowSize = "120dp"
		static let OobeIconSize = "100dp"
		static let OobeMadalHline = "40dp"
		static let OobeModalVline = "80dp"
		static let ViewOnboardingBoard = "400dp"
		static let ViewOnboardingBoardMarginTop = "50dp"
		static let ViewOnboardingBoardWrapper = "600dp"
		static let ViewOnboardingLabelMarginSide = "20dp"
		static let ViewOnboardingLabelMarginTop = "75dp"
	}
	public static let Empty = [
			
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
		static let BaseUrlProdUsw2 = "prod.example.com"
		static let BaseUrlStage = "dev.example.com"
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
