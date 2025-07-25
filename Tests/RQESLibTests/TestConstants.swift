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
@testable import RQESLib

struct TimestampTestConstants {
    
    struct Hashes {
        static let validSignedHash = "SGVsbG8gV29ybGQ="
        static let invalidSignedHash = "InvalidBase64!@#"
        static let realisticSignedHash = "MEUCIQCpel09QAFtK/fPUvn+Nhx4VPH7Fm+vspv/UXluxXSKBAIge68SlU0JHVJCbKABh1GpNEiU2gD9sMVaWtLBv3Vb7kE="
        
        static let testCases = [
            "SGVsbG8gV29ybGQ=",
            "U29tZVRlc3REYXRh",
            "VGVzdFN0cmluZw==",
            "MTIzNDU2Nzg5MA=="
        ]
    }
    
    struct URLs {
        static let tsaUrl = "https://mock-tsa.example.com/timestamp"
        static let invalidTsaUrl = "invalid-url"
        static let unreachableTsaUrl = "https://unreachable-tsa-server.com/timestamp"
    }
    
    struct TestData {
        static let testDataString = "Test data for timestamping"
        static let largeDataByte: UInt8 = 0x42
        static let largeDataSize = 1000
    }
    
    struct MockResponses {
        static let validTimestampResponse = "MIIBhAYJKoZIhvcNAQcCoIIBdTCCAXECAQMxDzANBglghkgBZQMEAgEFADB8BgsqhkiG9w0BCRABBKB".data(using: .utf8)!
        static let largeTimestampResponse = String(repeating: "MOCK_TSA_RESPONSE_", count: 50).data(using: .utf8)!
        static let emptyTimestampResponse = Data()
    }
}

struct PoDoFoTestConstants {
    
    struct Certificates {
        static let endEntityCertificate = """
        MIICmDCCAh+gAwIBAgIUIGYtzcs9IBXguB9P0riuz8l+3NgwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI1MDMyMTIyMDUxM1oXDTI3MDMyMTIyMDUxMlowVTEdMBsGA1UEAwwURmlyc3ROYW1lIFRlc3RlclVzZXIxEzARBgNVBAQMClRlc3RlclVzZXIxEjAQBgNVBCoMCUZpcnN0TmFtZTELMAkGA1UEBhMCRkMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATKfz322k66qo078TlOuj7DnCIysLH4Luq/rJXNXtlS5WvGOVNIc95blK/XRIgx8/Q0SYHrXwumDOaJxKZzs222o4HFMIHCMAwGA1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAUs2y4kRcc16QaZjGHQuGLwEDMlRswHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMB0GA1UdDgQWBBRwUXIdDj4Rr+AfehggZXvcNj9wUTAOBgNVHQ8BAf8EBAMCBkAwCgYIKoZIzj0EAwIDZwAwZAIwUH8UEK/Vc+EDC4ZrRwBPpOCeJC5+9pky0hIyghFpaAOFUSsrqFjRxF9BlP/p1kNmAjA3B8sBJKNnlyEEHd0h+E6gaj5p/rgzj+kVX/30h8oZtAMpe1oamOGYhoLiZwmJH7Y=
        """
        
        static let chainCertificate = """
        MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBQTBLzLa/9SGEBVXh88MmEeRCq9FTBLBggrBgEFBQcBAQQ/MD0wOwYIKwYBBQUHMAGGL2h0dHA6Ly9vY3NwLmFzYy5jYXJ0YW9kZWNpZGFkYW8ucHQvcHVibGljby9vY3NwMG8GA1UdLgRoMGYwZKBioGCGXmh0dHA6Ly9wa2kuY2FydGFvZGVjaWRhZGFvLnB0L3B1YmxpY28vbHJjL2NjX3N1Yi1lY19jaWRhZGFvX2Fzc2luYXR1cmFfY3JsMDAxOF9kZWx0YV9wMDAyMC5jcmwwgboGA1UdIASBsjCBrzBVBgtghGwBAQECBAABBzBGMEQGCCsGAQUFBwIBFjhodHRwczovL3BraS5jYXJ0YW9kZWNpZGFkYW8ucHQvcHVibGljby9wb2xpdGljYXMvY3AuaHRtbDBWBgtghGwBAQECBAEABzBHMEUGCCsGAQUFBwIBFjlodHRwczovL3BraS5jYXJ0YW9kZWNpZGFkYW8ucHQvcHVibGljby9wb2xpdGljYXMvY3BzLmh0bWwwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwgcYGCCsGAQUFBwEDBIG5MIG2MIGzBgcEAIGXXgEBDIGnQnkgaW5jbHVzaW9uIG9mIHRoaXMgc3RhdGVtZW50IHRoZSBpc3N1ZXIgY2xhaW1zIHRoYXQgdGhpcyB0aW1lLXN0YW1wIHRva2VuIGlzIGlzc3VlZCBhcyBhIHF1YWxpZmllZCBlbGVjdHJvbmljIHRpbWUtc3RhbXAgYWNjb3JkaW5nIHRvIHRoZSBSRUdVTEFUSU9OIChFVSkgTm8gOTEwLzIwMTQwaQYDVR0fBGIwYDBeoFygWoZYaHR0cDovL3BraS5jYXJ0YW9kZWNpZGFkYW8ucHQvcHVibGljby9scmMvY2Nfc3ViLWVjX2NpZGFkYW9fYXNzaW5hdHVyYV9jcmwwMDE4X3AwMDIwLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"
            ],
            "validFrom" : "20250321220513Z",
            "validTo" : "20270321220512Z",
            "subjectDN" : "C=FC, GIVENNAME=FirstName, SURNAME=TesterUser, CN=FirstName TesterUser",
            "status" : "valid",
            "issuerDN" : "C=UT, O=EUDI Wallet Reference Implementation, CN=PID Issuer CA - UT 01"
          },
          "signatureQualifier" : "eu_eidas_qes",
          "description" : "This is a credential for tests",
          "multisign" : 1,
          "key" : {
            "status" : "enabled",
            "curve" : "1.2.840.10045.3.1.7",
            "algo" : [
              "1.2.840.10045.2.1",
              "1.2.840.10045.4.3.2"
            ],
            "len" : 256
          },
          "lang" : "en-US"
        }
        ],
        "onlyValid" : false,
        "credentialIDs" : [
        "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85"
        ]
        }
        """
    }
    
    struct SigningData {
        static let signedHash = "MEUCIQCpel09QAFtK/fPUvn+Nhx4VPH7Fm+vspv/UXluxXSKBAIge68SlU0JHVJCbKABh1GpNEiU2gD9sMVaWtLBv3Vb7kE="
        
        static let timestampResponse = """
        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"
        """
    }
    
    struct Configuration {
        static let conformanceLevel = ConformanceLevel.ADES_B_T.rawValue
        static let hashAlgorithm = HashAlgorithmOID.SHA256.rawValue
        static let numberOfConcurrentRequests = 5
    }
}

struct FileTestConstants {
    
    struct Paths {
        static let samplePDFName = "sample"
        static let samplePDFExtension = "pdf"
        static let samplePDFFullName = "sample.pdf"
        static let inputPDFName = "input.pdf"
        static let outputPDFName = "signed-output.pdf"
        static let nonExistentFileName = "nonexistent.pdf"
        static let testOutputFile = "test-output.pdf"
        static let emptyFileName = ""
        static let invalidFileName = "///invalid///.pdf"
    }
    
