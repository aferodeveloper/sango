//
//  Utils.swift
//  Sango
//
//  Created by Steve Hales on 8/24/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

import Foundation

open class Utils
{
    static var verbose = false

    open static func setVerbose(_ state: Bool) -> Void {
        verbose = state
    }

    open static func debug(_ message: String) -> Void {
        if (verbose) {
            print(message)
        }
    }

    open static func error(_ message: String) -> Void {
        print(message)
    }
    
    open static func always(_ message: String) -> Void {
        print(message)
    }

    open static func toJSON(_ dictionary:Dictionary<String, Any>) -> String? {
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            if let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return jsonString.replacingOccurrences(of: "\\/", with: "/")
            }
            return nil
        }
        catch let error as NSError {
            let message:String = error.userInfo["NSDebugDescription"] as! String
            Utils.error(message)
            return nil
        }
    }
    
    open static func fromJSONFile(_ file:String) -> [String:Any]? {
        var result:[String: Any]?
        
        let location = NSString(string: file).expandingTildeInPath
        let fileContent = try? Data(contentsOf: URL(fileURLWithPath: location))
        if (fileContent != nil) {
            result = fromJSON(fileContent!)
            if (result == nil) {
                Utils.error("Error: Can't parse \(location) as JSON")
            }
        }
        else {
            Utils.error("Error: can't find file \(location)")
        }
        return result
    }
    
    open static func fromJSON(_ data:Data) -> [String: Any]? {
        var dict: Any?
        do {
            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
        catch let error as NSError {
            let message:String = error.userInfo["NSDebugDescription"] as! String
            Utils.error(message)
            dict = nil
        }
        
        return dict as? [String: Any]
    }

    open static func createFolders(_ folders: [String]) -> Bool {
        for file in folders {
            do {
                try FileManager.default.createDirectory(atPath: file, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                Utils.error("Error: creating folder \(file)")
                exit(-1)
            }
        }
        return true
    }
    
    @discardableResult open static func createFolderForFile(_ srcFile: String) -> Bool {
        let destPath = (srcFile as NSString).deletingLastPathComponent
        return createFolder(destPath)
    }
    
    @discardableResult open static func createFolder(_ src: String) -> Bool {
        var ok = true
        do {
            try FileManager.default.createDirectory(atPath: src, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            Utils.error("Error: creating folder \(src)")
            ok = false
        }
        
        return ok
    }

    @discardableResult open static func deleteFolder(_ src: String) -> Bool {
        var ok = true
        do {
            try FileManager.default.removeItem(atPath: src)
        }
        catch {
            ok = false
        }
        
        return ok
    }

    open static func copyFile(_ src: String, dest: String) -> Bool {
        deleteFile(dest)
        var ok = true
        do {
            try FileManager.default.copyItem(atPath: src, toPath: dest)
            Utils.debug("Copy \(src) -> \(dest)")
        }
        catch {
            Utils.error("Error: copying file \(src) to \(dest): \(String(reflecting: error))")
            ok = false
        }
        
        return ok
    }
    
    open static func copyFiles(_ files: [String], useRoot: Bool,
                                 srcRootPath: String, dstRootPath: String) -> Void {
        for file in files {
            let filePath = srcRootPath + "/" + file
            var destFile:String
            if (useRoot) {
                destFile = dstRootPath + "/" + file.lastPathComponent()
            }
            else {
                destFile = dstRootPath + "/" + file
            }
            let destPath = (destFile as NSString).deletingLastPathComponent
            createFolder(destPath)
            if (copyFile(filePath, dest: destFile) == false) {
                exit(-1)
            }
        }
    }

    @discardableResult open static func deleteFile(_ src: String) -> Bool {
        var ok = true
        do {
            try FileManager.default.removeItem(atPath: src)
        }
        catch {
            ok = false
        }
        
        return ok
    }
}

// EOF

