/* Generated with Sango, by Afero.io */

import UIKit
public struct Constants {
	public struct Colors {
		public static let Gray01 = UIColor(red: 0.882, green: 0.875, blue: 0.863, alpha: 1.0) /* #E1DFDC */
		public static let Gray01_50 = UIColor(red: 0.949, green: 0.929, blue: 0.922, alpha: 1.0) /* #F2EDEB */
		public static let Gray02 = UIColor(red: 0.749, green: 0.737, blue: 0.718, alpha: 1.0) /* #BFBCB7 */
		public static let Gray02_50 = UIColor(red: 0.816, green: 0.796, blue: 0.78, alpha: 1.0) /* #D0CBC7 */
		public static let Gray03 = UIColor(red: 0.616, green: 0.612, blue: 0.596, alpha: 1.0) /* #9D9C98 */
		public static let Gray03_50 = UIColor(red: 0.643, green: 0.627, blue: 0.6, alpha: 1.0) /* #A4A099 */
		public static let Gray04 = UIColor(red: 0.522, green: 0.529, blue: 0.541, alpha: 1.0) /* #85878A */
		public static let Gray04_50 = UIColor(red: 0.494, green: 0.482, blue: 0.467, alpha: 1.0) /* #7E7B77 */
		public static let Gray05 = UIColor(red: 0.443, green: 0.451, blue: 0.459, alpha: 1.0) /* #717375 */
		public static let Gray06 = UIColor(red: 0.38, green: 0.384, blue: 0.392, alpha: 1.0) /* #616264 */
		public static let Gray07 = UIColor(red: 0.325, green: 0.333, blue: 0.341, alpha: 1.0) /* #535557 */
		public static let Orange01 = UIColor(red: 0.929, green: 0.675, blue: 0.576, alpha: 1.0) /* #EDAC93 */
		public static let Orange01_50 = UIColor(red: 0.965, green: 0.49, blue: 0.294, alpha: 1.0) /* #F67D4B */
		public static let Orange02 = UIColor(red: 0.922, green: 0.643, blue: 0.522, alpha: 1.0) /* #EBA485 */
		public static let Orange03 = UIColor(red: 0.937, green: 0.58, blue: 0.443, alpha: 1.0) /* #EF9471 */
		public static let Orange04 = UIColor(red: 0.949, green: 0.518, blue: 0.357, alpha: 1.0) /* #F2845B */
		public static let Orange05 = UIColor(red: 0.957, green: 0.451, blue: 0.267, alpha: 1.0) /* #F47344 */
		public static let Orange06 = UIColor(red: 0.965, green: 0.49, blue: 0.294, alpha: 1.0) /* #F67D4B */
		public static let White01 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) /* #FFFFFF */
		public static let White01_50 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) /* #FFFFFF */
	}
	public struct Dimen {
		public static let ButtonGroupSpacing = "10dp"
		public static let ButtonRadius = "400dp"
		public static let OfflineScheduleDayEditorRingWidth = "35dp"
		public static let OobeArrowSize = "120dp"
		public static let OobeIconSize = "100dp"
		public static let OobeMadalHline = "40dp"
		public static let OobeModalVline = "80dp"
		public static let ViewOnboardingBoard = "400dp"
		public static let ViewOnboardingBoardMarginTop = "50dp"
		public static let ViewOnboardingBoardWrapper = "600dp"
		public static let ViewOnboardingLabelMarginSide = "20dp"
		public static let ViewOnboardingLabelMarginTop = "75dp"
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
		public static let BaseUrlProdUsw2 = "prod.example.com"
		public static let BaseUrlStage = "dev.example.com"
		public static let BrowseType = DeviceBrowserType.cards
		public static let LoginType = AuthType.oauth2
		public static let MenuView = MenuViewType.settings
	}
	public struct Settings {
		public static let DebugEnabled = true
		public static let DefaultAvatar = "account_avatar1"
		public static let DefaultDisplayUiStyle = 1
		public static let DefaultUiFont = "GT-Walsheim-Black.ttf"
		public static let PrefAccountName = "pref_account_display_name"
		public static let PrefService = "pref_service_name"
		public static let Scale = 1.5
		public static let ShowUi = false
		public static let UiBaseColor = UIColor(red: 0.263, green: 0.639, blue: 0.78, alpha: 1.0) /* 67,163,199,255 */
		public static let UiBaseColor2 = UIColor(red: 0.263, green: 0.639, blue: 0.78, alpha: 0.078) /* 67,163,199,20 */
		public static let UiSecondaryColor = UIColor(red: 0.263, green: 0.071, blue: 0.596, alpha: 1.0) /* #431298 */
		public static let UiSecondaryColorLow = UIColor(red: 0.263, green: 0.071, blue: 0.596, alpha: 0.502) /* #80431298 */
	}
	public static let TemperatureUnits = [
			TemperatureUnit.fahrenheit,
			TemperatureUnit.celsius,
			TemperatureUnit.kelvin
		]
	public enum AuthType {
		case afero
		case oauth2
	}
	public enum Day {
		case monday
		case tuesday
		case wednesday
		case thursday
		case friday
		case saturday
		case sunday
	}
	public enum DeviceBrowserType {
		case hex
		case cards
	}
	public enum MenuViewType {
		case classic
		case settings
	}
	public enum SafeImages {
		case asr_1
	}
	public enum TemperatureUnit {
		case celsius
		case fahrenheit
		case kelvin
	}
	public enum TimeOfDay {
		case breakfast
		case lunch
		case snack
		case dinner
	}
}
