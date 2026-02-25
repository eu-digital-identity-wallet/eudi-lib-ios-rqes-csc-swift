# EUDI RQES CSC Library - Architecture Documentation

This document provides architectural diagrams for the EUDI iOS Remote Qualified Electronic Signature (RQES) library implementing the CSC API v2.0.

---

## 1. High-Level Architecture

```mermaid
graph TB
    subgraph "iOS Application"
        APP[Wallet App]
    end

    subgraph "RQES Library"
        RQES[RQES<br/>Main Entry Point]

        subgraph "Core Services"
            INFO[InfoService]
            OAUTH[OAuth2TokenService]
            CRED_LIST[CredentialsListService]
            CRED_INFO[CredentialsInfoService]
            SIGN[SignHashService]
            PREP_AUTH[PrepareAuthorizationRequestService]
        end

        subgraph "PDF Engine"
            PODOFO[PodofoManager]
            TS[TimestampService]
            REV[RevocationService]
        end

        subgraph "Document Retrieval Module"
            DOC_RET[DocumentRetrieval]
            AUTH_RES[AuthorizationRequestResolver]
            DISPATCH[Dispatcher]
        end

        subgraph "Security"
            PKCE[PKCEManager]
            PKCE_STATE[PKCEState]
        end
    end

    subgraph "External Services"
        RSSP[RSSP<br/>Remote Signing Service Provider]
        TSA[TSA<br/>Timestamp Authority]
        OCSP[OCSP Responder]
        CRL[CRL Distribution Point]
        VERIFIER[Verifier/Relying Party]
    end

    APP --> RQES
    APP --> DOC_RET

    RQES --> INFO
    RQES --> OAUTH
    RQES --> CRED_LIST
    RQES --> CRED_INFO
    RQES --> SIGN
    RQES --> PREP_AUTH
    RQES --> PODOFO

    PODOFO --> TS
    PODOFO --> REV

    PREP_AUTH --> PKCE
    PKCE --> PKCE_STATE

    DOC_RET --> AUTH_RES
    DOC_RET --> DISPATCH

    INFO --> RSSP
    OAUTH --> RSSP
    CRED_LIST --> RSSP
    CRED_INFO --> RSSP
    SIGN --> RSSP

    TS --> TSA
    REV --> OCSP
    REV --> CRL

    DISPATCH --> VERIFIER
```

---

## 2. Component Diagram

```mermaid
graph LR
    subgraph "Sources"
        subgraph "Main"
            M_RQES[RQES.swift]
        end

        subgraph "Services Layer"
            S_INFO[InfoService]
            S_OAUTH[OAuth2TokenService]
            S_CRED_LIST[CredentialsListService]
            S_CRED_INFO[CredentialsInfoService]
            S_SIGN[SignHashService]
            S_PREP[PrepareAuthorizationRequestService]
            S_TS[TimestampService]
            S_REV[RevocationService]
        end

        subgraph "HTTP Clients"
            H_INFO[InfoClient]
            H_TOKEN[OAuth2TokenClient]
            H_CRED_LIST[CredentialsListClient]
            H_CRED_INFO[CredentialsInfoClient]
            H_SIGN[SignHashClient]
            H_TS[TimestampClient]
            H_OCSP[OcspClient]
            H_CRL[CrlClient]
            H_CERT[CertificateClient]
        end

        subgraph "PodofoManager"
            P_MGR[PodofoManager]
            P_WRAP[PodofoWrapper<br/>PoDoFo C++ Bridge]
        end

        subgraph "Document Retrieval"
            DR_MAIN[DocumentRetrieval]
            DR_RES[AuthorizationRequestResolver]
            DR_DISP[Dispatcher]
            DR_FETCH[RequestFetcher]
            DR_AUTH[ClientAuthenticator]
            DR_REQ_AUTH[RequestAuthenticator]
            DR_VALID[Validators]
            DR_VERIFY[JWSPublicKeyVerifier]
        end

        subgraph "Security/PKCE"
            SEC_MGR[PKCEManager]
            SEC_STATE[PKCEState]
        end

        subgraph "Protocols"
            P_INFO[InfoServiceType]
            P_OAUTH[OAuth2TokenServiceType]
            P_HTTP[HTTPClientType]
            P_SIGN[SignHashServiceType]
            P_CRED[CredentialsListServiceType]
        end

        subgraph "Models"
            subgraph "Requests"
                REQ_TOKEN[AccessTokenRequest]
                REQ_HASH[CalculateHashRequest]
                REQ_SIGN[SignHashRequest]
                REQ_CRED[CredentialsListRequest]
                REQ_CONFIG[CSCClientConfig]
            end

            subgraph "Responses"
                RES_TOKEN[AccessTokenResponse]
                RES_INFO[InfoServiceResponse]
                RES_SIGN[SignHashResponse]
                RES_CRED[CredentialsListResponse]
                RES_DIGEST[DocumentDigests]
            end
        end
    end

    M_RQES --> S_INFO
    M_RQES --> S_OAUTH
    M_RQES --> S_CRED_LIST
    M_RQES --> S_CRED_INFO
    M_RQES --> S_SIGN
    M_RQES --> S_PREP
    M_RQES --> P_MGR

    S_INFO --> H_INFO
    S_OAUTH --> H_TOKEN
    S_CRED_LIST --> H_CRED_LIST
    S_CRED_INFO --> H_CRED_INFO
    S_SIGN --> H_SIGN

    P_MGR --> S_TS
    P_MGR --> S_REV
    P_MGR --> P_WRAP

    S_TS --> H_TS
    S_REV --> H_OCSP
    S_REV --> H_CRL
    S_REV --> H_CERT

    S_PREP --> SEC_MGR
    SEC_MGR --> SEC_STATE

    DR_MAIN --> DR_RES
    DR_MAIN --> DR_DISP
    DR_RES --> DR_FETCH
    DR_RES --> DR_AUTH
    DR_RES --> DR_REQ_AUTH
    DR_RES --> DR_VALID
    DR_REQ_AUTH --> DR_VERIFY
```