    struct Directories {
        static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    struct TestData {
        static let sampleBase64 = "SGVsbG8gV29ybGQh"
        static let binaryData = Data([0x48, 0x65, 0x6C, 0x6C, 0x6F])
        static let largeBase64 = String(repeating: "QQ==", count: 1000)
        static let malformedBase64 = "Invalid-Base64!@#"
        static let emptyBase64 = ""
        static let validPDFBase64 = "JVBERi0xLjQKJcOkw7zDssOgCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0ZpbHRlci9GbGF0ZURlY29kZT4+CnN0cmVhbQp4nCvkMlAwtU0rSUxOLXL3LdBNySxJLVIwUDC2NbGwsBUwyEwuyU9VyC4qTS0pTk1VyE4tjk8sKs7ILy7RLSgtNtVtAQBaERdCCmVuZHN0cmVhbQplbmRvYmoKCjMgMCBvYmoKNTMKZW5kb2JqCgo0IDAgb2JqCjw8L1R5cGUvQ2F0YWxvZy9QYWdlcyAxIDAgUj4+CmVuZG9iagoKNSAwIG9iago8PC9UeXBlL1Jlc291cmNlRGljdGlvbmFyeS9Gb250PDwvRjEgNiAwIFI+Pj4KZW5kb2JqCgoKNiAwIG9iago8PC9UeXBlL0ZvbnQvU3VidHlwZS9UeXBlMS9CYXNlRm9udC9UaW1lcy1Sb21hbj4+CmVuZG9iagoKMSAwIG9iago8PC9UeXBlL1BhZ2VzL0NvdW50IDEvS2lkc1s3IDAgUl0+PgplbmRvYmoKCjcgMCBvYmoKPDwvVHlwZS9QYWdlL1BhcmVudCAxIDAgUi9SZXNvdXJjZXMgNSAwIFIvTWVkaWFCb3hbMCAwIDU5NSA4NDJdL0NvbnRlbnRzIDIgMCBSPj4KZW5kb2JqCgp4cmVmCjAgOAowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAyNzUgMDAwMDAgbiAKMDAwMDAwMDAwOSAwMDAwMCBuIAowMDAwMDAwMTI3IDAwMDAwIG4gCjAwMDAwMDAxNDYgMDAwMDAgbiAKMDAwMDAwMDE5MyAwMDAwMCBuIAowMDAwMDAyMjUzIDAwMDAwIG4gCjAwMDAwMDAzMDIgMDAwMDAgbiAKdHJhaWxlcgo8PC9TaXplIDgvUm9vdCA0IDAgUj4+CnN0YXJ0eHJlZgozOTcKJSVFT0Y="
        static let smallBinaryData = Data([0x01, 0x02, 0x03, 0x04])
        static let largeBinaryData = Data(repeating: 0xAB, count: 10000)
    }
    
    struct JSONData {
        static let validJSONString = """
        {
            "name": "Test User",
            "age": 30,
            "active": true
        }
        """
        static let invalidJSONString = "{ invalid json }"
        static let complexJSONString = """
        {
            "array": [1, 2, 3],
            "nested": {
                "value": "test"
            },
            "null_field": null
        }
        """
    }
    
    struct URLs {
        static let baseURL = "https://example.com"
        static let endpointPath = "/api/v1/test"
        static let malformedBase = "invalid-url"
        static let complexEndpoint = "/api/v1/users/123/details"
    }
}

struct SignHashTestConstants {
    
    struct Requests {
        static let validSignHashRequest = SignHashRequest(
            credentialID: "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
            hashes: ["gA6NvbA7MA5BwMOG7KPcM7kA74Xd1OrdoM6A9AoRlAqH9MEbNyTNGbox6T3fc8kcHITYsKkA8KLcZmkTimg3DK3D"],
            hashAlgorithmOID: .SHA256,
            signAlgo: .ECDSA,
            operationMode: "S"
        )
        
        static let multipleHashesRequest = SignHashRequest(
            credentialID: "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
            hashes: [
                "gA6NvbA7MA5BwMOG7KPcM7kA74Xd1OrdoM6A9AoRlAqH9MEbNyTNGbox6T3fc8kcHITYsKkA8KLcZmkTimg3DK3D",
                "bB7OvcB8NB6CxNPH8LQdN8lB85Ye2PseqN7B0BpSmBrI0NFcOzUOHcpwy4gd9dlcIJUZtLlB9LMdanzUjnh4EL4E"
            ],
            hashAlgorithmOID: .SHA256,
            signAlgo: .ECDSA,
            operationMode: "S"
        )
    }
    
    struct Responses {
        static let validSignHashResponse = SignHashResponse(
            signatures: ["MEUCIQAssqE1K+gIofKPQGL3ejPmPbMn9fKSGTXfW0Rde546yAiEAg1Yaj25jbdbzIlf9MfNiJ/vPiK0Gi4uPC3CVsxy7Fiw="]
        )
        
        static let multipleSignaturesResponse = SignHashResponse(
            signatures: [
                "MEUCIQAssqE1K+gIofKPQGL3ejPmPbMn9fKSGTXfW0Rde546yAiEAg1Yaj25jbdbzIlf9MfNiJ/vPiK0Gi4uPC3CVsxy7Fiw=",
                "MEQCIFa9T+KJf8QLA0mNw3W9YGLqzf2HvBNw3M4fQLrB6f7NAiBG8XbVzGmPFjH4vKEe9WJHqKwQ5LkYQF4hGZ8vQcRzLw=="
            ]
        )
    }
    
    struct URLs {
        static let rsspUrl = "https://mock-rssp.example.com"
        static let signHashEndpoint = "/signatures/signHash"
        static let fullSignHashUrl = "https://mock-rssp.example.com/signatures/signHash"
        static let invalidRsspUrl = "invalid-url"
    }
    
    struct AccessTokens {
        static let validAccessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        static let expiredAccessToken = "expired.token.here"
        static let malformedAccessToken = "not-a-valid-token"
    }
    
    struct MockResponses {
        static func createValidSignHashResponseJSON() -> String {
            return """
            {
              "signatures": [
                "MEUCIQAssqE1K+gIofKPQGL3ejPmPbMn9fKSGTXfW0Rde546yAiEAg1Yaj25jbdbzIlf9MfNiJ/vPiK0Gi4uPC3CVsxy7Fiw="
              ]
            }
            """
        }
        
        static func createMultipleSignaturesResponseJSON() -> String {
            return """
            {
              "signatures": [
                "MEUCIQAssqE1K+gIofKPQGL3ejPmPbMn9fKSGTXfW0Rde546yAiEAg1Yaj25jbdbzIlf9MfNiJ/vPiK0Gi4uPC3CVsxy7Fiw=",
                "MEQCIFa9T+KJf8QLA0mNw3W9YGLqzf2HvBNw3M4fQLrB6f7NAiBG8XbVzGmPFjH4vKEe9WJHqKwQ5LkYQF4hGZ8vQcRzLw=="
              ]
            }
            """
        }
        
        static func createErrorResponseJSON() -> String {
            return """
            {
              "error": "invalid_request",
              "error_description": "The credential ID is not valid or has been revoked"
            }
            """
        }
    }
} 

struct TestConstants {
    static let rsspUrl = "https://mock-rssp.example.com"

    static let standardCredentialsListRequest = CredentialsListRequest(
        userID: nil,
        credentialInfo: true,
        certificates: "chain",
        certInfo: true,
        authInfo: nil,
        onlyValid: nil,
        lang: nil,
        clientData: nil
    )
    
    static let minimalCredentialsListRequest = CredentialsListRequest(
        userID: nil,
        credentialInfo: false,
        certificates: "single",
        certInfo: false,
        authInfo: nil,
        onlyValid: nil,
        lang: nil,
        clientData: nil
    )

    static let standardCredentialsInfoRequest = CredentialsInfoRequest(
        credentialID: "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
        certificates: "chain",
        certInfo: true,
        authInfo: true,
        lang: nil,
        clientData: nil
    )
    
    static let minimalCredentialsInfoRequest = CredentialsInfoRequest(
        credentialID: "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
        certificates: "single",
        certInfo: false,
        authInfo: false,
        lang: "en-US",
        clientData: nil
    )

    static let serverResponseCredentialsInfoRequest = """
    {
      "credentialID": "server-credential-456",
      "certificates": "chain",
      "certInfo": true,
      "auth_info": false,
      "lang": "de-DE",
      "client_data": "server-data"
    }
    """
    
