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

final class DigestsTests: XCTestCase {

    private let helloBase64 = "aGVsbG8="          // "hello"
    private let helloBase64URL = "aGVsbG8"        // base64url(no padding)
    private let helloBase64PercentEncoded = "aGVsbG8%3D" // "aGVsbG8="

    private let plusSlashBase64 = "++//"          // bytes FB EF FF
    private let plusSlashBase64URL = "--__"       // base64url variant
    private var alg: HashAlgorithmOID {
        return .SHA256
    }

    // MARK: - DocumentDigest

    func testDocumentDigest_forAuthorization_convertsBase64ToBase64URLNoPadding() throws {
        let digest = try DocumentDigest.forAuthorization(label: "doc1", hash: helloBase64)
        XCTAssertEqual(digest.label, "doc1")
        XCTAssertEqual(digest.hash, helloBase64URL) // "=" removed for base64url no padding
        XCTAssertFalse(digest.hash.contains("="))
        XCTAssertFalse(digest.hash.contains("+"))
        XCTAssertFalse(digest.hash.contains("/"))
    }

    func testDocumentDigest_forToken_convertsBase64URLToBase64WithPadding() throws {
        let digest = try DocumentDigest.forToken(label: "doc1", hash: helloBase64URL)
        XCTAssertEqual(digest.hash, helloBase64) // padding restored
        XCTAssertTrue(digest.hash.hasSuffix("="))
    }

    func testDocumentDigest_percentEncodedInput_isAcceptedAndNormalized() throws {
        let digest = try DocumentDigest.forToken(label: "doc1", hash: helloBase64PercentEncoded)
        XCTAssertEqual(digest.hash, helloBase64)
    }

    func testDocumentDigest_plusSlashConversion() throws {
        let auth = try DocumentDigest.forAuthorization(label: "doc1", hash: plusSlashBase64)
        XCTAssertEqual(auth.hash, plusSlashBase64URL)

        let token = try DocumentDigest.forToken(label: "doc1", hash: plusSlashBase64URL)
        XCTAssertEqual(token.hash, plusSlashBase64)
    }

    func testDocumentDigest_blank_throws() {
        XCTAssertThrowsError(try DocumentDigest.forToken(label: "doc1", hash: "   "))
    }

    func testDocumentDigest_invalid_throws() {
        XCTAssertThrowsError(try DocumentDigest.forAuthorization(label: "doc1", hash: "not-base64!!"))
    }

    // MARK: - DocumentDigests

    func testDocumentDigests_forAuthorization_convertsAllToBase64URLNoPadding() throws {
        let digests = try DocumentDigests.forAuthorization(digests: [helloBase64, plusSlashBase64])
        XCTAssertEqual(digests.hashes, [helloBase64URL, plusSlashBase64URL])
    }

    func testDocumentDigests_forToken_convertsAllToBase64() throws {
        let digests = try DocumentDigests.forToken(digests: [helloBase64URL, plusSlashBase64URL])
        XCTAssertEqual(digests.hashes, [helloBase64, plusSlashBase64])
    }

    func testDocumentDigests_blank_throws() {
        XCTAssertThrowsError(try DocumentDigests.forToken(digests: [""]))
    }

    func testDocumentDigests_invalid_throws() {
        XCTAssertThrowsError(try DocumentDigests.forAuthorization(digests: ["###"]))
    }

    func testDocumentDigests_codableRoundTrip_preservesHashes() throws {
        let original = try DocumentDigests.forAuthorization(digests: [helloBase64, plusSlashBase64])

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DocumentDigests.self, from: encoded)

        XCTAssertEqual(decoded.hashes, [helloBase64URL, plusSlashBase64URL])
    }

    // MARK: - AuthorizationDetailsItem

    func testAuthorizationDetailsItem_copy_digestFormat_convertsDocumentDigestsOnly() throws {
        let item = AuthorizationDetailsItem(
            documentDigests: [
                DocumentDigest(label: "a", hash: helloBase64),
                DocumentDigest(label: "b", hash: plusSlashBase64),
            ],
            credentialID: "cred-123",
            hashAlgorithmOID: alg,
            locations: ["loc1", "loc2"],
            type: "someType"
        )

        let auth = try item.copy(digestFormat: .base64URLNoPadding)

        // other fields unchanged
        XCTAssertEqual(auth.credentialID, item.credentialID)
        XCTAssertEqual(auth.hashAlgorithmOID, item.hashAlgorithmOID)
        XCTAssertEqual(auth.locations, item.locations)
        XCTAssertEqual(auth.type, item.type)

        // hashes normalized
        XCTAssertEqual(auth.documentDigests.map(\.label), ["a", "b"])
        XCTAssertEqual(auth.documentDigests.map(\.hash), [helloBase64URL, plusSlashBase64URL])
    }

    func testAuthorizationDetailsItem_copy_hashesOverride_preservesLabelsAndOtherFields() throws {
        let item = AuthorizationDetailsItem(
            documentDigests: [
                DocumentDigest(label: "a", hash: helloBase64),
                DocumentDigest(label: "b", hash: helloBase64),
            ],
            credentialID: "cred-123",
            hashAlgorithmOID: alg,
            locations: ["loc1"],
            type: "someType"
        )

        let newHashes = [plusSlashBase64, helloBase64URL] // mixed inputs ok
        let updated = try item.copy(hashes: newHashes, digestFormat: .base64)

        XCTAssertEqual(updated.documentDigests.map(\.label), ["a", "b"])
        XCTAssertEqual(updated.documentDigests.map(\.hash), [plusSlashBase64, helloBase64]) // normalized to base64
        XCTAssertEqual(updated.credentialID, item.credentialID)
        XCTAssertEqual(updated.hashAlgorithmOID, item.hashAlgorithmOID)
        XCTAssertEqual(updated.locations, item.locations)
        XCTAssertEqual(updated.type, item.type)
    }

    func testAuthorizationDetailsItem_copy_hashesOverride_countMismatch_throws() {
        let item = AuthorizationDetailsItem(
            documentDigests: [DocumentDigest(label: "a", hash: helloBase64)],
            credentialID: "cred-123",
            hashAlgorithmOID: alg,
            locations: [],
            type: "someType"
        )

        XCTAssertThrowsError(try item.copy(hashes: [helloBase64, helloBase64], digestFormat: .base64))
    }

    // MARK: - DigestNormalizer testing strategy

    func testNormalizer_isCoveredIndirectlyThroughPublicAPIs() throws {
        // This test is here mainly to document that normalization behavior is exercised
        // through the initializers rather than calling DigestNormalizer directly.

        let d1 = try DocumentDigest(label: "x", hash: helloBase64, output: .base64URLNoPadding)
        XCTAssertEqual(d1.hash, helloBase64URL)

        let d2 = try DocumentDigests(digests: [helloBase64URL], output: .base64)
        XCTAssertEqual(d2.hashes, [helloBase64])
    }
}