---

## 3. Main Signing Flow - Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant App as iOS App
    participant RQES as RQES
    participant PrepAuth as PrepareAuthorizationRequestService
    participant PKCE as PKCEState
    participant OAuth as OAuth2TokenService
    participant CredList as CredentialsListService
    participant PodoFo as PodofoManager
    participant SignHash as SignHashService
    participant RSSP as RSSP Server
    participant TSA as Timestamp Authority
    participant Browser as Browser/WebView

    Note over App, TSA: Phase 1: Service Authorization (OAuth2 + PKCE)

    App->>RQES: prepareServiceAuthorizationRequest(walletState)
    RQES->>RSSP: GET /info
    RSSP-->>RQES: InfoServiceResponse (oauth2 URL)
    RQES->>PrepAuth: prepareServiceRequest()
    PrepAuth->>PKCE: initializeAndGetCodeChallenge()
    PKCE-->>PrepAuth: codeChallenge (S256)
    PrepAuth-->>RQES: AuthorizationPrepareResponse (authURL)
    RQES-->>App: authorizationCodeURL

    App->>Browser: Open authorization URL
    Browser->>RSSP: Authorization Request
    RSSP-->>Browser: Login Page
    Browser->>RSSP: User Credentials
    RSSP-->>Browser: Redirect with code
    Browser-->>App: Authorization Code

    App->>RQES: requestAccessTokenAuthFlow(code, state)
    RQES->>OAuth: getToken(request)
    OAuth->>PKCE: getCodeVerifier()
    PKCE-->>OAuth: codeVerifier
    OAuth->>RSSP: POST /oauth2/token (code + verifier)
    RSSP-->>OAuth: AccessTokenResponse
    OAuth-->>RQES: accessToken
    RQES-->>App: AccessTokenResponse

    Note over App, TSA: Phase 2: List & Select Credentials

    App->>RQES: listCredentials(request, accessToken)
    RQES->>CredList: getCredentialsList()
    CredList->>RSSP: POST /credentials/list
    RSSP-->>CredList: CredentialsListResponse
    CredList-->>RQES: credentials + certificates
    RQES-->>App: CredentialsListResponse

    Note over App, TSA: Phase 3: Calculate Document Hashes

    App->>RQES: calculateDocumentHashes(request)
    RQES->>PodoFo: calculateDocumentHashes(docs, cert, chain)
    PodoFo->>PodoFo: PodofoWrapper.calculateHash()
    PodoFo-->>RQES: DocumentDigests (hashes)
    RQES-->>App: hashes[]

    Note over App, TSA: Phase 4: Credential Authorization

    App->>RQES: prepareCredentialAuthorizationRequest(walletState, authDetails)
    RQES->>PrepAuth: prepareCredentialRequest()
    PrepAuth->>PKCE: initializeAndGetCodeChallenge()
    PKCE-->>PrepAuth: codeChallenge
    PrepAuth-->>RQES: AuthorizationPrepareResponse
    RQES-->>App: credentialAuthURL

    App->>Browser: Open credential auth URL
    Browser->>RSSP: Credential Authorization
    RSSP-->>Browser: Confirm signing
    Browser-->>App: Credential auth code

    App->>RQES: requestAccessTokenAuthFlow(credCode)
    RQES->>OAuth: getToken()
    OAuth->>RSSP: POST /oauth2/token
    RSSP-->>OAuth: credentialAccessToken
    OAuth-->>RQES: credentialAccessToken
    RQES-->>App: AccessTokenResponse

    Note over App, TSA: Phase 5: Sign Hashes

    App->>RQES: signHash(request, credentialAccessToken)
    RQES->>SignHash: signHash()
    SignHash->>RSSP: POST /signatures/signHash
    RSSP-->>SignHash: SignHashResponse (signatures)
    SignHash-->>RQES: signatures[]
    RQES-->>App: SignHashResponse

    Note over App, TSA: Phase 6: Create Signed Documents

    App->>RQES: createSignedDocuments(signatures)
    RQES->>PodoFo: createSignedDocuments()

    alt Conformance Level B-T, B-LT, or B-LTA
        PodoFo->>TSA: Request Timestamp
        TSA-->>PodoFo: Timestamp Response
    end

    alt Conformance Level B-LT or B-LTA (with revocation info)
        PodoFo->>PodoFo: Fetch OCSP Response
        PodoFo->>PodoFo: Fetch CRL Data
    end

    alt Conformance Level B-LTA
        PodoFo->>PodoFo: beginSigningLTA()
        PodoFo->>TSA: Request Document Timestamp
        TSA-->>PodoFo: LTA Timestamp
        PodoFo->>PodoFo: finishSigningLTA()
    end

    PodoFo->>PodoFo: finalizeSigning()
    PodoFo-->>RQES: Signed PDF saved
    RQES-->>App: Success
