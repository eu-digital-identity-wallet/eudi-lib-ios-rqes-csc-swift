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

public final actor PKCEState {
    public static let shared = PKCEState()
    
    private var codeVerifier: String?

    private init() {}

    public func initializeAndGetCodeChallenge() async throws -> String {
        await reset()
        
        await initializeCodeVerifier()

        guard let codeChallenge = await getCodeChallenge() else {
            throw NSError(domain: "PKCEError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate code challenge"])
        }
        return codeChallenge
    }

    public func reset() async {
        codeVerifier = nil
    }

    public func getVerifier() async -> String? {
        return codeVerifier
    }
    
    private func initializeCodeVerifier() async {
        codeVerifier = await PKCEManager().generateCodeVerifier()
    }
    
    private func getCodeChallenge() async -> String? {
        guard let verifier = codeVerifier else { return nil }
        return await PKCEManager().generateCodeChallenge(from: verifier)
    }
}