//
//  Extras.swift
//  Sango
//
//  Created by Steve Hales on 8/18/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

import Foundation
import AppKit

public extension NSImage
{
    /**
     *  Given a file path, load and return an NSImage
     */
    public static func loadFrom(_ file: String) -> NSImage! {
        // Loading directly with NSImage, doesn't take in account of scale
        let imageReps = NSBitmapImageRep.imageReps(withContentsOfFile: file)
        if (imageReps != nil) {
            var width = 0
            var height = 0
            
            for rep in imageReps! {
                if (rep.pixelsWide > width) {
                    width = rep.pixelsWide
                }
                if (rep.pixelsHigh > height) {
                    height = rep.pixelsHigh
                }
            }
            let newImage = NSImage(size: NSMakeSize(CGFloat(width), CGFloat(height)))
            newImage.setName(file.lastPathComponent())
            newImage.addRepresentations(imageReps!)
            return newImage
        }
        return nil
    }
    
    /**
     *  Given a file, image.png, image@2.png, image@3.png, return the scaling factor
     *  1, 2, 3
     */
    public static func getScaleFrom(_ file :String) -> (scale: Int, file: String) {
        var scale = 1
        var fileName = file.lastPathComponent()
        fileName = (fileName as NSString).deletingPathExtension
        if (fileName.hasSuffix("@1x")) {
            scale = 1
            fileName = fileName.replacingOccurrences(of: "@1x", with: "")
        }
        else if (fileName.hasSuffix("@2x")) {
            scale = 2
            fileName = fileName.replacingOccurrences(of: "@2x", with: "")
        }
        else if (fileName.hasSuffix("@3x")) {
            scale = 3
            fileName = fileName.replacingOccurrences(of: "@3x", with: "")
        }
        return (scale: scale, file: fileName)
    }
    
    public func saveTo(_ file: String) -> Bool {
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(self.size.width),
                                      pixelsHigh: Int(self.size.height),
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: NSDeviceRGBColorSpace,
                                      bytesPerRow: 0,
                                      bitsPerPixel: 0)!
        bitmap.size = self.size
        
        NSGraphicsContext.saveGraphicsState()
        
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: bitmap))
        self.draw(at: NSPoint.zero,
                         from: NSRect.zero,
                         operation: .sourceOver,
                         fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        
        var ok = false
        let imageData = bitmap.representation(using: NSBitmapImageFileType.PNG,
                                                       properties: [NSImageCompressionFactor: 1.0])
        if (imageData != nil) {
            ok = (try? imageData!.write(to: URL(fileURLWithPath: (file as NSString).standardizingPath), options: [.atomic])) != nil
        }
        if (ok == false) {
            Utils.error("Error: Can't save image to \(file)")
        }
        return ok
    }
    
    public func scale(_ percent: CGFloat) -> NSImage {
        if (percent == 100) {
            return self
        }
        else {
            var newR = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            let Width = newR.width
            let Height = newR.height
            let newWidth = (Width * percent) / 100.0
            let newHeight = (Height * percent) / 100.0
            
            let ratioOld = Width / Height
            let ratioNew = newWidth / newHeight
            
            if (ratioOld > ratioNew) {
                newR.size.width = newWidth                         // width of mapped rect
                newR.size.height = newR.size.width / ratioOld      // height of mapped rect
                newR.origin.x = 0                                  // x-coord of mapped rect
                newR.origin.y = (newHeight - newR.size.height) / 2 // y-coord of centered mapped rect
            }
            else {
                newR.size.height = newHeight
                newR.size.width = newR.size.height * ratioOld
                newR.origin.y = 0
                newR.origin.x = (newWidth - newR.size.width) / 2
            }
            return resize(newR.width, height: newR.height)
        }
    }
    
    public func tint(_ color: NSColor) -> NSImage {
        let destSize = self.size
        let rect = NSMakeRect(0, 0, self.size.width, self.size.height)
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(destSize.width),
                                      pixelsHigh: Int(destSize.height),
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: NSDeviceRGBColorSpace,
                                      bytesPerRow: 0,
                                      bitsPerPixel: 0)!
        bitmap.size = destSize
        
        NSGraphicsContext.saveGraphicsState()
        
        let context = NSGraphicsContext(bitmapImageRep: bitmap)
        context?.imageInterpolation = .high
        context?.shouldAntialias = true
        NSGraphicsContext.setCurrent(context)
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
                        from: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: .sourceOver,
                        fraction: 1.0)
        
        // tint with Source Atop operation, via 
        // http://www.w3.org/TR/2014/CR-compositing-1-20140220/#porterduffcompositingoperators
        color.set()
        NSRectFillUsingOperation(rect, .sourceAtop)

        NSGraphicsContext.restoreGraphicsState()
        let newImage = NSImage(size: destSize)
        newImage.addRepresentation(bitmap)
        return NSImage(data: newImage.tiffRepresentation!)!
    }

    public func resize(_ width: CGFloat, height: CGFloat) -> NSImage {
        let destSize = NSMakeSize(width, height)
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(destSize.width),
                                      pixelsHigh: Int(destSize.height),
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: NSDeviceRGBColorSpace,
                                      bytesPerRow: 0,
                                      bitsPerPixel: 0)!
        bitmap.size = destSize
        
        NSGraphicsContext.saveGraphicsState()
        
        let context = NSGraphicsContext(bitmapImageRep: bitmap)
        context?.imageInterpolation = .high
        context?.shouldAntialias = true
        NSGraphicsContext.setCurrent(context)
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
                        from: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: .sourceOver,
                        fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        let newImage = NSImage(size: destSize)
        newImage.addRepresentation(bitmap)
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}

