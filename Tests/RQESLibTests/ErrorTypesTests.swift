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

class ErrorTypesTests: XCTestCase {

    func testCredentialsInfoErrorDescriptions() {
        let missingCredentialIDError = CredentialsInfoError.missingCredentialID
        let invalidCertificatesError = CredentialsInfoError.invalidCertificates
        
        XCTAssertEqual(
            missingCredentialIDError.errorDescription,
            "Missing or invalid 'credentialID' parameter. The 'credentialID' must be a valid string.",
            "Should provide meaningful error description for missing credential ID"
        )
        
        XCTAssertEqual(
            invalidCertificatesError.errorDescription,
            "Invalid 'certificates' parameter. The provided 'certificates' value is not valid.",
            "Should provide meaningful error description for invalid certificates"
        )
    }
    
    func testCredentialsInfoErrorEquality() {
        let error1 = CredentialsInfoError.missingCredentialID
        let error2 = CredentialsInfoError.missingCredentialID
        let error3 = CredentialsInfoError.invalidCertificates
        
        XCTAssertEqual(error1, error2, "Same error cases should be equal")
        XCTAssertNotEqual(error1, error3, "Different error cases should not be equal")
        XCTAssertNotEqual(error2, error3, "Different error cases should not be equal")
    }
    
    func testCredentialsInfoErrorAsLocalizedError() {
        let error: LocalizedError = CredentialsInfoError.missingCredentialID
        
        XCTAssertNotNil(error.errorDescription, "Should provide error description through LocalizedError protocol")
        XCTAssertEqual(
            error.errorDescription,
            "Missing or invalid 'credentialID' parameter. The 'credentialID' must be a valid string."
        )
    }

    func testCredentialsListErrorDescription() {
        let invalidClientIDError = CredentialsListError.invalidClientID
        
        XCTAssertEqual(
            invalidClientIDError.errorDescription,
            "The client ID provided is invalid.",
            "Should provide meaningful error description for invalid client ID"
        )
    }
    
    func testCredentialsListErrorEquality() {
        let error1 = CredentialsListError.invalidClientID
        let error2 = CredentialsListError.invalidClientID
        
        XCTAssertEqual(error1, error2, "Same error cases should be equal")
    }
    
    func testCredentialsListErrorAsLocalizedError() {
        let error: LocalizedError = CredentialsListError.invalidClientID
        
        XCTAssertNotNil(error.errorDescription, "Should provide error description through LocalizedError protocol")
        XCTAssertEqual(error.errorDescription, "The client ID provided is invalid.")
    }
    
    func testErrorTypesAreDifferent() {
        let credentialsInfoError: Error = CredentialsInfoError.missingCredentialID
        let credentialsListError: Error = CredentialsListError.invalidClientID
        
        XCTAssertFalse(credentialsInfoError is CredentialsListError, "CredentialsInfoError should not be CredentialsListError")
        XCTAssertFalse(credentialsListError is CredentialsInfoError, "CredentialsListError should not be CredentialsInfoError")
        
        XCTAssertTrue(credentialsInfoError is CredentialsInfoError, "Should correctly identify CredentialsInfoError")
        XCTAssertTrue(credentialsListError is CredentialsListError, "Should correctly identify CredentialsListError")
    }

    func testErrorHandlingPatterns() {
        let errors: [Error] = [
            CredentialsInfoError.missingCredentialID,
            CredentialsInfoError.invalidCertificates,
            CredentialsListError.invalidClientID
        ]
        
        for error in errors {
            if let localizedError = error as? LocalizedError {
                XCTAssertNotNil(localizedError.errorDescription, "All errors should provide descriptions")
                XCTAssertFalse(localizedError.errorDescription?.isEmpty == true, "Error descriptions should not be empty")
            } else {
                XCTFail("All custom errors should conform to LocalizedError")
            }

            switch error {
            case is CredentialsInfoError:
                XCTAssertTrue(error is CredentialsInfoError, "Should correctly identify CredentialsInfoError in switch")
            case is CredentialsListError:
                XCTAssertTrue(error is CredentialsListError, "Should correctly identify CredentialsListError in switch")
            default:
                XCTFail("Unrecognized error type: \(type(of: error))")
            }
        }
    }

    func testErrorCaseExhaustiveness() {
        let allCredentialsInfoErrors: [CredentialsInfoError] = [
            .missingCredentialID,
            .invalidCertificates
        ]
        
        for error in allCredentialsInfoErrors {
            XCTAssertNotNil(error.errorDescription, "All CredentialsInfoError cases should have descriptions")
        }

        let allCredentialsListErrors: [CredentialsListError] = [
            .invalidClientID
        ]
        
        for error in allCredentialsListErrors {
            XCTAssertNotNil(error.errorDescription, "All CredentialsListError cases should have descriptions")
        }
    }
} 
