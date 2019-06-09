/**
 * Copyright 2016 Afero, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import Cocoa

public enum AspectMode: String {
    case fill
    case fit
    case none
}

public extension NSImage
{
    /// The height of the image.
    var height: CGFloat {
        return size.height
    }
    
    /// The width of the image.
    var width: CGFloat {
        return size.width
    }

    /// A PNG representation of the image.
    var PNGRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .png, properties: [:])
        }
        
        return nil
    }
    
    /// Saves the PNG representation of the image to the supplied URL parameter.
    ///
    /// - Parameter url: The URL to save the image data to.
    /// - Throws: An NSImageExtensionError if unwrapping the image data fails.
    ///           An error in the Cocoa domain, if there is an error writing to the URL.
    func savePngTo(url: URL) throws {
        guard let png = self.PNGRepresentation else {
            throw NSImageExtensionError.unwrappingPNGRepresentationFailed
        }
        try png.write(to: url, options: .atomicWrite)
    }
    
    /// Calculate the image size for a given aspect mode.
    ///
    /// - Parameters:
    ///   - targetSize: The size the image should be resized to
    ///   - aspectMode: The aspect mode to calculate the actual image size
    /// - Returns: The new image size
    private func calculateAspectSize(withTargetSize targetSize: NSSize, aspectMode: AspectMode) -> NSSize? {
        if aspectMode == .fit {
            return self.calculateFitAspectSize(widthRatio: targetSize.width / self.width,
                                               heightRatio: targetSize.height / self.height)
        }
        
        if aspectMode == .fill {
            return self.calculateFillAspectSize(widthRatio: targetSize.width / self.width,
                                                heightRatio: targetSize.height / self.height)
        }
        
        return nil
    }
    
    /// Calculate the size for an image to be resized in aspect fit mode; That is resizing it without
    /// cropping the image.
    ///
    /// - Parameters:
    ///   - widthRatio: The width ratio of the image and the target size the image should be resized to.
    ///   - heightRatio: The height retio of the image and the targed size the image should be resized to.
    /// - Returns: The maximum size the image can have, to fit inside the targed size, without cropping anything.
    private func calculateFitAspectSize(widthRatio: CGFloat, heightRatio: CGFloat) -> NSSize {
        if widthRatio < heightRatio {
            return NSSize(width: floor(self.width * widthRatio),
                          height: floor(self.height * widthRatio))
        }
        return NSSize(width: floor(self.width * heightRatio), height: floor(self.height * heightRatio))
    }
    
    /// Calculate the size for an image to be resized in aspect fill mode; That is resizing it and cropping
    /// the edges of the image, if necessary.
    ///
    /// - Parameters:
    ///   - widthRatio: The width ratio of the image and the target size the image should be resized to.
    ///   - heightRatio: The height retio of the image and the targed size the image should be resized to.
    /// - Returns: The minimum size the image needs to have to fill the complete target area.
    private func calculateFillAspectSize(widthRatio: CGFloat, heightRatio: CGFloat) -> NSSize? {
        if widthRatio > heightRatio {
            return NSSize(width: floor(self.width * widthRatio),
                          height: floor(self.height * widthRatio))
        }
        return NSSize(width: floor(self.width * heightRatio), height: floor(self.height * heightRatio))
    }

    /**
     *  Given a file path, load and return an NSImage
     */
    static func loadFrom(_ file: String) -> NSImage! {
        // Loading directly with NSImage, doesn't take in account of scale
        if let imageReps = NSBitmapImageRep.imageReps(withContentsOfFile: file) {
            var width = 0
            var height = 0
            
            for rep in imageReps {
                if (rep.pixelsWide > width) {
                    width = rep.pixelsWide
                }
                if (rep.pixelsHigh > height) {
                    height = rep.pixelsHigh
                }
            }
            let newImage = NSImage(size: NSMakeSize(CGFloat(width), CGFloat(height)))
            newImage.setName(NSImage.Name(rawValue: file.lastPathComponent()))
            newImage.addRepresentations(imageReps)
            return newImage
        }
        return nil
    }
    
    /**
     *  Given a file, image.png, image@2.png, image@3.png, return the scaling factor
     *  1, 2, 3
     */
    static func getScaleFrom(_ file :String) -> (scale: Int, file: String) {
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
    
    func saveTo(_ file: String) -> Bool {
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(self.size.width),
                                      pixelsHigh: Int(self.size.height),
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: NSColorSpaceName.deviceRGB,
                                      bytesPerRow: 0,
                                      bitsPerPixel: 0)!
        bitmap.size = self.size
        
        NSGraphicsContext.saveGraphicsState()
        
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        self.draw(at: NSPoint.zero,
                         from: NSRect.zero,
                         operation: .sourceOver,
                         fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        
        var ok = false
        if let imageData = bitmap.representation(using: NSBitmapImageRep.FileType.png,
                                                 properties: [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]) {
            ok = (try? imageData.write(to: URL(fileURLWithPath: (file as NSString).standardizingPath), options: [.atomic])) != nil
        }
        if (ok == false) {
            Utils.error("Error: Can't save image to \(file)")
        }
        return ok
    }
    
    func scale(_ percent: CGFloat) -> NSImage {
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
    
    func tint(_ color: NSColor) -> NSImage {
        let destSize = self.size
        let rect = NSMakeRect(0, 0, self.size.width, self.size.height)
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(destSize.width),
                                      pixelsHigh: Int(destSize.height),
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: NSColorSpaceName.deviceRGB,
                                      bytesPerRow: 0,
                                      bitsPerPixel: 0)!
        bitmap.size = destSize
        
        NSGraphicsContext.saveGraphicsState()
        
        let context = NSGraphicsContext(bitmapImageRep: bitmap)
        context?.imageInterpolation = .high
        context?.shouldAntialias = true
        NSGraphicsContext.current = context
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
                        from: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: .sourceOver,
                        fraction: 1.0)
        
        // tint with Source Atop operation, via 
        // http://www.w3.org/TR/2014/CR-compositing-1-20140220/#porterduffcompositingoperators
        color.set()
        rect.fill(using: .sourceAtop)

        NSGraphicsContext.restoreGraphicsState()
        let newImage = NSImage(size: destSize)
        newImage.addRepresentation(bitmap)
        return NSImage(data: newImage.tiffRepresentation!)!
    }

    func roundCorner(_ radiusX: CGFloat, _ radiusY : CGFloat) -> NSImage? {
        let imageFrame = NSMakeRect(0, 0, self.size.width, self.size.height)
        
        let composedImage = NSImage(size: imageFrame.size)
        composedImage.lockFocus()
        guard let context = NSGraphicsContext.current else {
            composedImage.unlockFocus()
            return nil
        }
        context.imageInterpolation = .high
        context.shouldAntialias = true
        
        let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: radiusX, yRadius: radiusY)
        clipPath.windingRule = NSBezierPath.WindingRule.evenOddWindingRule
        clipPath.addClip()
        
        self.draw(at: NSPoint.zero, from: imageFrame, operation: NSCompositingOperation.sourceOver, fraction: 1)
        composedImage.unlockFocus()
        return composedImage
    }

    func resize(_ width: CGFloat, height: CGFloat) -> NSImage {
        let destSize = NSMakeSize(width, height)
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(destSize.width),
                                      pixelsHigh: Int(destSize.height),
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: NSColorSpaceName.deviceRGB,
                                      bytesPerRow: 0,
                                      bitsPerPixel: 0)!
        bitmap.size = destSize
        
        NSGraphicsContext.saveGraphicsState()
        
        let context = NSGraphicsContext(bitmapImageRep: bitmap)
        context?.imageInterpolation = .high
        context?.shouldAntialias = true
        NSGraphicsContext.current = context
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
                        from: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: .sourceOver,
                        fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        
        let newImage = NSImage(size: destSize)
        newImage.addRepresentation(bitmap)
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    /// Resize the image to the given size.
    ///
    /// - Parameter size: The size to resize the image to.
    /// - Returns: The resized image.
    func resize(toSize targetSize: NSSize, aspectMode: AspectMode) -> NSImage? {
        let newSize     = self.calculateAspectSize(withTargetSize: targetSize, aspectMode: aspectMode) ?? targetSize
        let xCoordinate = round((targetSize.width - newSize.width) / 2)
        let yCoordinate = round((targetSize.height - newSize.height) / 2)
        let targetFrame = NSRect(origin: NSPoint.zero, size: targetSize)
        let frame       = NSRect(origin: NSPoint(x: xCoordinate, y: yCoordinate), size: newSize)
        
        var backColor   = NSColor.clear
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            backColor = tiffData.colorAt(x: 0, y: 0) ?? NSColor.clear
        }
        
        return NSImage(size: targetSize, flipped: false) { (_: NSRect) -> Bool in
            backColor.setFill()
            NSBezierPath.fill(targetFrame)
            guard let rep = self.bestRepresentation(for: NSRect(origin: NSPoint.zero, size: newSize),
                                                    context: nil,
                                                    hints: nil) else {
                                                        return false
            }
            return rep.draw(in: frame)
        }
    }
    
}

