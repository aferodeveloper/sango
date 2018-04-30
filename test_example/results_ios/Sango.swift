/* Generated with Sango, by Afero.io */

import UIKit
public struct Sango {
    public static let Version = "Sango © 2016,2017 Afero, Inc - Build 258"
}
extension String {
    init(locKey key: String, value: String) {
        self = Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }

    init(locKey key: String) {
        self = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }
}
