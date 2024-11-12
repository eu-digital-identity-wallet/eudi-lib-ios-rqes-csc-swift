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
import CryptoKit

final actor PKCEManager {
    
    func generateCodeVerifier() -> String {
        var verifier = UUID().uuidString + UUID().uuidString
        verifier = verifier.replacingOccurrences(of: "-", with: "")
        
        if verifier.count > 43 {
            verifier = String(verifier.prefix(43))
        } else if verifier.count < 43 {
            verifier += String(repeating: "0", count: 43 - verifier.count)
        }
        
        return verifier
    }

    func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        
        return Data(hashed).base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
