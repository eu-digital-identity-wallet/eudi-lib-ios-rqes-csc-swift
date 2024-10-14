import Foundation

internal final actor ServiceLocator {

    internal static let shared = ServiceLocator()

    private var services: [String: AnyObject] = [:]

    private init() {}

    internal func register<T: AnyObject>(service: T) {
        let key = String(describing: T.self)
        services[key] = service
    }

    internal func resolve<T: AnyObject>() -> T? {
        let key = String(describing: T.self)
        return services[key] as? T
    }

    internal func reset() {
        services.removeAll()
    }
}
