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
import Security
@testable import RQESLib

final class ECPublicKeyConverterTests: XCTestCase {
    
    func testP256_RoundTripPEMToSecKey() throws {
        try assertRoundTripForCurve(keySizeBits: 256, curveOID: "1.2.840.10045.3.1.7")
    }
    
    func testP384_RoundTripPEMToSecKey() throws {
        try assertRoundTripForCurve(keySizeBits: 384, curveOID: "1.3.132.0.34")
    }
    
    func testP521_RoundTripPEMToSecKey() throws {
        try assertRoundTripForCurve(keySizeBits: 521, curveOID: "1.3.132.0.35")
    }
    
    func testInvalidPEM_MissingHeaders_Throws() {
        let pem = "not a pem"
        XCTAssertThrowsError(try ECPublicKeyConverter.secKey(fromPEM: pem)) { error in
            guard case ECPemError.invalidPEM = error else {
                XCTFail("Expected invalidPEM, got \(error)")
                return
            }
        }
    }
    
    func testInvalidPEM_BadBase64_Throws() {
        let pem = """
    -----BEGIN PUBLIC KEY-----
    !!!notbase64!!!
    -----END PUBLIC KEY-----
    """
        XCTAssertThrowsError(try ECPublicKeyConverter.secKey(fromPEM: pem)) { error in
            guard case ECPemError.invalidPEM = error else {
                XCTFail("Expected invalidPEM, got \(error)")
                return
            }
        }
    }
    
    func testUnsupportedCurveOID_ThrowsUnsupportedCurve() throws {
        let (rawPubKey, _) = try generateECPublicKeyBytes(keySizeBits: 256)
        // Use a made-up curve OID
        let der = try makeSPKIDER(curveOID: "1.2.3.4.5.6.7", publicKeyBytes: rawPubKey)
        let pem = pemFromDER(der)
        
        XCTAssertThrowsError(try ECPublicKeyConverter.secKey(fromPEM: pem)) { error in
            guard case ECPemError.unsupportedCurveOID(let oid) = error else {
                XCTFail("Expected unsupportedCurveOID, got \(error)")
                return
            }
            XCTAssertEqual(oid, "1.2.3.4.5.6.7")
        }
    }
    
    func testWrongAlgorithmOID_NotECPublicKey_Throws() throws {
        let (rawPubKey, _) = try generateECPublicKeyBytes(keySizeBits: 256)
        
        // Build SPKI but with rsaEncryption OID (1.2.840.113549.1.1.1) instead of id-ecPublicKey.
        let der = try makeSPKIDER_CustomAlgorithmOID(
            algorithmOID: "1.2.840.113549.1.1.1",
            curveOID: "1.2.840.10045.3.1.7",
            publicKeyBytes: rawPubKey
        )
        let pem = pemFromDER(der)
        
        XCTAssertThrowsError(try ECPublicKeyConverter.secKey(fromPEM: pem)) { error in
            // Your converter throws asn1Unexpected for this scenario.
            guard case ECPemError.asn1Unexpected = error else {
                XCTFail("Expected asn1Unexpected, got \(error)")
                return
            }
        }
    }
    
    func testBitStringUnusedBitsNotZero_Throws() throws {
        let (rawPubKey, _) = try generateECPublicKeyBytes(keySizeBits: 256)
        let der = try makeSPKIDER(curveOID: "1.2.840.10045.3.1.7", publicKeyBytes: rawPubKey)
        
        let patched = try patchBitStringUnusedBitsByRebuildingSPKI(der: der, newValue: 0x01)
        let pem = pemFromDER(patched)
        
        XCTAssertThrowsError(try ECPublicKeyConverter.secKey(fromPEM: pem)) { error in
            guard case ECPemError.asn1Unexpected = error else {
                XCTFail("Expected asn1Unexpected, got \(error)")
                return
            }
        }
    }
    
    func testCompressedPoint_Throws() throws {
        let (rawPubKey, _) = try generateECPublicKeyBytes(keySizeBits: 256)
        XCTAssertEqual(rawPubKey.first, 0x04, "Expected uncompressed point from Security key export")
        
        // Replace uncompressed marker 0x04 with compressed marker 0x02
        var compressed = rawPubKey
        compressed[0] = 0x02
        
        let der = try makeSPKIDER(curveOID: "1.2.840.10045.3.1.7", publicKeyBytes: compressed)
        let pem = pemFromDER(der)
        
        XCTAssertThrowsError(try ECPublicKeyConverter.secKey(fromPEM: pem)) { error in
            guard case ECPemError.asn1Unexpected = error else {
                XCTFail("Expected asn1Unexpected, got \(error)")
                return
            }
        }
    }
    
