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

public func findOption(_ args:[String], option:String) -> Bool
{
    var found = false
    for argument in args {
        if (argument == option) {
            found = true
        }
    }
    return found
}

public func getOption(_ args:[String], option:String) -> String?
{
    var found:String? = nil
    for argument in args {
        if argument == option {
            if var indx = args.index(of: argument) {
                indx = indx + 1
                if indx < args.count {
                    found = args[indx]
                }
            }
            break
        }
    }
    return found
}

public func getOptions(_ args:[String], option:String) -> [String]?
{
    var found:[String]? = nil
    for argument in args {
        if (argument == option) {
            if var indx = args.index(of: argument) {
                indx = indx + 1
                found = []
                for dex in indx...(args.count - 1) {
                    let str = args[dex]
                    if (str.hasPrefix("-") == false) {
                        found?.append(str)
                    }
                    else {
                        break
                    }
                }
            }
            break
        }
    }
    return found
}

// MARK: main
let env = ProcessInfo.processInfo.environment
var args = CommandLine.arguments
args.removeFirst()

Utils.setVerbose(findOption(args, option: "-verbose"))

Shell.setup()

App().start(args)
exit(0)


// eof



