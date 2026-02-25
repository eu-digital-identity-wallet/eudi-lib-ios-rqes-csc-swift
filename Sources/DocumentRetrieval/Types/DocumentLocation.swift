/*
 * Copyright (c) 2023 European Commission
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
import SwiftyJSON

public struct DocumentLocation: Codable, Sendable {
    public let uri: String
    public let method: AccessMethod
    
    public init(uri: String, method: AccessMethod) {
        self.uri = uri
        self.method = method
    }
    
    init(json: JSON) {
        self.uri = json["uri"].stringValue
        self.method = AccessMethod(json: json["method"])
    }
}

public struct AccessMethod: Codable, Sendable {
    public let type: String
    
    public init(type: String) {
        self.type = type
    }
    
    public init(json: JSON) {
        self.type = json["type"].stringValue
    }
}