public func + (left: [String: [String: Any]]?, right: [String: [String: Any]]?) -> [String: [String: Any]]? {

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
        ret[next.0] = [ret[next.0], next.1].compactMap({$0})
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

public extension Character
{
    func unicodeScalarCodePoint() -> UnicodeScalar {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex]
    }
}

public extension String
{
    func lowercasedFirst() -> String {
        let first = String(prefix(1)).lowercased()
        return first + String(dropFirst())
    }
    
    func uppercasedFirst() -> String {
        let first = String(prefix(1)).uppercased()
        return first + String(dropFirst())
    }

    func removeFirst() -> String {
        return String(dropFirst())
    }

    func snakeCaseToCamelCase() -> String {
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
    func escapeStr() -> String {
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

    func lastPathComponent() -> String {
        return (self as NSString).lastPathComponent
    }

    func pathOnlyComponent() -> String {
        return (self as NSString).deletingLastPathComponent
    }

    func fileExtention() -> String {
        return (self as NSString).pathExtension.lowercased()
    }

    func fileNameOnly() -> String {
        let fileName = self.lastPathComponent()
        return (fileName as NSString).deletingPathExtension
    }

    func removeScale() -> String {
        var file = self.replacingOccurrences(of: "@1x", with: "")
        file = file.replacingOccurrences(of: "@2x", with: "")
        return file.replacingOccurrences(of: "@3x", with: "")
    }

    /**
     * File-based resource names must contain only lowercase a-z, 0-9, or underscore
     */
    func isAndroidCompatible() -> Bool {
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

    /**
     *  Remove digits from the start of a string only
     */
    func removeDigitsPrefix() -> String {
        var newString = String()
        let numbers = CharacterSet.decimalDigits
        var finished = false
        for (_, c) in self.enumerated() {
            let uc = c.unicodeScalarCodePoint()
            if (numbers.contains(uc) == false) || finished {
                newString.append(c)
                finished = true
            }
        }
        return newString
    }

    func removeWhitespace() -> String {
        return self.removeCharacters(.whitespacesAndNewlines)
    }

    func removeCharacters(_ set: CharacterSet) -> String {
        var newString = String()
        for (_, c) in self.enumerated() {
            let uc = c.unicodeScalarCodePoint()
            if set.contains(uc) == false {
                newString.append(c)
            }
        }
        return newString
    }

    func trunc(_ length: Int, trailing: String? = "…") -> String {
        if self.count > length {
            return String(self.prefix(length)) + (trailing ?? "")
        }
        else {
            return String(self)
        }
    }

    func isInteger() -> Bool {
        let numberCharacters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && self.rangeOfCharacter(from: numberCharacters) == nil
    }

    func isFloat() -> Bool {
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
    
    func isBoolean() -> Bool {
        return !self.isEmpty && self.lowercased() == "true"
    }
}

public func hasArrayBoolean(_ list: [Any]) -> Bool {
    var valid = false
    for itm in list {
        if let itm = itm as? String {
            if (itm.isBoolean()) {
                valid = true
                break
            }
        }
        else if itm is Bool {
            let strItm = String(describing: itm)
            if (strItm.isBoolean()) {
                valid = true
                break
            }
        }
    }
    return valid
}

public func hasArrayFloats(_ list: [Any]) -> Bool {
    var valid = false
    for itm in list {
        if let itm = itm as? String {
            if (itm.isFloat()) {
                valid = true
                break
            }
        }
        else if itm is Double || itm is Int {
            let strItm = String(describing: itm)
            if (strItm.isFloat()) {
                valid = true
                break
            }
        }
    }
    return valid
}

public func hasArrayInts(_ list: [Any]) -> Bool {
    var valid = false
    for itm in list {
        if let itm = itm as? String {
            if (itm.isInteger()) {
                valid = true
                break
            }
        }
        else if itm is Int {
            let strItm = String(describing: itm)
            if (strItm.isInteger()) {
                valid = true
                break
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