    static let credentialsListResponse = """
    {
      "credentialInfos" : [
        {
          "credentialID" : "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
          "cert" : {
            "serialNumber" : "184966370757515800362535864175063713398032096472",
            "certificates" : [
              "MIICmDCCAh+gAwIBAgIUIGYtzcs9IBXguB9P0riuz8l+3NgwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI1MDMyMTIyMDUxM1oXDTI3MDMyMTIyMDUxMlowVTEdMBsGA1UEAwwURmlyc3ROYW1lIFRlc3RlclVzZXIxEzARBgNVBAQMClRlc3RlclVzZXIxEjAQBgNVBCoMCUZpcnN0TmFtZTELMAkGA1UEBhMCRkMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATKfz322k66qo078TlOuj7DnCIysLH4Luq\\/rJXNXtlS5WvGOVNIc95blK\\/XRIgx8\\/Q0SYHrXwumDOaJxKZzs222o4HFMIHCMAwGA1UdEwEB\\/wQCMAAwHwYDVR0jBBgwFoAUs2y4kRcc16QaZjGHQuGLwEDMlRswHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMB0GA1UdDgQWBBRwUXIdDj4Rr+AfehggZXvcNj9wUTAOBgNVHQ8BAf8EBAMCBkAwCgYIKoZIzj0EAwIDZwAwZAIwUH8UEK\\/Vc+EDC4ZrRwBPpOCeJC5+9pky0hIyghFpaAOFUSsrqFjRxF9BlP\\/p1kNmAjA3B8sBJKNnlyEEHd0h+E6gaj5p\\/rgzj+kVX\\/30h8oZtAMpe1oamOGYhoLiZwmJH7Y=",
              "MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R\\/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X\\/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH\\/BAgwBgEB\\/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH\\/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl\\/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"
            ],
            "validFrom" : "20250321220513Z",
            "validTo" : "20270321220512Z",
            "subjectDN" : "C=FC, GIVENNAME=FirstName, SURNAME=TesterUser, CN=FirstName TesterUser",
            "status" : "valid",
            "issuerDN" : "C=UT, O=EUDI Wallet Reference Implementation, CN=PID Issuer CA - UT 01"
          },
          "signatureQualifier" : "eu_eidas_qes",
          "description" : "This is a credential for tests",
          "multisign" : 1,
          "key" : {
            "status" : "enabled",
            "curve" : "1.2.840.10045.3.1.7",
            "algo" : [
              "1.2.840.10045.2.1",
              "1.2.840.10045.4.3.2"
            ],
            "len" : 256
          },
          "lang" : "en-US"
        }
      ],
      "onlyValid" : false,
      "credentialIDs" : [
        "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85"
      ]
    }
    """
    
    static let credentialsInfoResponse = """
    {
      "signatureQualifier" : "eu_eidas_qes",
      "description" : "This is a credential for tests",
      "lang" : "en-US",
      "key" : {
        "status" : "enabled",
        "curve" : "1.2.840.10045.3.1.7",
        "algo" : [
          "1.2.840.10045.2.1",
          "1.2.840.10045.4.3.2"
        ],
        "len" : 256
      },
      "multisign" : 1,
      "cert" : {
        "validFrom" : "20250321220513Z",
        "serialNumber" : "184966370757515800362535864175063713398032096472",
        "subjectDN" : "C=FC, GIVENNAME=FirstName, SURNAME=TesterUser, CN=FirstName TesterUser",
        "validTo" : "20270321220512Z",
        "certificates" : [
          "MIICmDCCAh+gAwIBAgIUIGYtzcs9IBXguB9P0riuz8l+3NgwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxLS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI1MDMyMTIyMDUxM1oXDTI3MDMyMTIyMDUxMlowVTEdMBsGA1UEAwwURmlyc3ROYW1lIFRlc3RlclVzZXIxEzARBgNVBAQMClRlc3RlclVzZXIxEjAQBgNVBCoMCUZpcnN0TmFtZTELMAkGA1UEBhMCRkMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATKfz322k66qo078TlOuj7DnCIysLH4Luq\\/rJXNXtlS5WvGOVNIc95blK\\/XRIgx8\\/Q0SYHrXwumDOaJxKZzs222o4HFMIHCMAwGA1UdEwEB\\/wQCMAAwHwYDVR0jBBgwFoAUs2y4kRcc16QaZjGHQuGLwEDMlRswHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMB0GA1UdDgQWBBRwUXIdDj4Rr+AfehggZXvcNj9wUTAOBgNVHQ8BAf8EBAMCBkAwCgYIKoZIzj0EAwIDZwAwZAIwUH8UEK\\/Vc+EDC4ZrRwBPpOCeJC5+9pky0hIyghFpaAOFUSsrqFjRxF9BlP\\/p1kNmAjA3B8sBJKNnlyEEHd0h+E6gaj5p\\/rgzj+kVX\\/30h8oZtAMpe1oamOGYhoLiZwmJH7Y=",
          "MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R\\/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X\\/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH\\/BAgwBgEB\\/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH\\/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1ymUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl\\/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"
        ],
        "issuerDN" : "C=UT, O=EUDI Wallet Reference Implementation, CN=PID Issuer CA - UT 01",
        "status" : "valid"
      }
    }
    """

    static let completeCredentialInfoResponse = """
    {
      "description" : "Complete test credential",
      "signatureQualifier" : "eu_eidas_qes",
      "multisign" : 5,
      "lang" : "en-US",
      "scal" : "1",
      "key" : {
        "status" : "enabled",
        "algo" : ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"],
        "len" : 256,
        "curve" : "1.2.840.10045.3.1.7"
      },
      "cert" : {
        "status" : "valid",
        "certificates" : ["MIICmDCCAh+...cert1", "MIIDHTCCAqO...cert2"],
        "issuerDN" : "C=UT, O=Test CA, CN=Test Issuer",
        "serialNumber" : "123456789012345",
        "subjectDN" : "C=US, CN=John Doe, O=Test Org",
        "validFrom" : "20240101000000Z",
        "validTo" : "20251231235959Z"
      },
      "auth" : {
        "mode" : "explicit",
        "expression" : "PIN",
        "objects" : [
          {
            "type" : "PIN",
            "id" : "pin-id-1",
            "format" : "N",
            "label" : "Enter PIN",
            "description" : "6-digit PIN"
          }
        ]
      }
    }
    """
    
    static let minimalCredentialInfoResponse = """
    {
      "multisign" : 1,
      "key" : {
        "status" : "enabled",
        "algo" : ["1.2.840.10045.2.1"],
        "len" : 256
      }
    }
    """
    
    static let multipleAuthObjectsCredentialInfoResponse = """
    {
      "multisign" : 1,
      "key" : {
        "status" : "enabled",
        "algo" : ["1.2.840.10045.2.1"],
        "len" : 256
      },
      "auth" : {
        "mode" : "implicit",
        "expression" : "PIN || BIOMETRIC",
        "objects" : [
          {
            "type" : "PIN",
            "id" : "pin-primary",
            "format" : "N",
            "label" : "Primary PIN",
            "description" : "Main authentication PIN"
          },
          {
            "type" : "BIOMETRIC",
            "id" : "bio-fingerprint",
            "format" : "B",
            "label" : "Fingerprint",
            "description" : "Fingerprint scan"
          }
        ]
      }
    }
    """

    static let keyVariations = [
        ("""
        {"status": "enabled", "algo": ["1.2.840.10045.2.1"], "len": 256}
        """, 1),
        
        ("""
        {"status": "enabled", "algo": ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2", "1.2.840.10045.4.3.3"], "len": 384}
        """, 3),
        
        ("""
        {"status": "disabled", "algo": ["1.2.840.10045.2.1"], "len": 521}
        """, 1)
    ]

