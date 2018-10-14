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
import CoreFoundation

open class Shell
{
    static var plutilPath = "/usr/bin/plutil"
    static var gitPath = "/usr/bin/git"
    enum GitInstalled {
        case unset
        case installed
        case uninstalled
    }
    static var isGitInstalled:GitInstalled = .unset

    static func _shell(_ arguments: [String]) -> (output: String, status: Int32) {
        let task = Process()
        task.launchPath = "/bin/bash"
        var arg = ""
        for (index, value) in arguments.enumerated() {
            arg = arg + value
            if (index < (arguments.count - 1)) {
                arg = arg + " && "
            }
        }
        task.arguments = ["-c", arg]
        Utils.debug("$ \(arg)")
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        Thread.sleep(forTimeInterval: 1)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return (output: output, status: task.terminationStatus)
    }
    
    @discardableResult open static func gitInstalled() -> Bool {
        if (isGitInstalled == .unset) {
            let output = _shell(["which git"])
            isGitInstalled = (output.status == 0) ? .installed : .uninstalled

            gitPath = output.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return isGitInstalled == .installed
    }
    
    open static func gitInstalledPath() -> String {
        if gitInstalled() == false {
            Utils.error("Error: git not installed")
        }
        return gitPath
    }
    
    open static func gitCheckoutAtTag(_ path: String, tag: String) -> Bool {
        let output = _shell(["cd \(path)",
            "\(gitPath) checkout tags/\(tag)"])
        Utils.debug(output.output)
        return (output.status == 0)
    }

    @discardableResult open static func gitDropChanges(_ path: String) -> Bool {
        let output = _shell(["cd \(path)",
            "\(gitPath) stash -u", "\(gitPath) stash drop"])
        return (output.status == 0)
    }
    
    open static func gitResetHead(_ path: String, branch: String) -> Bool {
        let output = _shell(["cd \(path)",
            "\(gitPath) reset --hard origin/\(branch)"])
        return (output.status == 0)
    }
    
    open static func gitCurrentBranch(_ path: String) -> String {
        let output = _shell(["cd \(path)",
            "\(gitPath) rev-parse --abbrev-ref HEAD"])
        return output.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    open static func gitSetBranch(_ path: String, branch: String) -> Bool {
        gitDropChanges(path)
        let output = _shell(["cd \(path)",
            "\(gitPath) checkout \(branch)"])
        Utils.debug(output.output)
        return (output.status == 0)
    }

    open static func plint(_ file: String) -> Bool {
        let output = _shell(["\(plutilPath) -lint \(file)"])
        return (output.status == 0)
    }
    
    open static func setup() -> Void {
        gitInstalled()
    }
}

// eof

