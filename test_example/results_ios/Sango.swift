/* Generated with Sango, by Afero.io */

import UIKit
public struct Sango {
    public static let Version = "Sango © 2016 Afero, Inc - Build 186"
}
extension String {
    init(locKey key: String, value: String) {
        let v = NSBundle.mainBundle().localizedStringForKey(key, value: value, table: nil)
        self.init(v)
    }

    init(locKey key: String) {
        let v = NSBundle.mainBundle().localizedStringForKey(key, value: nil, table: nil)
        self.init(v)
    }
}