    static let invalidCredentialInfoJsons = [
        """
        {
          "multisign" : 1
        }
        """,
        """
        {
          "key" : {
            "status" : "enabled",
            "algo" : ["1.2.840.10045.2.1"],
            "len" : 256
          }
        }
        """,
        """
        {
          "multisign" : 1,
          "key" : {
            "algo" : ["1.2.840.10045.2.1"],
            "len" : 256
          }
        }
        """,
        """
        {
          "multisign" : 1,
          "key" : {
            "status" : "enabled",
            "len" : 256
          }
        }
        """,
        """
        {
          "multisign" : 1,
          "key" : {
            "status" : "enabled",
            "algo" : ["1.2.840.10045.2.1"]
          }
        }
        """
    ]
    static let completeCredentialsListResponse = """
    {
      "credentialInfos" : [
        {
          "credentialID" : "test-credential-123",
          "cert" : {
            "serialNumber" : "123456789",
            "certificates" : ["cert1", "cert2"],
            "validFrom" : "20240101000000Z",
            "validTo" : "20251231235959Z",
            "subjectDN" : "C=US, CN=Test User",
            "status" : "valid",
            "issuerDN" : "C=US, O=Test CA"
          },
          "signatureQualifier" : "eu_eidas_qes",
          "description" : "Test credential",
          "multisign" : 5,
          "key" : {
            "status" : "enabled",
            "curve" : "1.2.840.10045.3.1.7",
            "algo" : ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"],
            "len" : 256
          },
          "lang" : "en-US"
        }
      ],
      "onlyValid" : true,
      "credentialIDs" : ["test-credential-123"]
    }
    """
    
    static let emptyCredentialsListResponse = """
    {
      "credentialInfos" : [],
      "onlyValid" : false,
      "credentialIDs" : []
    }
    """
    
    static let multipleCredentialsListResponse = """
    {
      "credentialInfos" : [
        {
          "credentialID" : "cred-1",
          "cert" : {
            "serialNumber" : "111",
            "certificates" : ["cert1"],
            "validFrom" : "20240101000000Z",
            "validTo" : "20251231235959Z",
            "subjectDN" : "C=US, CN=User 1",
            "status" : "valid",
            "issuerDN" : "C=US, O=CA 1"
          },
          "signatureQualifier" : "eu_eidas_qes",
          "multisign" : 1,
          "key" : {
            "status" : "enabled",
            "algo" : ["1.2.840.10045.2.1"],
            "len" : 256
          }
        },
        {
          "credentialID" : "cred-2",
          "cert" : {
            "serialNumber" : "222",
            "certificates" : ["cert2"],
            "validFrom" : "20240101000000Z",
            "validTo" : "20251231235959Z",
            "subjectDN" : "C=US, CN=User 2",
            "status" : "valid",
            "issuerDN" : "C=US, O=CA 2"
          },
          "signatureQualifier" : "eu_eidas_ades",
          "multisign" : 3,
          "key" : {
            "status" : "enabled",
            "algo" : ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"],
            "len" : 256
          }
        }
      ],
      "onlyValid" : true,
      "credentialIDs" : ["cred-1", "cred-2"]
    }
    """
    
    static let minimalCredentialsListResponse = """
    {
      "credentialInfos" : [
        {
          "credentialID" : "minimal-cred",
          "cert" : {
            "serialNumber" : "999",
            "certificates" : [],
            "validFrom" : "20240101000000Z",
            "validTo" : "20251231235959Z",
            "subjectDN" : "C=US, CN=Minimal User",
            "status" : "valid",
            "issuerDN" : "C=US, O=Minimal CA"
          },
          "key" : {
            "status" : "enabled",
            "algo" : ["1.2.840.10045.2.1"],
            "len" : 256
          }
        }
      ],
      "credentialIDs" : ["minimal-cred"]
    }
    """
    
    static let nullCredentialInfosResponse = """
    {
      "credentialInfos" : null,
      "onlyValid" : false,
      "credentialIDs" : ["id-without-info"]
    }
    """

    static let invalidCredentialsListJsons = [
        """
        {
          "credentialInfos" : [],
          "onlyValid" : false
        }
        """,
        """
        {
          "credentialInfos" : [
            {
              "credentialID" : "invalid-cred",
              "key" : {
                "status" : "enabled",
                "algo" : ["1.2.840.10045.2.1"],
                "len" : 256
              }
            }
          ],
          "credentialIDs" : ["invalid-cred"]
        }
        """,
        """
        {
          "credentialInfos" : [
            {
              "credentialID" : "invalid-cred",
              "cert" : {
                "serialNumber" : "999",
                "certificates" : [],
                "validFrom" : "20240101000000Z",
                "validTo" : "20251231235959Z",
                "subjectDN" : "C=US, CN=User",
                "status" : "valid",
                "issuerDN" : "C=US, O=CA"
              }
            }
          ],
          "credentialIDs" : ["invalid-cred"]
        }
        """
    ]

    static let emptyCredentialsListResponseForService = """
    {
      "credentialInfos": [],
      "onlyValid": true,
      "credentialIDs": []
    }
    """
    
    static let multipleCredentialsResponseForService = """
    {
      "credentialInfos" : [
        {
          "credentialID" : "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
          "cert" : {
            "serialNumber" : "184966370757515800362535864175063713398032096472",
            "certificates" : ["cert1"],
            "validFrom" : "20250321220513Z",
            "validTo" : "20270321220512Z",
            "subjectDN" : "C=FC, CN=First User",
            "status" : "valid",
            "issuerDN" : "C=UT, O=Test CA"
          },
          "signatureQualifier" : "eu_eidas_qes",
          "description" : "First credential",
          "multisign" : 1,
          "key" : {
            "status" : "enabled",
            "curve" : "1.2.840.10045.3.1.7",
            "algo" : ["1.2.840.10045.2.1"],
            "len" : 256
          },
          "lang" : "en-US"
        },
        {
          "credentialID" : "another-credential-id",
          "cert" : {
            "serialNumber" : "987654321",
            "certificates" : ["cert2"],
            "validFrom" : "20240101000000Z",
            "validTo" : "20250101000000Z",
            "subjectDN" : "C=ES, CN=Second User",
            "status" : "valid",
            "issuerDN" : "C=ES, O=Another CA"
          },
          "signatureQualifier" : "eu_eidas_ades",
          "description" : "Second credential",
          "multisign" : 5,
          "key" : {
            "status" : "enabled",
            "curve" : "1.2.840.10045.3.1.7",
            "algo" : ["1.2.840.10045.2.1", "1.2.840.10045.4.3.2"],
            "len" : 256
          },
          "lang" : "es-ES"
        }
      ],
      "onlyValid" : false,
      "credentialIDs" : [
        "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
        "another-credential-id"
      ]
    }
    """

    static func credentialsListResponseWithSignatureQualifier(_ qualifier: String) -> String {
        return """
        {
          "credentialInfos" : [
            {
              "credentialID" : "test-cred",
              "cert" : {
                "serialNumber" : "123",
                "certificates" : [],
                "validFrom" : "20240101000000Z",
                "validTo" : "20251231235959Z",
                "subjectDN" : "C=US, CN=User",
                "status" : "valid",
                "issuerDN" : "C=US, O=CA"
              },
              "signatureQualifier" : "\(qualifier)",
              "key" : {
                "status" : "enabled",
                "algo" : ["1.2.840.10045.2.1"],
                "len" : 256
              }
            }
          ],
          "credentialIDs" : ["test-cred"]
        }
        """
    }