    func testTruncatedDER_ThrowsInvalidDER() throws {
        let (rawPubKey, _) = try generateECPublicKeyBytes(keySizeBits: 256)
        let der = try makeSPKIDER(curveOID: "1.2.840.10045.3.1.7", publicKeyBytes: rawPubKey)
        
        let truncated = der.prefix(max(0, der.count - 8))
        let pem = pemFromDER(Data(truncated))
        
        XCTAssertThrowsError(try ECPublicKeyConverter.secKey(fromPEM: pem)) { error in
            // Depending on where truncation hits, invalidDER is expected.
            guard case ECPemError.invalidDER = error else {
                XCTFail("Expected invalidDER, got \(error)")
                return
            }
        }
    }
    
    private func assertRoundTripForCurve(keySizeBits: Int, curveOID: String) throws {
        let (rawPubKey, pubSecKeyOriginal) = try generateECPublicKeyBytes(keySizeBits: keySizeBits)
        let der = try makeSPKIDER(curveOID: curveOID, publicKeyBytes: rawPubKey)
        let pem = pemFromDER(der)
        
        let secKey = try ECPublicKeyConverter.secKey(fromPEM: pem)
        
        // Verify key attributes
        let attrs = SecKeyCopyAttributes(secKey) as NSDictionary? as? [CFString: Any]
        let size = attrs?[kSecAttrKeySizeInBits] as? Int
        XCTAssertEqual(size, keySizeBits)
        
        // Verify external representation matches original raw public key bytes
        let convertedBytes = try externalRepresentation(of: secKey)
        XCTAssertEqual(convertedBytes, rawPubKey)
        
        // Sanity: also compare against the original public SecKey’s export
        let originalBytes = try externalRepresentation(of: pubSecKeyOriginal)
        XCTAssertEqual(originalBytes, rawPubKey)
    }
    
