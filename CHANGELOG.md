# 📦 Changelog

## [R5] - 2025-5-9 - Added includeRevocationInfo Configuration

### 🔄 Changed
In **R5**, a new configuration option `includeRevocationInfo` has been added to the `CSCClientConfig` to control whether revocation information (CRL and OCSP) should be included during PDF signing operations. This allows users to optimize performance by skipping revocation requests when they are not needed.

The `includeRevocationInfo` parameter defaults to `false`, ensuring backward compatibility while providing the option to include revocation information when required.

#### 🔁 Previous (R5)

```Swift
let cscClientConfig = CSCClientConfig(
    OAuth2Client: CSCClientConfig.OAuth2Client(
        clientId: "wallet-client",
        clientSecret: "somesecret2"
    ),
    authFlowRedirectionURI: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
    rsspId: "https://walletcentric.signer.eudiw.dev/csc/v2",
    tsaUrl: "http://ts.cartaodecidadao.pt/tsa/server"
)
```

#### ✅ Now (R5)

```Swift
let cscClientConfig = CSCClientConfig(
    OAuth2Client: CSCClientConfig.OAuth2Client(
        clientId: "wallet-client",
        clientSecret: "somesecret2"
    ),
    authFlowRedirectionURI: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
    rsspId: "https://walletcentric.signer.eudiw.dev/csc/v2",
    tsaUrl: "http://ts.cartaodecidadao.pt/tsa/server",
    includeRevocationInfo: false // can be set to true to include CRL and OCSP Requests. If not set, defaults to false.
)
```

### ✅ Behavior Summary

| includeRevocationInfo | CRL Requests | OCSP Requests | Validation Certificates |
|----------------------|---------------|----------------|-------------------------|
| `false` (default)    | ❌ Skipped    | ❌ Skipped     | ✅ Always included      |
| `true`               | ✅ Included   | ✅ Included    | ✅ Always included      |

This optimization reduces network requests and improves performance when revocation information is not required for the signing operation.

## [R5] - 2025-17-7 - SCA URL Removed

### 🔄 Changed
SCA URL removed and replaced by rsspId

```Swift
let cscClientConfig = CSCClientConfig(
    OAuth2Client: CSCClientConfig.OAuth2Client(
        clientId: "wallet-client",
        clientSecret: "somesecret2"
    ),
    authFlowRedirectionURI: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
    rsspId: "https://walletcentric.signer.eudiw.dev/csc/v2", //Before: scaBaseURL: "https://walletcentric.signer.eudiw.dev",
    tsaUrl: "http://ts.cartaodecidadao.pt/tsa/server"
)
```


## [R5] - 2025-17-6 - Added Support for Pades B-T 

### 🔄 Changed
In **R5**, the `ConformanceLevel` enum has been extended to include support for **Pades B-T** signatures. This allows users to create PDF signatures that comply with the PAdES B-T standard, which includes a timestamp.

In order to add support for Pades B-T, you must update the constructor of the `RQES` class to include a new `tsaUrl` parameter in the `CSCClientConfig`. This URL points to a trusted timestamp authority (TSA) service that will be used to obtain timestamps for signatures.

Also, you must set the `conformanceLevel` to `.ADES_B_T` when creating the signature request.

So, now both Pades B and Pades B-T signatures are supported.

```Swift
CalculateHashRequest.Document(
    documentInputPath: inputURL.path,
    documentOutputPath: outputURL.path,
    signatureFormat: SignatureFormat.P,
    conformanceLevel: ConformanceLevel.ADES_B_T,
    signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
    container: "No"
)
```

#### 🔁 Previous (R3)

```Swift
let cscClientConfig = CSCClientConfig(
    OAuth2Client: CSCClientConfig.OAuth2Client(
        clientId: "wallet-client",
        clientSecret: "somesecret2"
    ),
    authFlowRedirectionURI: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
    scaBaseURL: "https://walletcentric.signer.eudiw.dev"
)
self.rqes = await RQES(cscClientConfig: cscClientConfig)
```

#### ✅ Now (R5)

```Swift
let cscClientConfig = CSCClientConfig(
    OAuth2Client: CSCClientConfig.OAuth2Client(
        clientId: "wallet-client",
        clientSecret: "somesecret2"
    ),
    authFlowRedirectionURI: "https://walletcentric.signer.eudiw.dev/tester/oauth/login/code",
    scaBaseURL: "https://walletcentric.signer.eudiw.dev",
    tsaUrl: "http://ts.cartaodecidadao.pt/tsa/server"
)
self.rqes = await RQES(cscClientConfig: cscClientConfig)
```





