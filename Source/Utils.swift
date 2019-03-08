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

open class Utils
{
    static var verbose = false

    public static func setVerbose(_ state: Bool) -> Void {
        verbose = state
    }

    public static func debug(_ message: String) -> Void {
        if (verbose) {
            print(message)
        }
    }

    public static func error(_ message: String) -> Void {
        print(message)
    }
    
    public static func always(_ message: String) -> Void {
        print(message)
    }

    public static func toJSON(_ dictionary:Dictionary<String, Any>) -> String? {
        do {
            var keys = JSONSerialization.WritingOptions.prettyPrinted
            if #available(OSX 10.13, *) {
                keys = [JSONSerialization.WritingOptions.sortedKeys, JSONSerialization.WritingOptions.prettyPrinted]
            }
            let data: Data = try JSONSerialization.data(withJSONObject: dictionary, options: keys)
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
    
    public static func fromJSONFile(_ file:String) -> [String:Any]? {
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
    
    public static func fromJSON(_ data:Data) -> [String: Any]? {
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

    public static func createFolders(_ folders: [String]) -> Bool {
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
    
    @discardableResult public static func createFolderForFile(_ srcFile: String) -> Bool {
        let destPath = (srcFile as NSString).deletingLastPathComponent
        return createFolder(destPath)
    }
    
    @discardableResult public static func createFolder(_ src: String) -> Bool {
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

    @discardableResult public static func deleteFolder(_ src: String) -> Bool {
        var ok = true
        do {
            try FileManager.default.removeItem(atPath: src)
        }
        catch {
            ok = false
        }
        
        return ok
    }

    public static func copyFile(_ src: String, dest: String) -> Bool {
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
    
    public static func copyFiles(_ files: [String], useRoot: Bool,
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

    @discardableResult public static func deleteFile(_ src: String) -> Bool {
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

