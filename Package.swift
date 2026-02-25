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

// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "eudi-lib-ios-rqes-csc-swift",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(
      name: "RQESLib",
      targets: ["RQESLib"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/airsidemobile/JOSESwift.git",
      from: "3.0.0"
    ),
    .package(
      url: "https://github.com/SwiftyJSON/SwiftyJSON.git",
      from: "5.0.1"
    ),
    .package(
      url: "https://github.com/apple/swift-certificates.git",
      .upToNextMajor(from: "1.15.0")
    ),
    .package(url: "https://github.com/eu-digital-identity-wallet/eudi-lib-podofo", exact: "0.3.8")
  ],
  targets: [
    .target(
      name: "RQESLib",
      dependencies: [
        .product(
          name: "JOSESwift",
          package: "JOSESwift"
        ),
        .product(
          name: "SwiftyJSON",
          package: "SwiftyJSON"
        ),
        .product(
          name: "X509",
          package: "swift-certificates"
        ),
        .product(name: "PoDoFo", package: "eudi-lib-podofo")
      ],
      path: "Sources",
      resources: [
        .copy("Documents")
      ],
      linkerSettings: [
        .linkedLibrary("bz2"), .linkedLibrary("c++")
      ]
    ),
    .testTarget(
      name: "RQESLibTests",
      dependencies: [
        "RQESLib",
        .product(
          name: "JOSESwift",
          package: "JOSESwift"
        ),
        .product(
          name: "SwiftyJSON",
          package: "SwiftyJSON"
        ),
      ],
      path: "Tests",
      resources: [
        .copy("fixtures/sample.pdf")
      ]
    )
  ]
)
