/* Generated with Sango, by Afero.io */

package io.afero.tokui;
public final class Constants {
	public static final String Empty[] = {
		""
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
		public static final String BASE_URL_PROD_USW2 = "api.afero.io";
		public static final String BASE_URL_STAGE = "api.dev.afero.io";
		public static final DeviceBrowserType BROWSE_TYPE = DeviceBrowserType.CARDS;
		public static final MenuViewType MENU_VIEW = MenuViewType.SETTINGS;
		public static final AuthType TYPE = AuthType.OAUTH2;
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
		ASR_1, AC_ICON_LARGE
	}
	public enum TimeOfDay {
		BREAKFAST, LUNCH, SNACK, DINNER
	}
}
