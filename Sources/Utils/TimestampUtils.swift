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

public enum TimestampUtilsError: Error {
    case invalidBase64Hash
    case emptyHash
}

public struct TimestampUtils {

    public static func buildTSQ(from signedHash: String) throws -> Data {

        guard !signedHash.isEmpty else {
            throw TimestampUtilsError.emptyHash
        }

        guard let raw = Data(base64Encoded: signedHash) else {
            throw TimestampUtilsError.invalidBase64Hash
        }

        let digest = SHA256.hash(data: raw)
        let digestData = Data(digest)

        let oidSHA256  = Data([0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01])
        let nullBytes  = Data([0x05, 0x00])
        let algIDSeq   = Data.tlv(0x30, oidSHA256 + nullBytes)

        let octetDigest   = Data.tlv(0x04, digestData)
        let msgImprintSeq = Data.tlv(0x30, algIDSeq + octetDigest)

        let versionBytes = Data([0x02, 0x01, 0x01])
        let certReqBytes = Data([0x01, 0x01, 0xFF])
        let tsReqBody    = versionBytes + msgImprintSeq + certReqBytes
        let tsqDER       = Data.tlv(0x30, tsReqBody)

        return tsqDER
    }

    public static func encodeTSRToBase64(_ tsrData: Data) -> String {
        tsrData.base64EncodedString()
    }
}

private extension Data {
    static func tlv(_ tag: UInt8, _ value: Data) -> Data {
        let length = value.count
        let lengthBytes: Data = {
            if length < 0x80 {
                return Data([UInt8(length)])
            } else {
                var tmp = length
                var octets: [UInt8] = []
                while tmp > 0 {
                    octets.insert(UInt8(tmp & 0xFF), at: 0)
                    tmp >>= 8
                }
                let first = UInt8(0x80 | UInt8(octets.count))
                return Data([first] + octets)
            }
        }()
        return Data([tag]) + lengthBytes + value
    }
}
