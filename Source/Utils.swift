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

}