    static let calculateHashRequest = """
    {
      "endEntityCertificate" : "MIICmDCCAh+gAwIBAgIUIGYtzcs9IBXguB9P0riuz8l+3NgwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI1MDMyMTIyMDUxM1oXDTI3MDMyMTIyMDUxMlowVTEdMBsGA1UEAwwURmlyc3ROYW1lIFRlc3RlclVzZXIxEzARBgNVBAQMClRlc3RlclVzZXIxEjAQBgNVBCoMCUZpcnN0TmFtZTELMAkGA1UEBhMCRkMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATKfz322k66qo078TlOuj7DnCIysLH4Luq\\/rJXNXtlS5WvGOVNIc95blK\\/XRIgx8\\/Q0SYHrXwumDOaJxKZzs222o4HFMIHCMAwGA1UdEwEB\\/wQCMAAwHwYDVR0jBBgwFoAUs2y4kRcc16QaZjGHQuGLwEDMlRswHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMB0GA1UdDgQWBBRwUXIdDj4Rr+AfehggZXvcNj9wUTAOBgNVHQ8BAf8EBAMCBkAwCgYIKoZIzj0EAwIDZwAwZAIwUH8UEK\\/Vc+EDC4ZrRwBPpOCeJC5+9pky0hIyghFpaAOFUSsrqFjRxF9BlP\\/p1kNmAjA3B8sBJKNnlyEEHd0h+E6gaj5p\\/rgzj+kVX\\/30h8oZtAMpe1oamOGYhoLiZwmJH7Y=",
      "hashAlgorithmOID" : "2.16.840.1.101.3.4.2.3",
      "documents" : [
        {
          "documentInputPath" : "Documents/sample.pdf",
          "documentOutputPath" : "Documents/sample-signed.pdf",
          "signature_format" : "P",
          "container" : "No",
          "signed_envelope_property" : "ENVELOPED",
          "conformance_level" : "ADES_B_LT"
        }
      ],
      "certificateChain" : [
        "MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R\\/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X\\/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH\\/BAgwBgEB\\/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH\\/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl\\/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"
      ]
    }
    """
    
    static let documentDigestsResponse = """
    {
      "hashes" : [
        "lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D"
      ]
    }
    """
    
    static let minimalCalculateHashRequest = """
    {
      "endEntityCertificate" : "MIIC...",
      "hashAlgorithmOID" : "2.16.840.1.101.3.4.2.1",
      "documents" : [
        {
          "documentInputPath" : "test.pdf",
          "documentOutputPath" : "test-signed.pdf",
          "signature_format" : "P",
          "container" : "No",
          "signed_envelope_property" : "ENVELOPED",
          "conformance_level" : "ADES_B_LT"
        }
      ],
      "certificateChain" : ["CERT1"]
    }
    """
    
    static let emptyDocumentsCalculateHashRequest = """
    {
      "endEntityCertificate" : "MIIC...",
      "hashAlgorithmOID" : "2.16.840.1.101.3.4.2.1",
      "documents" : [],
      "certificateChain" : ["CERT1"]
    }
    """
    
    static let multipleDocumentsCalculateHashRequest = """
    {
      "endEntityCertificate" : "MIIC...",
      "hashAlgorithmOID" : "2.16.840.1.101.3.4.2.1",
      "documents" : [
        {
          "documentInputPath" : "doc1.pdf",
          "documentOutputPath" : "doc1-signed.pdf",
          "signature_format" : "P",
          "container" : "No",
          "signed_envelope_property" : "ENVELOPED",
          "conformance_level" : "ADES_B"
        },
        {
          "documentInputPath" : "doc2.pdf",
          "documentOutputPath" : "doc2-signed.pdf",
          "signature_format" : "C",
          "container" : "ASiC-S",
          "signed_envelope_property" : "ENVELOPING",
          "conformance_level" : "ADES_B_LT"
        }
      ],
      "certificateChain" : ["CERT1", "CERT2"]
    }
    """
    
    static let multipleHashesDocumentDigestsResponse = """
    {
      "hashes" : [
        "hash1EncodedValue",
        "hash2EncodedValue",
        "hash3EncodedValue"
      ]
    }
    """
    
    static let emptyHashesDocumentDigestsResponse = """
    {
      "hashes" : []
    }
    """

    static let standardCalculateHashRequest = CalculateHashRequest(
        documents: [
            CalculateHashRequest.Document(
                documentInputPath: "Documents/sample.pdf",
                documentOutputPath: "Documents/sample-signed.pdf",
                signatureFormat: SignatureFormat.P,
                conformanceLevel: ConformanceLevel.ADES_B_LT,
                signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
                container: "No"
            )
        ],
        endEntityCertificate: "MIICmDCCAh+gAwIBAgIUIGYtzcs9IBXguB9P0riuz8l+3NgwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI1MDMyMTIyMDUxM1oXDTI3MDMyMTIyMDUxMlowVTEdMBsGA1UEAwwURmlyc3ROYW1lIFRlc3RlclVzZXIxEzARBgNVBAQMClRlc3RlclVzZXIxEjAQBgNVBCoMCUZpcnN0TmFtZTELMAkGA1UEBhMCRkMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATKfz322k66qo078TlOuj7DnCIysLH4Luq\\/rJXNXtlS5WvGOVNIc95blK\\/XRIgx8\\/Q0SYHrXwumDOaJxKZzs222o4HFMIHCMAwGA1UdEwEB\\/wQCMAAwHwYDVR0jBBgwFoAUs2y4kRcc16QaZjGHQuGLwEDMlRswHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHBzOi8vcHJlcHJvZC5wa2kuZXVkaXcuZGV2L2NybC9waWRfQ0FfVVRfMDEuY3JsMB0GA1UdDgQWBBRwUXIdDj4Rr+AfehggZXvcNj9wUTAOBgNVHQ8BAf8EBAMCBkAwCgYIKoZIzj0EAwIDZwAwZAIwUH8UEK\\/Vc+EDC4ZrRwBPpOCeJC5+9pky0hIyghFpaAOFUSsrqFjRxF9BlP\\/p1kNmAjA3B8sBJKNnlyEEHd0h+E6gaj5p\\/rgzj+kVX\\/30h8oZtAMpe1oamOGYhoLiZwmJH7Y=",
        certificateChain: ["MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R\\/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X\\/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH\\/BAgwBgEB\\/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH\\/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl\\/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"],
        hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.3")
    )
    
    static let minimalCalculateHashRequestObject = CalculateHashRequest(
        documents: [
            CalculateHashRequest.Document(
                documentInputPath: "test.pdf",
                documentOutputPath: "test-signed.pdf",
                signatureFormat: SignatureFormat.P,
                conformanceLevel: ConformanceLevel.ADES_B_LT,
                signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
                container: "No"
            )
        ],
        endEntityCertificate: "MIIC...",
        certificateChain: ["CERT1"],
        hashAlgorithmOID: HashAlgorithmOID(rawValue: "2.16.840.1.101.3.4.2.1")
    )

    static let accessTokenRequestJSON = """
    {
      "state" : "BB94593E-79FF-4BBE-8549-1A20E9D99677",
      "code" : "XpOL_9gBQ4OczsEPvEL2atWb64WdvA_pCladM5ergCfegJD3RRXnqpqOBMCKNQ-RAAuoeynkSn6jE_fwFY5res9QmZJIC39z_k4G3-ZoIyJ2VZ13uPhQbJnoH4u_3DV0"
    }
    """
    
    static let accessTokenResponseJSON = """
    {
      "scope" : "service",
      "access_token" : "eyJraWQiOiI1NmI1YjZmYi03N2JhLTRmY2QtODVlZi0yMjc3ZTA0MWI5ZDgiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI4UGZDQVF6VG1PTitGSER2SDRHVy9nK0pVdGc1ZVZUZ3RxTUtaRmRCLytjPSIsImF1ZCI6IndhbGxldC1jbGllbnQiLCJuYmYiOjE3NTM0OTA1NDAsInN1cm5hbWUiOiJNT2U5VFZSbEZ0YklVWVc2U1AzR0pvR2pCQURkaGRoTlF1R0crSXNxQnJwZDNjUVFGakk9IiwiaXNzdWluZ0NvdW50cnkiOiJGQyIsInNjb3BlIjpbInNlcnZpY2UiXSwiZ2l2ZW5OYW1lIjoiWHVOY3ExVGl3Ky9ubWg2SG5VaHR5M3ZoUGZHbDRKN281Z0VUSFR2b0sveXVrczFmbWc9PSIsImlzcyI6Imh0dHBzOi8vd2FsbGV0Y2VudHJpYy5zaWduZXIuZXVkaXcuZGV2IiwiZXhwIjoxNzUzNDkwODQwLCJpYXQiOjE3NTM0OTA1NDAsImp0aSI6ImMyZDQzYzNkLTYzMjgtNGE3NS1hMzA5LTdhYmNmZjgwYTRiMyJ9.c_ODfYYCuL5zhWzfcOPG2jrMRuPneoycGWBy25ljr_aw5R2w5j_B2m_AnIYCeTTxlBt2T47bqAONd6rfIdTgZjWcNnVCdVgqbtJ4a0z2qjdqZxL3bmvAduLWxXiM6qvwxLod0_6BPs4SF4Y1l7IAA8YS1T45pQYiUXioFmgxU1R1JxGh73mHa-YSoktuF7K5HLymJYXZQ7UbULm9WX1ZTxRSw48C2Gn1MSaxGj6NfVNdjLKR0F05gVzzCT84xqilcQifeYeefEPxzq429R5hrjuDf1Z02BfFIX4DDhgG2hJwZm9ZS1pstAus379iNQU-L_0x6eBqf5ML-3JJlDCcZA",
      "token_type" : "Bearer",
      "expires_in" : 3599
    }
    """
    
