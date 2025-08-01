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
import XCTest
@testable import RQESLib

final class PKCETests: XCTestCase {

    var pkceManager: PKCEManager!

    override func setUp() {
        super.setUp()
        pkceManager = PKCEManager()
    }

    override func tearDown() {
        pkceManager = nil
        super.tearDown()
    }

    func testGenerateCodeVerifier_IsAlwaysCorrectLength() async {
        for _ in 0..<100 {
            let verifier = await pkceManager.generateCodeVerifier()
            XCTAssertEqual(verifier.count, 43, "The code verifier must always be 43 characters long.")
        }
    }

    func testGenerateCodeVerifier_IsUnique() async {
        let verifier1 = await pkceManager.generateCodeVerifier()
        let verifier2 = await pkceManager.generateCodeVerifier()
        XCTAssertNotEqual(verifier1, verifier2, "Consecutively generated code verifiers should be unique.")
    }

    func testGenerateCodeVerifier_ContainsValidCharacters() async {
        let verifier = await pkceManager.generateCodeVerifier()
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        XCTAssertTrue(verifier.rangeOfCharacter(from: characterSet.inverted) == nil, "Verifier should only contain unreserved characters (alphanumeric, '-', '.', '_', '~'). Given the implementation, it should be alphanumeric and '0' padding.")
    }

    func testGenerateCodeChallenge_IsDeterministic() async {
        let verifier = "some_fixed_verifier_string_of_correct_length"
        let challenge1 = await pkceManager.generateCodeChallenge(from: verifier)
        let challenge2 = await pkceManager.generateCodeChallenge(from: verifier)
        XCTAssertEqual(challenge1, challenge2, "The code challenge must be deterministic for the same verifier.")
    }
    
    func testGenerateCodeChallenge_ProducesCorrectURLSafeBase64() async {
        let verifier = await pkceManager.generateCodeVerifier()
        let challenge = await pkceManager.generateCodeChallenge(from: verifier)
        
        XCTAssertFalse(challenge.contains("+"), "URL-safe Base64 should not contain '+'")
        XCTAssertFalse(challenge.contains("/"), "URL-safe Base64 should not contain '/'")
        XCTAssertFalse(challenge.contains("="), "URL-safe Base64 should not contain '=' padding")
    }

    func testInitializeAndGetCodeChallenge_ResetsAndGeneratesNewState() async throws {
        let pkceState = PKCEState.shared
        
        let challenge1 = try await pkceState.initializeAndGetCodeChallenge()
        let verifier1 = await pkceState.getVerifier()
        
        XCTAssertNotNil(verifier1, "Verifier should not be nil after initialization.")
        
        let challenge2 = try await pkceState.initializeAndGetCodeChallenge()
        let verifier2 = await pkceState.getVerifier()
        
        XCTAssertNotNil(verifier2, "Verifier should not be nil after second initialization.")
        
        XCTAssertNotEqual(verifier1, verifier2, "A new verifier should be generated on each initialization.")
        XCTAssertNotEqual(challenge1, challenge2, "A new challenge should be generated on each initialization.")
    }

    func testInitializeAndGetCodeChallenge_ProducesValidChallenge() async throws {
        let pkceState = PKCEState.shared
        
        let challengeFromState = try await pkceState.initializeAndGetCodeChallenge()
        
        guard let verifierFromState = await pkceState.getVerifier() else {
            XCTFail("Verifier should not be nil after initialization.")
            return
        }
        
        let manuallyGeneratedChallenge = await pkceManager.generateCodeChallenge(from: verifierFromState)
        
        XCTAssertEqual(challengeFromState, manuallyGeneratedChallenge, "The challenge from the state must correspond to its internal verifier.")
    }

    
    func testGetVerifier_ReturnsInitialStateAsNil() async {
        let pkceState = PKCEState.shared
        await pkceState.reset()
        
        let verifier = await pkceState.getVerifier()
        XCTAssertNil(verifier, "Initially, the verifier should be nil.")
    }

    func testPKCEStateIsSingleton() async throws {
        let state1 = PKCEState.shared
        let state2 = PKCEState.shared

        _ = try await state1.initializeAndGetCodeChallenge()
        let verifier1 = await state1.getVerifier()

        let verifier2 = await state2.getVerifier()

        XCTAssertNotNil(verifier1)
        XCTAssertEqual(verifier1, verifier2, "Both references should point to the same instance and share the same verifier state.")

        await state2.reset()
        let verifierAfterReset = await state1.getVerifier()
        XCTAssertNil(verifierAfterReset, "Resetting via one reference should clear the state for all references.")
    }
} 
