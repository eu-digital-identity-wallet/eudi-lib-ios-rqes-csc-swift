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
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "RQES_LIBRARY",
      targets: ["RQES_LIBRARY"]
    )
  ],
  dependencies: [
    // Only your remote PoDoFo package
    .package(
      url: "https://github.com/niscy-eudiw/eudi-podofo-lib-ios.git",
      from: "1.0.3"
    ),
  ],
  targets: [

    .target(
      name: "RQES_LIBRARY",
      dependencies: [
        .product(name: "PoDoFo", package: "eudi-podofo-lib-ios")
      ],
      path: "Sources",
      resources: [
        // bundles your Documents folder if you still need it
        .copy("Documents")
      ],
      linkerSettings: [
        // link the system BZip2 library
        .linkedLibrary("bz2")
      ]
    ),

    // 3) Your tests, bundling sample.pdf into the test bundle
    .testTarget(
      name: "RQES_LIBRARYTests",
      dependencies: ["RQES_LIBRARY"],
      path: "Tests/RQES_LIBRARYTests",
      resources: [
        .copy("sample.pdf")
      ]
    )
  ]
)
