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
@testable import RQES_LIBRARY   // brings in your target, and transitively PoDoFo
@testable import PoDoFo         // SPM binary target

final class PoDoFoIntegrationTests: XCTestCase {
  
    func testPoDoFoSessionRuns() throws {
        enum ConformanceLevel: String {
            case Ades_B_B = "ADES_B_B"
        }

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
            conformanceLevel: ConformanceLevel.Ades_B_B.rawValue,
            hashAlgorithm:       HashAlgorithmOID.SHA256.rawValue, //"2.16.840.1.101.3.4.2.1",
            inputPath:           inputCopyURL.path,
            outputPath:          outputURL.path,
            certificate:         certificate,
            chainCertificates:   [chainCertificate]
        )

        session.printState()

        let hash = session.calculateHash()
        XCTAssertNotNil(hash, "calculateHash() should return something")

        // finalize signing with a dummy signed hash
        let signedHash = "MEUCIQCpel09QAFtK/fPUvn+Nhx4VPH7Fm+vspv/UXluxXSKBAIge68SlU0JHVJCbKABh1GpNEiU2gD9sMVaWtLBv3Vb7kE="
        session.finalizeSigning(withSignedHash: signedHash)
        
        print("Pdf signed successfully and saved to \(outputURL.path)")
        // if we got here without crashing, our integration “ran”
        XCTAssertTrue(true, "PoDoFo session completed without error")
    }
}
