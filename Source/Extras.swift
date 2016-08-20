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
            newImage.setName((file as NSString).lastPathComponent)
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
        var fileName = (file as NSString).lastPathComponent
        fileName = (fileName as NSString).stringByDeletingPathExtension
        if (fileName.hasSuffix("@2x")) {
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
                         operation: NSCompositingOperation.CompositeSourceOver,
                         fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        
        var ok = false
        let imageData = bitmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType,
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
        context?.imageInterpolation = NSImageInterpolation.High
        NSGraphicsContext.setCurrentContext(context)
        self.drawInRect(NSMakeRect(0, 0, destSize.width, destSize.height),
                        fromRect: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: NSCompositingOperation.CompositeSourceOver,
                        fraction: 1.0)
        color.setFill()
        NSBezierPath.fillRect(rect)

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
        context?.imageInterpolation = NSImageInterpolation.High
        NSGraphicsContext.setCurrentContext(context)
        self.drawInRect(NSMakeRect(0, 0, destSize.width, destSize.height),
                        fromRect: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: NSCompositingOperation.CompositeSourceOver,
                        fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        let newImage = NSImage(size: destSize)
        newImage.addRepresentation(bitmap)
        return NSImage(data: newImage.TIFFRepresentation!)!
    }
}

public func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>)
    -> Dictionary<K,V>
{
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
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
            camelCase += $1.capitalizedString
        }
        return camelCase
    }
    
    /**
     * File-based resource names must contain only lowercase a-z, 0-9, or underscore
     */
    public func isAndroidCompatible() -> Bool {
        let set:NSMutableCharacterSet = NSMutableCharacterSet()
        set.formUnionWithCharacterSet(NSCharacterSet.lowercaseLetterCharacterSet())
        set.formUnionWithCharacterSet(NSCharacterSet.decimalDigitCharacterSet())
        set.addCharactersInString("_")
        let inverted = set.invertedSet
        if let _ = self.rangeOfCharacterFromSet(inverted, options: .CaseInsensitiveSearch) {
            return false
        }
        return true
    }

    public func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return !self.isEmpty && self.rangeOfCharacterFromSet(numberCharacters) == nil
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


