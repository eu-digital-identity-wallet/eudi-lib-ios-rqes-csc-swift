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


private final class MockService: Equatable, Sendable {
    let id = UUID()
    static func == (lhs: MockService, rhs: MockService) -> Bool {
        lhs.id == rhs.id
    }
}

private final class AnotherMockService: Sendable {}

final class ServiceLocatorTests: XCTestCase {

    var serviceLocator: ServiceLocator!

    override func setUp() {
        super.setUp()
        serviceLocator = ServiceLocator.shared
    }

    override func tearDown() async throws {
        await serviceLocator.reset()
        serviceLocator = nil
        try await super.tearDown()
    }

    func testRegisterAndResolve_WhenServiceIsRegistered_ItIsResolvedSuccessfully() async {
        let service = MockService()

        await serviceLocator.register(service: service)
        let resolvedService: MockService? = await serviceLocator.resolve()

        XCTAssertNotNil(resolvedService, "Resolved service should not be nil")
        XCTAssertEqual(resolvedService, service, "Resolved service should be the same instance that was registered")
        XCTAssertTrue(resolvedService === service, "Resolved service should be the identical instance")
    }

    func testResolve_WhenServiceNotRegistered_ReturnsNil() async {
        let resolvedService: MockService? = await serviceLocator.resolve()

        XCTAssertNil(resolvedService, "Resolving an unregistered service should return nil")
    }

    func testReset_WhenCalled_RemovesAllRegisteredServices() async {
        let service = MockService()
        await serviceLocator.register(service: service)

        var resolvedService: MockService? = await serviceLocator.resolve()
        XCTAssertNotNil(resolvedService, "Service should be present before reset")

        await serviceLocator.reset()

        resolvedService = await serviceLocator.resolve()
        XCTAssertNil(resolvedService, "Service should be nil after reset")
    }

    func testRegister_WhenRegisteringMultipleDifferentServices_TheyAreResolvedCorrectly() async {
        let serviceA = MockService()
        let serviceB = AnotherMockService()

        await serviceLocator.register(service: serviceA)
        await serviceLocator.register(service: serviceB)

        let resolvedServiceA: MockService? = await serviceLocator.resolve()
        XCTAssertTrue(resolvedServiceA === serviceA, "First service should resolve to its correct instance")

        let resolvedServiceB: AnotherMockService? = await serviceLocator.resolve()
        XCTAssertTrue(resolvedServiceB === serviceB, "Second service should resolve to its correct instance")
    }

    func testRegister_WhenRegisteringSameTypeTwice_LastOneOverwrites() async {
        let firstService = MockService()
        let secondService = MockService()

        await serviceLocator.register(service: firstService)
        await serviceLocator.register(service: secondService)

        let resolvedService: MockService? = await serviceLocator.resolve()
        XCTAssertNotNil(resolvedService)
        XCTAssertTrue(resolvedService === secondService, "Resolved service should be the second instance")
        XCTAssertFalse(resolvedService === firstService, "Resolved service should not be the first instance")
    }
   
} 
