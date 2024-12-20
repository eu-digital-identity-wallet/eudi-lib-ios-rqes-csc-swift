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

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "RQES_LIBRARY",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(
            name: "RQES_LIBRARY",
            targets: ["RQES_LIBRARY"]),
    ],
    targets: [
        .target(
            name: "RQES_LIBRARY",
            resources: [
                .copy("Documents")
            ]
        ),
        .testTarget(
            name: "RQES_LIBRARYTests",
            dependencies: ["RQES_LIBRARY"]
        ),
    ]
)