    private func generateECPublicKeyBytes(keySizeBits: Int) throws -> (Data, SecKey) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: keySizeBits
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue()
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            XCTFail("Failed to get public key")
            throw ECPemError.invalidDER
        }
        
        let raw = try externalRepresentation(of: publicKey)
        // For EC X9.63 uncompressed: 0x04 || X || Y
        XCTAssertEqual(raw.first, 0x04, "Expected uncompressed EC point (0x04 prefix)")
        return (raw, publicKey)
    }
    
    private func externalRepresentation(of key: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
            throw error?.takeRetainedValue() ?? ECPemError.invalidDER
        }
        return data
    }
    
    /// Standard SPKI for EC:
    /// SEQUENCE {
    ///   SEQUENCE { OID id-ecPublicKey, OID namedCurve }
    ///   BIT STRING { 0 unused bits, <X9.63 bytes> }
    /// }
    private func makeSPKIDER(curveOID: String, publicKeyBytes: Data) throws -> Data {
        try makeSPKIDER_CustomAlgorithmOID(
            algorithmOID: "1.2.840.10045.2.1", // id-ecPublicKey
            curveOID: curveOID,
            publicKeyBytes: publicKeyBytes
        )
    }
    
    private func makeSPKIDER_CustomAlgorithmOID(
        algorithmOID: String,
        curveOID: String,
        publicKeyBytes: Data
    ) throws -> Data {
        let algSeq = derSequence([
            derOID(algorithmOID),
            derOID(curveOID)
        ])
        
        // BIT STRING contents: [unusedBitsByte=0x00] + publicKeyBytes
        let bitStringContents = Data([0x00]) + publicKeyBytes
        let spkBitString = derBitString(bitStringContents)
        
        return derSequence([algSeq, spkBitString])
    }
    
    private func pemFromDER(_ der: Data) -> String {
        let b64 = der.base64EncodedString()
        let lines = stride(from: 0, to: b64.count, by: 64).map { i -> String in
            let start = b64.index(b64.startIndex, offsetBy: i)
            let end = b64.index(start, offsetBy: min(64, b64.count - i))
            return String(b64[start..<end])
        }.joined(separator: "\n")
        
        return """
    -----BEGIN PUBLIC KEY-----
    \(lines)
    -----END PUBLIC KEY-----
    """
    }
    
    private func derSequence(_ elements: [Data]) -> Data {
        let content = elements.reduce(into: Data()) { $0.append($1) }
        return Data([0x30]) + derLength(content.count) + content
    }
    
    private func derBitString(_ content: Data) -> Data {
        return Data([0x03]) + derLength(content.count) + content
    }
    
    private func derOID(_ oid: String) -> Data {
        let arcs = oid.split(separator: ".").compactMap { Int($0) }
        precondition(arcs.count >= 2, "OID must have at least 2 arcs")
        
        var body = Data()
        body.append(UInt8(arcs[0] * 40 + arcs[1]))
        
        for arc in arcs.dropFirst(2) {
            body.append(contentsOf: base128Encode(arc))
        }
        
        return Data([0x06]) + derLength(body.count) + body
    }
    
    private func base128Encode(_ value: Int) -> [UInt8] {
        precondition(value >= 0)
        if value == 0 { return [0] }
        
        var bytes: [UInt8] = []
        var v = value
        while v > 0 {
            bytes.append(UInt8(v & 0x7F))
            v >>= 7
        }
        bytes.reverse()
        for i in 0..<(bytes.count - 1) {
            bytes[i] |= 0x80
        }
        return bytes
    }
    
    private func derLength(_ length: Int) -> Data {
        precondition(length >= 0)
        if length < 128 {
            return Data([UInt8(length)])
        }
        // Long form
        var len = length
        var octets: [UInt8] = []
        while len > 0 {
            octets.append(UInt8(len & 0xFF))
            len >>= 8
        }
        octets.reverse()
        return Data([0x80 | UInt8(octets.count)]) + Data(octets)
    }
    
    private func patchBitStringUnusedBits(der: Data, newValue: UInt8) throws -> Data {
        var data = der
        // naive scan: find BIT STRING tag 0x03
        guard let bitIndex = data.firstIndex(of: 0x03) else {
            throw ECPemError.invalidDER
        }
        var idx = data.distance(from: data.startIndex, to: bitIndex)
        idx += 1 // move past tag
        
        // parse length (DER)
        guard idx < data.count else { throw ECPemError.invalidDER }
        let firstLen = data[idx]
        idx += 1
        
        var contentLen = 0
        if firstLen & 0x80 == 0 {
            contentLen = Int(firstLen)
        } else {
            let count = Int(firstLen & 0x7F)
            guard count > 0, count <= 4, idx + count <= data.count else { throw ECPemError.invalidDER }
            for _ in 0..<count {
                contentLen = (contentLen << 8) | Int(data[idx])
                idx += 1
            }
        }
        
        guard contentLen >= 1, idx < data.count else { throw ECPemError.invalidDER }
        
        // idx is now at BIT STRING content start; first byte is unused bits count
        data[idx] = newValue
        return data
    }
    
    private func patchBitStringUnusedBitsByRebuildingSPKI(der: Data, newValue: UInt8) throws -> Data {
        // Parse outer SPKI SEQUENCE
        var i = 0
        let spki = try ASN1.readTLV(der, &i, expectedTag: 0x30) // SEQUENCE
        var inner = 0
        
        // Grab AlgorithmIdentifier SEQUENCE bytes (as TLV) so we can reuse exact bytes.
        let alg = try ASN1.readTLV(spki.value, &inner, expectedTag: 0x30) // value is just the inner value
        // BUT: we lost the original tag+len bytes since ASN1.readTLV returns only value.
        // So we re-encode it.
        let algTLV = derSequence([alg.value]) // alg.value is already the inner of AlgorithmIdentifier? No—it's the value of that sequence, so this reconstructs it.
        
        // Grab BIT STRING (value includes unused-bits byte + key bytes)
        let bit = try ASN1.readTLV(spki.value, &inner, expectedTag: 0x03)
        
        guard !bit.value.isEmpty else { throw ECPemError.invalidDER }
        var patchedBitValue = bit.value
        patchedBitValue[patchedBitValue.startIndex] = newValue
        
        let bitTLV = derBitString(patchedBitValue)
        
        // Rebuild SPKI
        return derSequence([algTLV, bitTLV])
    }
}
