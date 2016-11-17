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
    public static func loadFrom(file: String) -> NSImage! {
        // Loading directly with NSImage, doesn't take in account of scale
        let imageReps = NSBitmapImageRep.imageRepsWithContentsOfFile(file)
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
    public static func getScaleFrom(file :String) -> (scale: Int, file: String) {
        var scale = 1
        var fileName = file.lastPathComponent()
        fileName = (fileName as NSString).stringByDeletingPathExtension
        if (fileName.hasSuffix("@1x")) {
            scale = 1
            fileName = fileName.stringByReplacingOccurrencesOfString("@1x", withString: "")
        }
        else if (fileName.hasSuffix("@2x")) {
            scale = 2
            fileName = fileName.stringByReplacingOccurrencesOfString("@2x", withString: "")
        }
        else if (fileName.hasSuffix("@3x")) {
            scale = 3
            fileName = fileName.stringByReplacingOccurrencesOfString("@3x", withString: "")
        }
        return (scale: scale, file: fileName)
    }
    
    public func saveTo(file: String) -> Bool {
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
        
        NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: bitmap))
        self.drawAtPoint(NSPoint.zero,
                         fromRect: NSRect.zero,
                         operation: .SourceOver,
                         fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        
        var ok = false
        let imageData = bitmap.representationUsingType(NSBitmapImageFileType.PNG,
                                                       properties: [NSImageCompressionFactor: 1.0])
        if (imageData != nil) {
            ok = imageData!.writeToFile((file as NSString).stringByStandardizingPath, atomically: true)
        }
        if (ok == false) {
            print("Error: Can't save image to \(file)")
        }
        return ok
    }
    
    public func scale(percent: CGFloat) -> NSImage {
        if (percent == 100) {
            return self
        }
        else {
            var newR = CGRectMake(0, 0, self.size.width, self.size.height)
            let Width = CGRectGetWidth(newR)
            let Height = CGRectGetHeight(newR)
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
    
    public func tint(color: NSColor) -> NSImage {
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
        context?.imageInterpolation = .High
        context?.shouldAntialias = true
        NSGraphicsContext.setCurrentContext(context)
        self.drawInRect(NSMakeRect(0, 0, destSize.width, destSize.height),
                        fromRect: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: .SourceOver,
                        fraction: 1.0)
        
        // tint with Source Atop operation, via 
        // http://www.w3.org/TR/2014/CR-compositing-1-20140220/#porterduffcompositingoperators
        color.set()
        NSRectFillUsingOperation(rect, .SourceAtop)

        NSGraphicsContext.restoreGraphicsState()
        let newImage = NSImage(size: destSize)
        newImage.addRepresentation(bitmap)
        return NSImage(data: newImage.TIFFRepresentation!)!
    }

    public func resize(width: CGFloat, height: CGFloat) -> NSImage {
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
        context?.imageInterpolation = .High
        context?.shouldAntialias = true
        NSGraphicsContext.setCurrentContext(context)
        self.drawInRect(NSMakeRect(0, 0, destSize.width, destSize.height),
                        fromRect: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: .SourceOver,
                        fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        let newImage = NSImage(size: destSize)
        newImage.addRepresentation(bitmap)
        return NSImage(data: newImage.TIFFRepresentation!)!
    }
}

public func + (left: [String: [String: AnyObject]]?, right: [String: [String: AnyObject]]) -> [String: [String: AnyObject]]? {

    let localLeft: [String: [String: AnyObject]] = left ?? [:]
    let localRight: [String: [String: AnyObject]] = right ?? [:]

    return localRight.reduce(localLeft) {
        curr, next in
        var ret = curr
        ret[next.0] = next.1
        return ret
    }
    
}

public func + (left: Dictionary<String, Array<AnyObject>>?, right: Dictionary<String, Array<AnyObject>>?) -> Dictionary<String, Array<AnyObject>> {
    
    let localLeft: [String: Array<AnyObject>] = left ?? [:]
    let localRight: [String: Array<AnyObject>] = right ?? [:]
    
    return localRight.reduce(localLeft) {
        curr, next in
        var ret = curr
        ret[next.0] = [ret[next.0], next.1].flatMap({$0})
        return ret
    }
    
}

public func + (left: Dictionary<String, AnyObject>, right: Dictionary<String, AnyObject>)
    -> Dictionary<String, AnyObject>
{
    var map = left
    for (k, v) in right {
        
        // merge arrays
        if let _v = v as? [AnyObject] {
            if let la = map[k] as? [AnyObject] {
                map[k] = la + _v
            }
            else {
                map[k] = v
            }
        }
        else if
            let _v = v as? Dictionary<String, AnyObject>,
            let la = map[k] as? Dictionary<String, AnyObject> {
            map[k] = la + _v
        }
        else {
            map[k] = v
        }
    }
    return map
}

public extension Double
{
    public var roundTo3f: Double {return Double(round(1000 * self) / 1000) }
    public var roundTo2f: Double {return Double(round(100 * self) / 100) }
}

public extension String
{
    public func snakeCaseToCamelCase() -> String {
        let items = self.componentsSeparatedByString("_")
        var camelCase = ""
        items.enumerate().forEach {
            if ($1.isNumber()) {
                // this is a special case, so we can support a label:
                // Green_50
                camelCase += "_";
            }
            camelCase += $1.capitalizedString
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
            escaped = escaped.stringByReplacingOccurrencesOfString(key, withString: value)
        }
        return escaped
    }

    public func lastPathComponent() -> String {
        return (self as NSString).lastPathComponent
    }

    public func pathOnlyComponent() -> String {
        return (self as NSString).stringByDeletingLastPathComponent
    }

    public func fileExtention() -> String {
        return (self as NSString).pathExtension.lowercaseString
    }

    public func removeScale() -> String {
        var file = self.stringByReplacingOccurrencesOfString("@1x", withString: "")
        file = file.stringByReplacingOccurrencesOfString("@2x", withString: "")
        return file.stringByReplacingOccurrencesOfString("@3x", withString: "")
    }

    /**
     * File-based resource names must contain only lowercase a-z, 0-9, or underscore
     */
    public func isAndroidCompatible() -> Bool {
        let set:NSMutableCharacterSet = NSMutableCharacterSet()
        set.formUnionWithCharacterSet(NSCharacterSet.lowercaseLetterCharacterSet())
        set.formUnionWithCharacterSet(NSCharacterSet.decimalDigitCharacterSet())
        set.addCharactersInString("_.")
        let inverted = set.invertedSet
        let file = self.lastPathComponent().removeScale()
        if let _ = file.rangeOfCharacterFromSet(inverted, options: .CaseInsensitiveSearch) {
            return false
        }
        return true
    }

    public func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return !self.isEmpty && self.rangeOfCharacterFromSet(numberCharacters) == nil
    }

    public func isBoolean() -> Bool {
        return !self.isEmpty && self.lowercaseString == "true"
    }
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


