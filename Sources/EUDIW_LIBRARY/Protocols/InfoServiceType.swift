import Foundation

public protocol InfoServiceType {
    func getInfo(request: InfoServiceRequest?) async throws -> InfoServiceResponse
}