    static let credentialAccessTokenRequestJSON = """
    {
      "authorizationDetails" : "[{\\"locations\\":[],\\"hashAlgorithmOID\\":\\"2.16.840.1.101.3.4.2.1\\",\\"credentialID\\":\\"662e92ed-cbeb-4d4f-9a46-8fc4df3cea85\\",\\"documentDigests\\":[{\\"hash\\":\\"lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D\\",\\"label\\":\\"A sample1 pdf\\"}],\\"type\\":\\"credential\\"}]",
      "state" : "BB94593E-79FF-4BBE-8549-1A20E9D99677",
      "code" : "TjTlT5hNRGoIRgbiAklj8cK3bCwbhOlzMxTdx7f9ZlK-684vbBBrlKxRx3l6yKWGkuKEiiU19t9szlGkh1i3FwDbkw1qdOdOxj6XilNg7zm1D--TXrH_4oz7orcAge09"
    }
    """
    
    static let credentialAccessTokenResponseJSON = """
    {
      "expires_in" : 299,
      "scope" : "credential",
      "token_type" : "Bearer",
      "access_token" : "eyJraWQiOiI1NmI1YjZmYi03N2JhLTRmY2QtODVlZi0yMjc3ZTA0MWI5ZDgiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI4UGZDQVF6VG1PTitGSER2SDRHVy9nK0pVdGc1ZVZUZ3RxTUtaRmRCLytjPSIsIm51bVNpZ25hdHVyZXMiOjEsImlzcyI6Imh0dHBzOi8vd2FsbGV0Y2VudHJpYy5zaWduZXIuZXVkaXcuZGV2IiwiaGFzaEFsZ29yaXRobU9JRCI6IjIuMTYuODQwLjEuMTAxLjMuNC4yLjEiLCJhdWQiOiJ3YWxsZXQtY2xpZW50IiwibmJmIjoxNzUzNDkwNTY5LCJzY29wZSI6WyJjcmVkZW50aWFsIl0sImhhc2hlcyI6ImxWMFhhUndadml0a2d4cFI2V1NhcWQ2eUxLOWdjV0ZxWGw0SmVQMVRJekwvUGRwcGFRMExzYzRjOTc5TmI1Z1B1bkVMd2pqWndmeVJ2OXhXMGtNbi9BPT0iLCJjcmVkZW50aWFsSUQiOiI2NjJlOTJlZC1jYmViLTRkNGYtOWE0Ni04ZmM0ZGYzY2VhODUiLCJleHAiOjE3NTM0OTA4NjksImlhdCI6MTc1MzQ5MDU2OSwianRpIjoiMzhmYzJjZjQtMThiNi00MDAzLWEyMWMtYzY2MjQzZjYzNTM2In0.XSfeM-YorMvsrAYuMS10X_faoTvIJtF9iY3ATDqp2uVKwhr7aqofu-7dCyIQ0GlH1-chhEkevlZPe7ZEXD18ROfcoMrExQyxtdmL2XLj1xQJFdV8CKq_Zu9HxYDSyDGFQS21lGr3eOJXVEmtpDPkR_UyRVoMTlOOSP0MLtRTU0kCfut-JXdMX1rQpJpUHyorMBECJP8YinEFPmaAWOaSNqf1p1jMoiU1RlwuvsKgzj07DJ6nQ5PxVbuUVgTL5mjp7z6KByNhN7Edxj3AXtM2UP7khAqk4s7wv9rCdgicLCtNqAWtfoCDmbfEUneKRe0ys_JOnx4hQqIO2v4VdOwN-Q"
    }
    """
    
    static let oAuth2ErrorResponseJSON = """
    {
      "error" : "invalid_grant",
      "error_description" : "The provided authorization grant is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client."
    }
    """
    
    static let invalidJSONResponse = """
    {
      "invalid": "json",
      "missing_required_fields": true
    }
    """

    static let serviceAccessTokenRequest = AccessTokenRequest(
        code: "XpOL_9gBQ4OczsEPvEL2atWb64WdvA_pCladM5ergCfegJD3RRXnqpqOBMCKNQ-RAAuoeynkSn6jE_fwFY5res9QmZJIC39z_k4G3-ZoIyJ2VZ13uPhQbJnoH4u_3DV0",
        state: "BB94593E-79FF-4BBE-8549-1A20E9D99677",
        authorizationDetails: nil
    )
    
    static let credentialAccessTokenRequest = AccessTokenRequest(
        code: "TjTlT5hNRGoIRgbiAklj8cK3bCwbhOlzMxTdx7f9ZlK-684vbBBrlKxRx3l6yKWGkuKEiiU19t9szlGkh1i3FwDbkw1qdOdOxj6XilNg7zm1D--TXrH_4oz7orcAge09",
        state: "BB94593E-79FF-4BBE-8549-1A20E9D99677",
        authorizationDetails: "[{\"locations\":[],\"hashAlgorithmOID\":\"2.16.840.1.101.3.4.2.1\",\"credentialID\":\"662e92ed-cbeb-4d4f-9a46-8fc4df3cea85\",\"documentDigests\":[{\"hash\":\"lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D\",\"label\":\"A sample1 pdf\"}],\"type\":\"credential\"}]"
    )
    
    static let testCSCClientConfig = CSCClientConfig(
        OAuth2Client: CSCClientConfig.OAuth2Client(
            clientId: "wallet-client",
            clientSecret: "somesecret2"
        ),
        authFlowRedirectionURI: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
        rsspId: "https://walletcentric.signer.eudiw.dev/csc/v2",
        tsaUrl: "https://timestamp.sectigo.com/qualified"
    )
    
    static let testIssuerURL = "https://walletcentric.signer.eudiw.dev"

    static let testCodeVerifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
    static let testCodeChallenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"

    static let adesB_B_Document = CalculateHashRequest.Document(
        documentInputPath: "Documents/ades-b-b.pdf",
        documentOutputPath: "Documents/ades-b-b-signed.pdf",
        signatureFormat: SignatureFormat.P,
        conformanceLevel: ConformanceLevel.ADES_B_B,
        signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
        container: "No"
    )
    
    static let adesB_T_Document = CalculateHashRequest.Document(
        documentInputPath: "Documents/ades-b-t.pdf",
        documentOutputPath: "Documents/ades-b-t-signed.pdf",
        signatureFormat: SignatureFormat.P,
        conformanceLevel: ConformanceLevel.ADES_B_T,
        signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
        container: "No"
    )
    
    static let adesB_LT_Document = CalculateHashRequest.Document(
        documentInputPath: "Documents/ades-b-lt.pdf",
        documentOutputPath: "Documents/ades-b-lt-signed.pdf",
        signatureFormat: SignatureFormat.P,
        conformanceLevel: ConformanceLevel.ADES_B_LT,
        signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
        container: "No"
    )
    
    static let adesB_LTA_Document = CalculateHashRequest.Document(
        documentInputPath: "Documents/ades-b-lta.pdf",
        documentOutputPath: "Documents/ades-b-lta-signed.pdf",
        signatureFormat: SignatureFormat.P,
        conformanceLevel: ConformanceLevel.ADES_B_LTA,
        signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
        container: "No"
    )
    
