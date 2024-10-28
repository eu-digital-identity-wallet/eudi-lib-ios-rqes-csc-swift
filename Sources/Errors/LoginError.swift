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

public enum LoginError: LocalizedError {
    case emptyUsername
    case emptyPassword
    case invalidResponse
    case decodingFailed
    
    public var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "Username cannot be empty."
        case .emptyPassword:
            return "Password cannot be empty."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed:
            return "Failed to decode the response."
        }
    }
}