```

---

## 4. Document Retrieval Flow - Sequence Diagram (OpenID4VP)

```mermaid
sequenceDiagram
    autonumber
    participant Verifier as Verifier/RP
    participant App as iOS Wallet App
    participant DocRet as DocumentRetrieval
    participant Parser as UnvalidatedRequest
    participant Resolver as AuthorizationRequestResolver
    participant Fetcher as RequestFetcher
    participant ClientAuth as ClientAuthenticator
    participant ReqAuth as RequestAuthenticator
    participant Validator as Validators
    participant Dispatcher as Dispatcher
    participant SignFlow as RQES Signing Flow

    Note over Verifier, SignFlow: Phase 1: Receive Authorization Request

    Verifier->>App: Authorization Request URL<br/>(QR Code / Deep Link)
    App->>DocRet: parse(url)
    DocRet->>Parser: UnvalidatedRequest.make(from: urlString)

    alt Plain Request
        Parser-->>DocRet: .plain(RequestObject)
    else JWT Pass-by-Value
        Parser-->>DocRet: .jwtSecuredPassByValue(clientId, jwt)
    else JWT Pass-by-Reference
        Parser-->>DocRet: .jwtSecuredPassByReference(clientId, jwtURI)
    end

    DocRet-->>App: Result<UnvalidatedRequest, Error>

    Note over Verifier, SignFlow: Phase 2: Resolve & Validate Request

    App->>DocRet: resolve(config, unvalidatedRequest)
    DocRet->>Resolver: resolve()

    Resolver->>Fetcher: fetchRequest(unvalidatedRequest)

    alt JWT Pass-by-Reference
        Fetcher->>Verifier: GET request_uri
        Verifier-->>Fetcher: JWT
    end

    Fetcher-->>Resolver: FetchedRequest

    Resolver->>ClientAuth: Create ClientAuthenticator
    Resolver->>ReqAuth: Create RequestAuthenticator

    Resolver->>ReqAuth: authenticate(fetchedRequest)
    ReqAuth->>ClientAuth: authenticateClient()

    alt X.509 SAN DNS Scheme
        ClientAuth->>ClientAuth: Verify X.509 Certificate
        ClientAuth->>ClientAuth: Extract SAN DNS
    else Pre-registered Client
        ClientAuth->>ClientAuth: Lookup client_id
    end

    ClientAuth-->>ReqAuth: AuthenticatedClient

    ReqAuth->>Validator: Validate JWT Claims
    Validator->>Validator: Verify Signature
    Validator->>Validator: Check Expiry
    Validator->>Validator: Validate Nonce
    Validator-->>ReqAuth: Valid

    ReqAuth-->>Resolver: AuthenticatedRequest

    Resolver->>Resolver: Validate Response Type (vp_token)
    Resolver->>Resolver: Validate Nonce Present

    Resolver->>ReqAuth: createValidatedData()
    ReqAuth-->>Resolver: ValidatedRequestData

    Resolver->>Resolver: resolveRequest()
    Resolver-->>DocRet: ResolvedRequestData

    alt Plain Request
        DocRet-->>App: AuthorizationRequest.notSecured(data)
    else JWT Secured
        DocRet-->>App: AuthorizationRequest.jwt(request)
    end

    Note over Verifier, SignFlow: Phase 3: Extract Document Info & Sign

    App->>App: Extract from ResolvedRequestData:<br/>- documentDigests<br/>- documentLocations<br/>- hashAlgorithmOID<br/>- signatureQualifier

    opt Document Locations Present
        App->>Verifier: Fetch documents from locations
        Verifier-->>App: Documents
    end

    App->>SignFlow: Perform RQES Signing Flow<br/>(See Main Signing Sequence)
    SignFlow-->>App: Signed Documents / Signatures

    Note over Verifier, SignFlow: Phase 4: Dispatch Response

    App->>DocRet: dispatch(poster, resolvedData, consent)
    DocRet->>Dispatcher: dispatch()

    alt Positive Consent
        Dispatcher->>Dispatcher: Create success payload<br/>(documentWithSignature, signatureObject)
    else Negative Consent
        Dispatcher->>Dispatcher: Create error payload<br/>(user_cancelled)
    end

    Dispatcher->>Dispatcher: Build DirectPost form
    Dispatcher->>Verifier: POST response_uri<br/>(application/x-www-form-urlencoded)

    alt Success (HTTP 200)
        Verifier-->>Dispatcher: { redirect_uri: "..." }
        Dispatcher-->>DocRet: DispatchOutcome.accepted(redirectURI)
    else Failure
        Verifier-->>Dispatcher: Error response
        Dispatcher-->>DocRet: DispatchOutcome.rejected(reason)
    end

    DocRet-->>App: DispatchOutcome

    opt Redirect URI Present
        App->>App: Navigate to redirect_uri
    end
