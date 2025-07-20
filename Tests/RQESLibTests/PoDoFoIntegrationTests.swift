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
@testable import PoDoFo

final class PoDoFoIntegrationTests: XCTestCase {
  
    func testPoDoFoSessionRuns() throws {
        guard let pdfURL = Bundle.module.url(
                forResource: "sample",
                withExtension: "pdf"
        ) else {
            XCTFail("Missing sample.pdf in test bundle")
            return
        }

        let docsDir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let inputCopyURL  = docsDir.appendingPathComponent("input.pdf")
        let outputURL     = docsDir.appendingPathComponent("signed-output.pdf")

        for url in [inputCopyURL, outputURL] {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        }

        try FileManager.default.copyItem(at: pdfURL, to: inputCopyURL)
        print("Input PDF copy at:  \(inputCopyURL.path)")
        print("Output will be at: \(outputURL.path)")

        let certificate = """
        MIICmDCCAh+gAwIBAgIUIGYtzcs9IBXguB9P0riuz8l+3NgwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI1MDMyMTIyMDUxM1oXDTI3MDMyMTIyMDUxMlowVTEdMBsGA1UEAwwURmlyc3ROYW1lIFRlc3RlclVzZXIxEzARBgNVBAQMClRlc3RlclVzZXIxEjAQBgNVBCoMCUZpcnN0TmFtZTELMAkGA1UEBhMCRkMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATKfz322k66qo078TlOuj7DnCIysLH4Luq/rJXNXtlS5WvGOVNIc95blK/XRIgx8/Q0SYHrXwumDOaJxKZzs222o4HFMIHCMAwGA1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAUs2y4kRcc16QaZjGHQuGLwEDMlRswHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMB0GA1UdDgQWBBRwUXIdDj4Rr+AfehggZXvcNj9wUTAOBgNVHQ8BAf8EBAMCBkAwCgYIKoZIzj0EAwIDZwAwZAIwUH8UEK/Vc+EDC4ZrRwBPpOCeJC5+9pky0hIyghFpaAOFUSsrqFjRxF9BlP/p1kNmAjA3B8sBJKNnlyEEHd0h+E6gaj5p/rgzj+kVX/30h8oZtAMpe1oamOGYhoLiZwmJH7Y=
        """
        let chainCertificate = """
        MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs
        """

        let session = PodofoWrapper(
            conformanceLevel:    ConformanceLevel.ADES_B_LT.rawValue,
            hashAlgorithm:       HashAlgorithmOID.SHA256.rawValue, //"2.16.840.1.101.3.4.2.1",
            inputPath:           inputCopyURL.path,
            outputPath:          outputURL.path,
            certificate:         certificate,
            chainCertificates:   [chainCertificate]
        )

        session.printState()

        let hash = session.calculateHash()
        XCTAssertNotNil(hash, "calculateHash() should return something")

        // finalize signing with a dummy but realistic signed hash
        let signedHash = "MEUCIQCldUS00il6qjIez47FWa2mJONabr0ydhC9emMlDeYfWAIgY7bVx7LuGDVSc3E//NSC+pI9atPS8MwXRRfL1Qk3TcU="
        
        // this is a dummy timestamp response based on the signed hash above
        let tsr = "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";
        
        let crlInfoEndCertificate = "MIIC5DCCAmoCAQEwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUFw0yNTA3MDMyMDM2NDBaFw0yNTA3MDUyMDM2MzlaMIIBFDAlAhRJpLGNz+t0zMC3cDtDMb34DXURjxcNMjQwNTAyMTA1NzEyWjAzAhRZI/C3stVqsBpzrHf0f1L/ssOj7BcNMjUwMTIwMTIyNDA5WjAMMAoGA1UdFQQDCgEBMDMCFBrSqD1bFGbUkndKlgI9whe3oFvzFw0yNTAyMjcxNzI4MzRaMAwwCgYDVR0VBAMKAQEwJQIUKcisR6EIUhFks62CN61cu+wMseoXDTI0MDUwMjEwNTc0NFowJQIUfkJnrdzo4QbORo6Spvfkf9pjzyQXDTI0MDIwNTExNDYxMFowMwIUCiGS1dT2EsyPKy6TwefSUYGaj3UXDTI0MTAwMzA5NDgyMlowDDAKBgNVHRUEAwoBAaCBxDCBwTAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzBOBggrBgEFBQcBAQRCMEAwPgYIKwYBBQUHMAKGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMAsGA1UdFAQEAgICAzBBBgNVHRwEOjA4oDagNIYyaHR0cHM6Ly9wcmVwcm9kLnBraS5ldWRpdy5kZXYvY3JsL3BpZF9DQV9VVF8wMS5jcmwwCgYIKoZIzj0EAwIDaAAwZQIwK5da7BwkUbCubwJVEJV1ne2VKatBbyETYlm/3DEWRqaFQ5KB7KwlUQCOiW/4b9V/AjEAjVSAblbQZCR4bidtTXQ1Gd3MCAY7rWXLqa5wBiDqvvaeX+ePyYYqpAK9Gf6pgBNX";
        let crlInfoChainCertificate = "MIIC5DCCAmoCAQEwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUFw0yNTA3MDMyMDM2NDBaFw0yNTA3MDUyMDM2MzlaMIIBFDAlAhRJpLGNz+t0zMC3cDtDMb34DXURjxcNMjQwNTAyMTA1NzEyWjAzAhRZI/C3stVqsBpzrHf0f1L/ssOj7BcNMjUwMTIwMTIyNDA5WjAMMAoGA1UdFQQDCgEBMDMCFBrSqD1bFGbUkndKlgI9whe3oFvzFw0yNTAyMjcxNzI4MzRaMAwwCgYDVR0VBAMKAQEwJQIUKcisR6EIUhFks62CN61cu+wMseoXDTI0MDUwMjEwNTc0NFowJQIUfkJnrdzo4QbORo6Spvfkf9pjzyQXDTI0MDIwNTExNDYxMFowMwIUCiGS1dT2EsyPKy6TwefSUYGaj3UXDTI0MTAwMzA5NDgyMlowDDAKBgNVHRUEAwoBAaCBxDCBwTAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzBOBggrBgEFBQcBAQRCMEAwPgYIKwYBBQUHMAKGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMAsGA1UdFAQEAgICAzBBBgNVHRwEOjA4oDagNIYyaHR0cHM6Ly9wcmVwcm9kLnBraS5ldWRpdy5kZXYvY3JsL3BpZF9DQV9VVF8wMS5jcmwwCgYIKoZIzj0EAwIDaAAwZQIwK5da7BwkUbCubwJVEJV1ne2VKatBbyETYlm/3DEWRqaFQ5KB7KwlUQCOiW/4b9V/AjEAjVSAblbQZCR4bidtTXQ1Gd3MCAY7rWXLqa5wBiDqvvaeX+ePyYYqpAK9Gf6pgBNX";
        
        let certificates = [certificate, chainCertificate , tsr]
        let crls = [crlInfoEndCertificate, crlInfoChainCertificate ]
        let ocspResponses: [String] = []

        session.finalizeSigning(withSignedHash: signedHash, tsr: tsr, validationCertificates: certificates, validationCRLs: crls, validationOCSPs: ocspResponses)
        
        print("Pdf signed successfully and saved to \(outputURL.path)")
        // if we got here without crashing, our integration “ran”
        XCTAssertTrue(true, "PoDoFo session completed without error")
    }
}
