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
import Security
import JOSESwift

internal struct JWSPublicKeyVerifier {

  static func convertPEMToPublicKey(
    _ pem: String,
    algorithm: SignatureAlgorithm = .RS256
  ) -> SecKey? {
    switch algorithm {
    case .RS256, .RS384, .RS512:
      return try? convertRSAPEMToPublicKey(pem)

    case .ES256, .ES384, .ES512:
      return try? ECPublicKeyConverter.secKey(fromPEM: pem)

    case .HS256, .HS384, .HS512:
      return nil

    case .PS256, .PS384, .PS512:
      return nil
    }
  }

  static func verify(
    jws: JWS,
    pem: String,
    algorithm: SignatureAlgorithm = .RS256
  ) throws -> Bool {
    guard let publicKey = convertPEMToPublicKey(pem, algorithm: algorithm) else {
      throw JOSEError.invalidVerifier // or define your own "invalidKey" error
    }
    return try verify(jws: jws, publicKey: publicKey, algorithm: algorithm)
  }

  static func verify(
    jws: JWS,
    publicKey: SecKey,
    algorithm: SignatureAlgorithm = .RS256
  ) throws -> Bool {
    let verifier = try makeVerifier(algorithm: algorithm, publicKey: publicKey)
    return try jws.validate(using: verifier).isValid(for: verifier)
  }

  private static func convertRSAPEMToPublicKey(_ pem: String) throws -> SecKey? {
    let key = pem
      .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
      .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
      .split(separator: "\n").joined()

    let attributes: [CFString: Any] = [
      kSecAttrKeyType: kSecAttrKeyTypeRSA,
      kSecAttrKeyClass: kSecAttrKeyClassPublic
    ]

    guard let publicKeyData = Data(
      base64Encoded: key,
      options: .ignoreUnknownCharacters
    ) else {
      return nil
    }

    var error: Unmanaged<CFError>?
    guard let secKey = SecKeyCreateWithData(
      publicKeyData as CFData,
      attributes as CFDictionary,
      &error
    ) else {
      if let error = error?.takeRetainedValue() {
        print("Failed to create SecKey:", error)
      }
      return nil
    }

    return secKey
  }

  private static func makeVerifier(
    algorithm: SignatureAlgorithm,
    publicKey: SecKey
  ) throws -> JOSESwift.Verifier {
    guard let verifier = Verifier(signatureAlgorithm: algorithm, key: publicKey) else {
      throw JOSEError.invalidVerifier
    }
    return verifier
  }
}