```

---

## 5. Signature Conformance Levels

```mermaid
graph TB
    subgraph "Conformance Levels"
        BB[ADES_B_B<br/>Basic Signature]
        BT[ADES_B_T<br/>With Timestamp]
        BLT[ADES_B_LT<br/>Long-Term Validation]
        BLTA[ADES_B_LTA<br/>Long-Term Archival]
    end

    subgraph "Components Added"
        SIG[Digital Signature]
        TS[Timestamp Token]
        OCSP_DATA[OCSP Response]
        CRL_DATA[CRL Data]
        CERTS[Validation Certificates]
        LTA_TS[LTA Document Timestamp]
    end

    BB --> SIG

    BT --> SIG
    BT --> TS

    BLT --> SIG
    BLT --> TS
    BLT --> OCSP_DATA
    BLT --> CRL_DATA
    BLT --> CERTS

    BLTA --> SIG
    BLTA --> TS
    BLTA --> OCSP_DATA
    BLTA --> CRL_DATA
    BLTA --> CERTS
    BLTA --> LTA_TS
```

---

## 6. Document Retrieval - Request Types

```mermaid
graph TB
    subgraph "UnvalidatedRequest Types"
        PLAIN[Plain Request<br/>Query parameters only]
        JWT_VAL[JWT Pass-by-Value<br/>request=JWT]
        JWT_REF[JWT Pass-by-Reference<br/>request_uri=URL]
    end

    subgraph "Processing"
        PARSE[Parse URL]
        FETCH[Fetch JWT from URI]
        DECODE[Decode JWT]
        VERIFY[Verify Signature]
        VALIDATE[Validate Claims]
    end

    subgraph "Output"
        AUTH_REQ[AuthorizationRequest]
        NOT_SEC[.notSecured]
        JWT_SEC[.jwt]
        INVALID[.invalidResolution]
    end

    PLAIN --> PARSE
    PARSE --> VALIDATE
    VALIDATE --> AUTH_REQ
    AUTH_REQ --> NOT_SEC

    JWT_VAL --> PARSE
    PARSE --> DECODE
    DECODE --> VERIFY
    VERIFY --> VALIDATE
    VALIDATE --> AUTH_REQ
    AUTH_REQ --> JWT_SEC

    JWT_REF --> PARSE
    PARSE --> FETCH
    FETCH --> DECODE
    DECODE --> VERIFY
    VERIFY --> VALIDATE
    VALIDATE --> AUTH_REQ
    AUTH_REQ --> JWT_SEC

    VALIDATE -.->|Error| INVALID