public func + (left: [String: [String: Any]]?, right: [String: [String: Any]]) -> [String: [String: Any]]? {

    let localLeft: [String: [String: Any]] = left ?? [:]
    let localRight: [String: [String: Any]] = right ?? [:]

    return localRight.reduce(localLeft) {
        curr, next in
        var ret = curr
        ret[next.0] = next.1
        return ret
    }
    
}

public func + (left: Dictionary<String, Array<Any>>?, right: Dictionary<String, Array<Any>>?) -> Dictionary<String, Array<Any>> {
    
    let localLeft: [String: Array<Any>] = left ?? [:]
    let localRight: [String: Array<Any>] = right ?? [:]
    
    return localRight.reduce(localLeft) {
        curr, next in
        var ret = curr
        ret[next.0] = [ret[next.0], next.1].flatMap({$0})
        return ret
    }
    
}

public func + (left: Dictionary<String, Any>, right: Dictionary<String, Any>)
    -> Dictionary<String, Any>
{
    var map = left
    for (k, v) in right {
        
        // merge arrays
        if let _v = v as? [Any] {
            if let la = map[k] as? [Any] {
                map[k] = la + _v
            }
            else {
                map[k] = v
            }
        }
        else if
            let _v = v as? Dictionary<String, Any>,
            let la = map[k] as? Dictionary<String, Any> {
            map[k] = la + _v
        }
        else {
            map[k] = v
        }
    }
    return map
}

public func roundTo3f(value: Double) -> Double {
    return round(1000.0 * value) / 1000.0
}
public func roundTo2f(value: Double) -> Double {
    return round(100.0 * value) / 100.0
}

public extension String
{
    public func snakeCaseToCamelCase() -> String {
        let items = self.components(separatedBy: "_")
        var camelCase = ""
        items.enumerated().forEach {
            if ($1.isInteger()) {
                // this is a special case, so we can support a label:
                // Green_50
                camelCase += "_";
            }
            camelCase += $1.capitalized
        }
        return camelCase
    }
    