## [R5] - 2025-21-5 - Refactoring Hash & PDF Signing Flow

### 🔄 Changed
In **R5**, major architectural changes were introduced in the **PDF hash calculation**, **signature embedding**, and final signed PDF creation flows — specifically affecting the `calculateDocumentHashes` and `getSignedDocuments` methods. These operations, which were previously handled via external services, are now executed locally on the device. **All other functionality remains unchanged**.


---

### 🧮 Hash Calculation (Local)

#### 🔁 Previous (R3)

In R3, calculating PDF document hashes required sending the **base64-encoded PDF** to a remote service via `calculateDocumentHashes(...)`, along with an access token for authorization.

**Example:**
```swift
let calculateHashRequest = CalculateHashRequest(
    documents: [
        CalculateHashRequest.Document(
            document: pdfDocument!,
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
    ],
    endEntityCertificate: (credentialInfoResponse.cert?.certificates?[0])!,
    certificateChain: [(credentialInfoResponse.cert?.certificates?[1])!],
    hashAlgorithmOID: HashAlgorithmOID.SHA256
)

let documentDigests = try await rqes.calculateDocumentHashes(
    request: calculateHashRequest,
    accessToken: accessTokenResponse.accessToken
)
```

---

#### ✅ Now (R5)

In R5, the calculation is fully **offline** and operates on **file paths** instead of base64 data. There is no need to pass an access token.

**New Example:**
```swift
let calculateHashRequest = CalculateHashRequest(
    documents: [
        CalculateHashRequest.Document(
            documentInputPath: inputURL.path,
            documentOutputPath: outputURL.path,
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
    ],
    endEntityCertificate: self.endEntityCertificate,
    certificateChain: self.certificateChain,
    hashAlgorithmOID: HashAlgorithmOID.SHA256
)

let documentDigests = try await rqes.calculateDocumentHashes(request: calculateHashRequest)
```

---

### 🖋️ Signed Document Creation

#### 🔁 Previous (R3)

Signed PDF generation was handled remotely. The request object included the base64 document and required an access token.

**Example:**
```swift
let obtainSignedDocRequest = ObtainSignedDocRequest(
    documents: [
        ObtainSignedDocRequest.Document(
            document: pdfDocument!,
            signatureFormat: SignatureFormat.P,
            conformanceLevel: ConformanceLevel.ADES_B_B,
            signedEnvelopeProperty: SignedEnvelopeProperty.ENVELOPED,
            container: "No"
        )
    ],
    endEntityCertificate: credentialInfoResponse.cert?.certificates?.first ?? "",
    certificateChain: credentialInfoResponse.cert?.certificates?.dropFirst().map { $0 } ?? [],
    hashAlgorithmOID: HashAlgorithmOID.SHA256,
    date: documentDigests.signatureDate,
    signatures: signHashResponse.signatures ?? []
)

let signedDocuments = try await rqes.getSignedDocuments(request: obtainSignedDocRequest, accessToken: accessCredentialTokenResponse.accessToken)
```

---

#### ✅ Now (R5)

The signed document is created **locally** by embedding the provided `signatures` into the original document. The method directly writes the result to the declared `documentOutputPath`. The method `getSignedDocuments` has been renamed to `createSignedDocuments`.

**New Example:**
```swift
let signatures = signHashResponse.signatures

try await rqes.createSignedDocuments(signatures: signatures!)
```

This embeds each `signature` into the respective input PDF (using `documentInputPath`) and creates the final signed document at `documentOutputPath`.

---



### ✅ Summary of Improvements

| Feature                            | R3 (Remote)                                       | R5 (Local)                                  |
|------------------------------------|--------------------------------------------------|---------------------------------------------|
| PDF Handling                       | Base64                                           | File Paths                                   |
| Access Token Required              | ✅ Yes                                            | ❌ No                                        |
| Hash Calculation                   | Remote API                                       | Local Processing                             |
| Signature Embedding & PDF Creation | Remote API                                       | Local Processing                             |
| Output Format                      | Base64-encoded Signed PDF                        | Written to `documentOutputPath`             |