```

---

## 7. Dependency Injection Architecture

```mermaid
graph TB
    subgraph "ServiceLocator Pattern"
        SL[ServiceLocator<br/>Actor Singleton]

        subgraph "Registered Services"
            REG_INFO[InfoServiceType]
            REG_OAUTH[OAuth2TokenServiceType]
            REG_CRED_LIST[CredentialsListServiceType]
            REG_CRED_INFO[CredentialsInfoServiceType]
            REG_SIGN[SignHashServiceType]
            REG_PREP[PrepareAuthorizationRequestServiceType]
        end
    end

    subgraph "Default Implementations"
        IMP_INFO[InfoService]
        IMP_OAUTH[OAuth2TokenService]
        IMP_CRED_LIST[CredentialsListService]
        IMP_CRED_INFO[CredentialsInfoService]
        IMP_SIGN[SignHashService]
        IMP_PREP[PrepareAuthorizationRequestService]
    end

    subgraph "Consumer"
        RQES[RQES<br/>Main Class]
    end

    SL --> REG_INFO
    SL --> REG_OAUTH
    SL --> REG_CRED_LIST
    SL --> REG_CRED_INFO
    SL --> REG_SIGN
    SL --> REG_PREP

    REG_INFO -.->|default| IMP_INFO
    REG_OAUTH -.->|default| IMP_OAUTH
    REG_CRED_LIST -.->|default| IMP_CRED_LIST
    REG_CRED_INFO -.->|default| IMP_CRED_INFO
    REG_SIGN -.->|default| IMP_SIGN
    REG_PREP -.->|default| IMP_PREP

    RQES -->|resolve| SL
```

---

## 8. HTTP Client Layer

```mermaid
graph LR
    subgraph "HTTP Clients"
        direction TB
        INFO_C[InfoClient]
        TOKEN_C[OAuth2TokenClient]
        CRED_LIST_C[CredentialsListClient]
        CRED_INFO_C[CredentialsInfoClient]
        SIGN_C[SignHashClient]
        TS_C[TimestampClient]
        OCSP_C[OcspClient]
        CRL_C[CrlClient]
        CERT_C[CertificateClient]
    end

    subgraph "Protocol"
        HTTP[HTTPClientType]
    end

    subgraph "Implementation"
        HTTP_SVC[HTTPService]
        URL_SESS[URLSession]
    end

    subgraph "Endpoints"
        INFO_E[/csc/v2/info]
        TOKEN_E[/oauth2/token]
        CRED_LIST_E[/csc/v2/credentials/list]
        CRED_INFO_E[/csc/v2/credentials/info]
        SIGN_E[/csc/v2/signatures/signHash]
        TSA_E[TSA Server]
        OCSP_E[OCSP Responder]
        CRL_E[CRL DP]
    end

    INFO_C --> HTTP
    TOKEN_C --> HTTP
    CRED_LIST_C --> HTTP
    CRED_INFO_C --> HTTP
    SIGN_C --> HTTP
    TS_C --> HTTP
    OCSP_C --> HTTP
    CRL_C --> HTTP
    CERT_C --> HTTP

    HTTP --> HTTP_SVC
    HTTP_SVC --> URL_SESS

    INFO_C -.-> INFO_E
    TOKEN_C -.-> TOKEN_E
    CRED_LIST_C -.-> CRED_LIST_E
    CRED_INFO_C -.-> CRED_INFO_E
    SIGN_C -.-> SIGN_E
    TS_C -.-> TSA_E
    OCSP_C -.-> OCSP_E
    CRL_C -.-> CRL_E
