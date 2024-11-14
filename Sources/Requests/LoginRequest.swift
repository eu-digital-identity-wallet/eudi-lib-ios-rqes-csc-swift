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

public struct LoginRequest: Codable, Sendable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public func toFormData() -> (data: Data, boundary: String) {
        let boundary = UUID().uuidString
        var formData = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        formData.append(boundaryPrefix.data(using: .utf8)!)
        formData.append("Content-Disposition: form-data; name=\"username\"\r\n\r\n".data(using: .utf8)!)
        formData.append("\(username)\r\n".data(using: .utf8)!)
        
        formData.append(boundaryPrefix.data(using: .utf8)!)
        formData.append("Content-Disposition: form-data; name=\"password\"\r\n\r\n".data(using: .utf8)!)
        formData.append("\(password)\r\n".data(using: .utf8)!)
        
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return (formData, boundary)
    }
}
