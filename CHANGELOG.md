# 📦 Changelog

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
            document_inputPath: inputURL.path,
            document_outputPath: outputURL.path,
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

The signed document is created **locally** by embedding the provided `signatures` into the original document. The method directly writes the result to the declared `document_outputPath`. The method `getSignedDocuments` has been renamed to `createSignedDocuments`.

**New Example:**
```swift
let signatures = signHashResponse.signatures

try await rqes.createSignedDocuments(signatures: signatures!)
```

This embeds each `signature` into the respective input PDF (using `document_inputPath`) and creates the final signed document at `document_outputPath`.

---



### ✅ Summary of Improvements

| Feature                            | R3 (Remote)                                       | R5 (Local)                                  |
|------------------------------------|--------------------------------------------------|---------------------------------------------|
| PDF Handling                       | Base64                                           | File Paths                                   |
| Access Token Required              | ✅ Yes                                            | ❌ No                                        |
| Hash Calculation                   | Remote API                                       | Local Processing                             |
| Signature Embedding & PDF Creation | Remote API                                       | Local Processing                             |
| Output Format                      | Base64-encoded Signed PDF                        | Written to `document_outputPath`             |