```

---

## 9. Complete End-to-End Flow (Document Retrieval + Signing)

```mermaid
sequenceDiagram
    autonumber
    participant RP as Relying Party<br/>(Verifier)
    participant Wallet as iOS Wallet
    participant DocRet as DocumentRetrieval
    participant RQES as RQES
    participant RSSP as RSSP
    participant TSA as TSA

    Note over RP, TSA: 1. Authorization Request Initiation
    RP->>Wallet: Authorization Request<br/>(QR/Deep Link)

    Note over RP, TSA: 2. Parse & Resolve Request
    Wallet->>DocRet: parse(url)
    DocRet-->>Wallet: UnvalidatedRequest
    Wallet->>DocRet: resolve(config, request)
    DocRet-->>Wallet: ResolvedRequestData<br/>(documentDigests, documentLocations, etc.)

    Note over RP, TSA: 3. OAuth2 Service Authorization
    Wallet->>RQES: prepareServiceAuthorizationRequest()
    RQES-->>Wallet: authorizationCodeURL
    Wallet->>RSSP: OAuth2 Authorization
    RSSP-->>Wallet: Authorization Code
    Wallet->>RQES: requestAccessTokenAuthFlow()
    RQES-->>Wallet: Service Access Token

    Note over RP, TSA: 4. Get Credentials
    Wallet->>RQES: listCredentials()
    RQES->>RSSP: POST /credentials/list
    RSSP-->>RQES: Credentials + Certificates
    RQES-->>Wallet: CredentialsListResponse

    Note over RP, TSA: 5. Prepare Documents for Signing
    Wallet->>RQES: calculateDocumentHashes()
    RQES-->>Wallet: DocumentDigests

    Note over RP, TSA: 6. OAuth2 Credential Authorization
    Wallet->>RQES: prepareCredentialAuthorizationRequest(authDetails)
    RQES-->>Wallet: credentialAuthURL
    Wallet->>RSSP: Credential Authorization
    RSSP-->>Wallet: Credential Code
    Wallet->>RQES: requestAccessTokenAuthFlow()
    RQES-->>Wallet: Credential Access Token

    Note over RP, TSA: 7. Sign Document Hashes
    Wallet->>RQES: signHash(hashes, credentialToken)
    RQES->>RSSP: POST /signatures/signHash
    RSSP-->>RQES: Signatures
    RQES-->>Wallet: SignHashResponse

    Note over RP, TSA: 8. Finalize Signed Documents
    Wallet->>RQES: createSignedDocuments(signatures)
    RQES->>TSA: Request Timestamp
    TSA-->>RQES: Timestamp Token
    RQES-->>Wallet: Signed PDF Created

    Note over RP, TSA: 9. Dispatch Response to Verifier
    Wallet->>DocRet: dispatch(resolvedData, consent)
    DocRet->>RP: POST response_uri<br/>(documentWithSignature, signatureObject)
    RP-->>DocRet: { redirect_uri }
    DocRet-->>Wallet: DispatchOutcome.accepted

    Note over RP, TSA: 10. Complete
    Wallet->>Wallet: Navigate to redirect_uri
```

---

## Legend

| Symbol | Meaning |
|--------|---------|
| `→` | Synchronous call |
| `-->>` | Response/Return |
| `-.->` | Default/Optional relationship |
| `alt` | Alternative paths |
| `opt` | Optional block |

## Key Acronyms

| Acronym | Full Name |
|---------|-----------|
| RQES | Remote Qualified Electronic Signature |
| CSC | Cloud Signature Consortium |
| RSSP | Remote Signing Service Provider |
| TSA | Timestamp Authority |
| OCSP | Online Certificate Status Protocol |
| CRL | Certificate Revocation List |
| PKCE | Proof Key for Code Exchange |
| OpenID4VP | OpenID for Verifiable Presentations |
| RP | Relying Party |