    // from http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf
    public func escapeStr() -> String {
        let set = [
            "\"":"\u{005C}\"",
            "/":"\\/",
            "\u{0001}":"",
            "\u{0002}":"",
            "\u{0003}":"",
            "\u{0004}":"",
            "\u{0005}":"",
            "\u{0006}":"",
            "\u{0007}":"",
            "\u{0008}":"\\b",
            "\u{0009}":"\\t",
            "\u{000A}":"\\n",
            "\u{000B}":"",
            "\u{000C}":"\\f",
            "\u{000D}":"\\r",
            "\u{000E}":"",
            "\u{000F}":"",
            "\u{0010}":"",
            "\u{0011}":"",
            "\u{0012}":"",
            "\u{0013}":"",
            "\u{0014}":"",
            "\u{0015}":"",
            "\u{0016}":"",
            "\u{0017}":"",
            "\u{0018}":"",
            "\u{0019}":"",
            "\u{001A}":"",
            "\u{001B}":"",
            "\u{001C}":"",
            "\u{001D}":"",
            "\u{001E}":"",
            "\u{001F}":""
        ]
            
        var escaped = self
        for (key, value) in set {
            escaped = escaped.replacingOccurrences(of: key, with: value)
        }
        return escaped
    }

    public func lastPathComponent() -> String {
        return (self as NSString).lastPathComponent
    }

    public func pathOnlyComponent() -> String {
        return (self as NSString).deletingLastPathComponent
    }

    public func fileExtention() -> String {
        return (self as NSString).pathExtension.lowercased()
    }

    public func removeScale() -> String {
        var file = self.replacingOccurrences(of: "@1x", with: "")
        file = file.replacingOccurrences(of: "@2x", with: "")
        return file.replacingOccurrences(of: "@3x", with: "")
    }

    /**
     * File-based resource names must contain only lowercase a-z, 0-9, or underscore
     */
    public func isAndroidCompatible() -> Bool {
        let set:NSMutableCharacterSet = NSMutableCharacterSet()
        set.formUnion(with: CharacterSet.lowercaseLetters)
        set.formUnion(with: CharacterSet.decimalDigits)
        set.addCharacters(in: "_.")
        let inverted = set.inverted
        let file = self.lastPathComponent().removeScale()
        if let _ = file.rangeOfCharacter(from: inverted, options: .caseInsensitive) {
            return false
        }
        return true
    }

    public func isInteger() -> Bool {
        let numberCharacters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && self.rangeOfCharacter(from: numberCharacters) == nil
    }

    public func isFloat() -> Bool {
        var floaty = false
        if (!self.isEmpty) {
            let numberCharacters = NSMutableCharacterSet.decimalDigit()
            numberCharacters.addCharacters(in: ".")
            numberCharacters.invert()
            if (self.rangeOfCharacter(from: numberCharacters as CharacterSet) == nil) {
                if (self.contains(".")) {
                    floaty = true
                }
            }
        }
        return floaty
    }
    
    public func isBoolean() -> Bool {
        return !self.isEmpty && self.lowercased() == "true"
    }
}

public func hasArrayFloats(_ list: Any) -> Bool {
    var valid = false
    let alist = list as? Array<Any>
    if (alist != nil) {
        for itm in alist! {
            if let itm = itm as? String {
                if (itm.isFloat()) {
                    valid = true
                    break
                }
            }
            else if ((itm is Double) || (itm is Int)) {
                let strItm = String(describing: itm)
                if (strItm.isFloat()) {
                    valid = true
                    break
                }
            }
        }
    }
    return valid
}

public func hasArrayInts(_ list: Any) -> Bool {
    var valid = false
    let alist = list as? Array<Any>
    if (alist != nil) {
        for itm in alist! {
            if let itm = itm as? String {
                if (itm.isInteger()) {
                    valid = true
                    break
                }
            }
            else if (itm is Int) {
                let strItm = String(describing: itm)
                if (strItm.isInteger()) {
                    valid = true
                    break
                }
            }
        }
    }
    return valid
}

func test() -> Void {
    let a = "123".isAndroidCompatible()
    let b = "ANB".isAndroidCompatible()
    let c = "asd_234".isAndroidCompatible()
    let d = ",,:asd".isAndroidCompatible()
    let e = "&%#asd".isAndroidCompatible()
    let f = "fe_12_😀".isAndroidCompatible()
    
    print(a, b, c, d, e, f)
}


