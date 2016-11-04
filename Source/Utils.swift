//
//  Utils.swift
//  Sango
//
//  Created by Steve Hales on 8/24/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

import Foundation

public class Utils
{
    private static var verbose = false

    public static func setVerbose(state: Bool) -> Void
    {
        verbose = state
    }

    public static func debug(message: String) -> Void
    {
        if (verbose) {
            print(message)
        }
    }
    
    public static func toJSON(dictionary:Dictionary<String, AnyObject>) -> String?
    {
        do {
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
            let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            return jsonString.stringByReplacingOccurrencesOfString("\\/", withString: "/")
        }
        catch let error as NSError {
            let message:String = error.userInfo["NSDebugDescription"] as! String
            print(message)
            return nil
        }
    }
    
    public static func fromJSONFile(file:String) -> [String:AnyObject]?
    {
        var result:[String: AnyObject]?
        
        let location = NSString(string: file).stringByExpandingTildeInPath
        let fileContent = NSData(contentsOfFile: location)
        if (fileContent != nil) {
            result = fromJSON(fileContent!)
            if (result == nil) {
                print("Error: Can't parse \(location) as JSON")
            }
        }
        else {
            print("Error: can't find file \(location)")
        }
        return result
    }
    
    public static func fromJSON(data:NSData) -> [String: AnyObject]?
    {
        var dict:[String: AnyObject]?
        do {
            dict = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject]
        }
        catch let error as NSError {
            let message:String = error.userInfo["NSDebugDescription"] as! String
            print(message)
            dict = nil
        }
        return dict
    }

    public static func createFolders(folders: [String]) -> Bool {
        for file in folders {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(file, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Error: creating folder \(file)")
                exit(-1)
            }
        }
        return true
    }
    
    public static func createFolderForFile(srcFile: String) -> Bool {
        let destPath = (srcFile as NSString).stringByDeletingLastPathComponent
        return createFolder(destPath)
    }
    
    public static func createFolder(src: String) -> Bool {
        var ok = true
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(src, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("Error: creating folder \(src)")
            ok = false
        }
        
        return ok
    }

    public static func deleteFolder(src: String) -> Bool {
        var ok = true
        do {
            try NSFileManager.defaultManager().removeItemAtPath(src)
        }
        catch {
            print("Error: creating folder \(src)")
            ok = false
        }
        
        return ok
    }

    public static func copyFile(src: String, dest: String) -> Bool {
        deleteFile(dest)
        var ok = true
        do {
            try NSFileManager.defaultManager().copyItemAtPath(src, toPath: dest)
            Utils.debug("Copy \(src) -> \(dest)")
        }
        catch {
            print("Error: copying file \(src) to \(dest)")
            ok = false
        }
        
        return ok
    }
    
    public static func copyFiles(files: [String], useRoot: Bool,
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
            let destPath = (destFile as NSString).stringByDeletingLastPathComponent
            createFolder(destPath)
            if (copyFile(filePath, dest: destFile) == false) {
                exit(-1)
            }
        }
    }

    public static func deleteFile(src: String) -> Bool {
        var ok = true
        do {
            try NSFileManager.defaultManager().removeItemAtPath(src)
        }
        catch {
            ok = false
        }
        
        return ok
    }
    
}