    static let mixedConformanceLevelDocuments = [adesB_T_Document, adesB_LT_Document]
    
    static let validTsaUrl = "https://timestamp.authority.com/tsa"
    static let emptyTsaUrl = ""
    
    static let sampleSignatures = [
        "MEUCIQCldUS00il6qjIez47FWa2mJONabr0ydhC9emMlDeYfWAIgY7bVx7LuGDVSc3E//NSC+pI9atPS8MwXRRfL1Qk3TcU=",
        "MEQCIFZkJ2lq8yB3eF2gK8rN5pH7qT9vMzXwL4aE1cR6sD8pAiBO3mY8kF9sL2pQ7jH6vR9eN1sA3xC8zT4yW1qE5dF9gQ==",
        "MEYCIQDRtL8nP9sF7mK6xQ2vE1hJ8sT4aA9cB6eL3kN7wP1sF2gIhAOz5yR8qN7mL4pE6dC9sA1vT3xF8kB2eL9wN4sP7qM="
    ]

    static let mockEndCertificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNtRENDQWgrZ0F3SUJBZ0lVSUdZdHpjczlJQlhndUI5UDByaXV6OGwrM05nd0NnWUlLb1pJemowRUF3SXcKWERFZU1Cd0dBMVVFQXd3VlVFbEVJRWx6YzNWbGNpQkRRU0FnTFNCVlZEQXhNUzB3S3dZRFZRUUtEQ1JGVlVScApJRmRoYkd4bGRDQlNaV1psY21WdVkyVWdTVzF3YkdWdFpXNTBZWFJwYjI0eEN6QUpCZ05WQkFZVEFsVlVNQjRYCkRUSTFNRE15TVRJeU1EVXhNMW9YRFRJM01ETXlNVEl5TURVeE1sb3dWVEVkTUJzR0ExVUVBd3dVUm1seWMzUk8KWVcxbElGUmxjM1JsY2xWelpYSXhFekFSQmdOVkJBUU1DbFJsYzNSbGNsVnpaWEl4RWpBUUJnTlZCQ29NQ1VacApjbk4wVG1GdFpURUxNQWtHQTFVRUJoTUNSa013V1RBVEJnY3Foa2pPUFFJQkJnZ3Foa2pPUFFNQkJ3TkNBQVRLCmZ6MzIyazY2cW8wNzhUbE91ajdEbkNJeXNMSDRMdXEvcUpYTlh0bFM1V3ZHT1ZOSWM5NWJsSy9YUklneDgvUTAKU1lIclh3dW1ET2FKeEtaenMyMjJvNEhGTUlIQ01Bd0dBMVVkRXdFQi93UUNNQUF3SHdZRFZSMGpCQmd3Rm9BVQpzMnk0a1JjYzE2UWFaakdIUXVHTHdFRE1sUnN3SFFZRFZSMEZCQLL3VUFZSUt3WUJCUVVIQXdJR0NDc0dBUVVGCkJ3TUVNRnkDVlNSMGZRVUkvF1UNOWpBNk1EaUFOcUEwakpKb2RIUndjem9zTDNCeVpYQnliMlF1Y0d0cExtVjEKWkdsd2RDNW5aWGQyZEhzKlBjVTFuSWpWL1FEQUFOc1U2VE1BZVVONzVuOU0LCG1yVXJGW2o2Vlh2bk0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ=="
    
    static let mockChainCertificates = [
        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURIVENDQXFPZnl8E2FvUw0RjTE1VXFqZ3RKcWY0aFVZSmtxZFlqaSswNTJaVENnWWJLb1pJemowRUF3TXcKWERFZU1Cd0dBMVVBd2k5VU9VbEIKa2YbEZkVzNWOERJTElWeDOxQ2tSUUJ6UFp0ZTE0dmMwV1ZVbUy4U2VJCkIyQklCS2Jua3ZpZGZnUFhEYzB2RTZMdUowRjJvbWgrbFlNNyFrYmNvQ3MnbfQUSUpCQWdHQTFVTFdEbJCa28dJbGhuTGh3LEtBR3Q4RmdBVlJqRE2fT2kvOGdKQ3JnVWZPeQ==",
        "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNDVENhVnNRUUFBQUcxVUE3bE1MQUFBUWJSS3NiZzhVSE9xb2hrako2ZnAwTnlrU3ZJbm1yZDR6ekNuV3MKdyFVaXZydk1kV3UwbGxuWRzUnRhMHBzRVFLdGE3VjJmdTlBRkdZODVvVDcycTZ4cy9yOGkxOVZNWWd3VGdZCklLb2I0d1WfC0dBMVJoTHZCcUFJaHNWZjNEZVpsQjhWaUV1VlVFeGFjZUJLUnpOQ2JvG3UjVXNNK3E2WUlxbgppNGQ0WE0rSUtXM3hFa3NVZzJRNHg1dmNaYVlmSVJJaSUxVG9kZHoRVxk1WVFJVjVINDBHbVhLVGg8LzJkRjBfCnZXNVNWbnpGdEJ2cVVTVWhTUk42cFEzaHNGM3F5RVFWL3ViYXVybm5zeU5ySWpGK3Z5M19ldCtIenFsL3VGR1SdtI0hU1FG=",
        "LS0tLS1CRUfVJCSUZJQ0FURS0tLS0tCk1JSURDQUVVQXdJQkFnTVFRR0UcCORJTkRBZ0VJZ0J4QUFEQThBSkxRVE5EMFnONW5VGEgD3VVV7MEcEZXlNSTdyeU1FS1VaT0NjZVpsVXl3Q0NySENIZjJ6SXBJQ3hxaUVsREZSaXQxSUd1alQ="
    ]
    
    static let mockTimestampResponse = "dGVzdC10aW1lc3RhbXAtcmVzcG9uc2UtYmFzZTY0LWVuY29kZWQ="
    
    static let mockCrlUrls = [
        "https://example.com/crl1.crl",
        "https://example.com/crl2.crl"
    ]
    
    static let mockCrlBase64Responses = [
        "Q1JMMSBiYXNlNjQgZW5jb2RlZCBkYXRh",
        "Q1JMMiBiYXNlNjQgZW5jb2RlZCBkYXRh"
    ]
    
    static let mockHashForTimestamp = "abc123def456789"

    static let allConformanceLevelDocuments = [
        adesB_B_Document,
        adesB_T_Document, 
        adesB_LT_Document,
        adesB_LTA_Document
    ]
    
    static let onlyAdesB_B_Documents = [
        adesB_B_Document,
        CalculateHashRequest.Document(
            documentInputPath: "Documents/another-ades-b-b.pdf",
            documentOutputPath: "Documents/another-ades-b-b-signed.pdf",
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
    ]
    
    static let onlyTsaRequiredDocuments = [adesB_T_Document, adesB_LT_Document, adesB_LTA_Document]

    static let serviceAuthorizationCode = "fXTIoXtrM9S0JENdIXnBLkgpKV6i5iWbcI9Ay1c5Nmza36aik1hd3DygBb7fCmc5eU4Ig0QOC2qyU3ccRo0G9uKwuB6voatEg3grSKdebasqStGToYTHfpigcHxegn6f"
    static let credentialAuthorizationCode = "cdiAxN7M7MZImpZHRpIVfrWc_UJPlrzHcnMhoYPKl04y8zhBsOV2E8kc17sadoCbprT0etN8ZUyuSRWzabjlpgOuT2GQOTv_tkuT7GgrPdDsjr8lPWz8BmjD_y4noeew"
    static let walletState = "40298BAF-0574-4D7B-95D7-9E93D18E56B8"
    
    static let serviceAuthorizationURL = "https://walletcentric.signer.eudiw.dev/oauth2/authorize?response_type=code&client_id=wallet-client&redirect_uri=https%3A//walletcentric.signer.eudiw.dev/tester/oauth/login/code&scope=service&code_challenge=icwKf_6fgjKJhe0olOXYp-RcSJlYp-Xjg5MQ3O28Pi0&code_challenge_method=S256&state=40298BAF-0574-4D7B-95D7-9E93D18E56B8"
    
    static let credentialAuthorizationURL = "https://walletcentric.signer.eudiw.dev/oauth2/authorize?response_type=code&client_id=wallet-client&redirect_uri=https%3A//walletcentric.signer.eudiw.dev/tester/oauth/login/code&scope=credential&code_challenge=icwKf_6fgjKJhe0olOXYp-RcSJlYp-Xjg5MQ3O28Pi0&code_challenge_method=S256&state=40298BAF-0574-4D7B-95D7-9E93D18E56B8&authorization_details=%5B%7B%22type%22%3A%22credential%22%2C%22hashAlgorithmOID%22%3A%222.16.840.1.101.3.4.2.1%22%2C%22documentDigests%22%3A%5B%7B%22label%22%3A%22A%20sample1%20pdf%22%2C%22hash%22%3A%22lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%252FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%252FA%253D%253D%22%7D%5D%2C%22credentialID%22%3A%22662e92ed-cbeb-4d4f-9a46-8fc4df3cea85%22%2C%22locations%22%3A%5B%5D%7D%5D"
    
    static let testDocumentDigest = DocumentDigest(
        label: "A sample1 pdf",
        hash: "lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D"
    )
    
    static let testAuthorizationDetailsItem = AuthorizationDetailsItem(
        documentDigests: [testDocumentDigest],
        credentialID: "662e92ed-cbeb-4d4f-9a46-8fc4df3cea85",
        hashAlgorithmOID: HashAlgorithmOID.SHA256,
        locations: [],
        type: "credential"
    )
    
    static let testAuthorizationDetails: AuthorizationDetails = [testAuthorizationDetailsItem]
    
    static let authorizationDetailsJSON = """
    [{"type":"credential","hashAlgorithmOID":"2.16.840.1.101.3.4.2.1","documentDigests":[{"label":"A sample1 pdf","hash":"lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D"}],"credentialID":"662e92ed-cbeb-4d4f-9a46-8fc4df3cea85","locations":[]}]
    """
    
    static let serviceAccessTokenResponseNew = """
    {
      "token_type" : "Bearer",
      "access_token" : "eyJraWQiOiI1NmI1YjZmYi03N2JhLTRmY2QtODVlZi0yMjc3ZTA0MWI5ZDgiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI4UGZDQVF6VG1PTitGSER2SDRHVy9nK0pVdGc1ZVZUZ3RxTUtaRmRCLytjPSIsImF1ZCI6IndhbGxldC1jbGllbnQiLCJuYmYiOjE3NTM1NjQ3NzYsInN1cm5hbWUiOiJjUTc4aUpsdWJGWHl4cFhud2dGeGExbnRmOG52MEtaVW9Dck9jeWx1YlFxOU1SdWs2ODg9IiwiaXNzdWluZ0NvdW50cnkiOiJGQyIsInNjb3BlIjpbInNlcnZpY2UiXSwiZ2l2ZW5OYW1lIjoiVGdGaE5SSFpRa1pIK0pwZEVaR1JOOG9Oc2JZOU1LRUt1bElXZGh5VnlaTENDUnBYd2c9PSIsImlzcyI6Imh0dHBzOi8vd2FsbGV0Y2VudHJpYy5zaWduZXIuZXVkaXcuZGV2IiwiZXhwIjoxNzUzNTY1MDc2LCJpYXQiOjE3NTM1NjQ3NzYsImp0aSI6IjkxODMyM2U0LWQ2NzMtNDI4Ny05NjVjLTdkYzQ3NjRhNjYyZCJ9.KdBswZvzQt11NB3_5JqLi9R7llVlt8lUUo9ngalywzHqX04RT_6reRIIYvmLdYiDcNPhhfd4exUJTVE4o4Va48LyZUk65tfsSESb1x5MLoGCXdhivZ4HFjglh1vjCJsoWVTmYQYbwtX-SQ4pc3LqvtEMfn5IVToRJnacybgOD50XCPChGSlCrVn_7nMdpvqWpn5SC5OnIaG8U2lpa5kmvVOuvtRkNS-6eVDI_mZSZSZwH0HHxAl7ZrgcsbnE-AW9ZuhVxpALR-UBUA4n-Es8cONZ504L1YnnuCdbzpzQ8Pdi1K05YJacKONAQnOoP9KxwdPJiCAc8Y5dbJ_bfgOqQ",
      "scope" : "service",
      "expires_in" : 3599
    }
    """
    
    static let credentialAccessTokenResponseNew = """
    {
      "token_type" : "Bearer",
      "expires_in" : 299,
      "scope" : "credential", 
      "access_token" : "eyJraWQiOiI1NmI1YjZmYi03N2JhLTRmY2QtODVlZi0yMjc3ZTA0MWI5ZDgiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI4UGZDQVF6VG1PTitGSER2SDRHVy9nK0pVdGc1ZVZUZ3RxTUtaRmRCLytjPSIsIm51bVNpZ25hdHVyZXMiOjEsImlzcyI6Imh0dHBzOi8vd2FsbGV0Y2VudHJpYy5zaWduZXIuZXVkaXcuZGV2IiwiaGFzaEFsZ29yaXRobU9JRCI6IjIuMTYuODQwLjEuMTAxLjMuNC4yLjEiLCJhdWQiOiJ3YWxsZXQtY2xpZW50IiwibmJmIjoxNzUzNTY0ODY4LCJzY29wZSI6WyJjcmVkZW50aWFsIl0sImhhc2hlcyI6ImxWMFhhUndadml0a2d4cFI2V1NhcWQ2eUxLOWdjV0ZxWGw0SmVQMVRJekwvUGRwcGFRMExzYzRjOTc5TmI1Z1B1bkVMd2pqWndmeVJ2OXhXMGtNbi9BPT0iLCJjcmVkZW50aWFsSUQiOiI2NjJlOTJlZC1jYmViLTRkNGYtOWE0Ni04ZmM0ZGYzY2VhODUiLCJleHAiOjE3NTM1NjUxNjgsImlhdCI6MTc1MzU2NDg2OCwianRpIjoiZGQ3MTNhMWQtYjA3Yy00OGUzLWIyNGItZGUwZjA3OTQ0ODU4In0.Ne0nQbdyfph66OJh4Z0_8MFb-_cORc4rAbRKZH_Zz6FSuvcCwrnJfp65H6w9HLB2t6VLHk0Ahap65CufYQxvL-7D7MQlI6-7oh9g2ZajF36zrhaKdkav0rEE4V1TwbaOwoFdHBRnrhnxfPm9B2QzazmYEqNU0jQXOznvzbmGhyHam3PDdpUfY7BBp_gU4Tg6vDCQZjfsqcCA8sEtr6W6--kBzkpMXVS8iKEt3o51w-mei-AsRlIlbtaM8LX4Nz1W8KMnFjoaKOQLPaE0mtaAEi1MEC4t2fkFJTtzFHSBM1YNGVqm4cbZF1Qe3YC2bQA1k9zE9WLaQ4ozFEF3A7P1_A"
    }
    """
    
    static let testSignHashResponse = """
    {
      "signatures" : [
        "MEQCIGQn4ZvDdQ1JSYKMv6cvyADkn52jAqZPAxFzyn+ll2P7AiAzus2disd68tiXMv+XoJx3umyBB/iBedyQ4cV0he0Mng=="
      ]
    }
    """
    
    static let urlEncodedHash = "lV0XaRwZvitkgxpR6WSaqd6yLK9gcWFqXl4JeP1TIzL%2FPdppaQ0Lsc4c979Nb5gPunELwjjZwfyRv9xW0kMn%2FA%3D%3D"
    
    static let testCodeChallenge2 = "icwKf_6fgjKJhe0olOXYp-RcSJlYp-Xjg5MQ3O28Pi0"
} 
