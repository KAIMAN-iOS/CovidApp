import UIKit

public protocol BaseCoordinatorType: class {
    associatedtype DeepLinkType
    func start()
    func start(with link: DeepLinkType?)
}

public protocol PresentableCoordinatorType: BaseCoordinatorType, Presentable {}

open class PresentableCoordinator<DeepLinkType>: NSObject, PresentableCoordinatorType {
    
    public override init() {
        super.init()
    }
    
    open func start() { start(with: nil) }
    open func start(with link: DeepLinkType?) {}
    
    open func toPresentable() -> UIViewController {
        fatalError("Must override toPresentable()")
    }
}


public protocol CoordinatorType: PresentableCoordinatorType {
    var router: RouterType { get }
}

open class Coordinator<DeepLinkType>: PresentableCoordinator<DeepLinkType>, CoordinatorType  {
    public var childCoordinators: [Coordinator<DeepLinkType>] = []
    let id: UUID = UUID()
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let coord = object as? Coordinator<DeepLinkType> else { return false }
        return coord.id == id
    }
    
    open var router: RouterType
    
    public init(router: RouterType) {
        self.router = router
        super.init()
    }
    
    public func addChild(_ coordinator: Coordinator<DeepLinkType>) {
        childCoordinators.append(coordinator)
    }
    
    public func removeChild(_ coordinator: Coordinator<DeepLinkType>?) {
        
        if let coordinator = coordinator, let index = childCoordinators.firstIndex(of: coordinator) {
            childCoordinators.remove(at: index)
        }
    }
    
    open override func toPresentable() -> UIViewController {
        return router.toPresentable()
    }
}

enum DeepLink {
    case share(userEmail: String)
    case home
    
    static var scheme: String = "covidapp"
    
    static func from(route: String) -> DeepLink? {
        //
        if let range = route.range(of: "share"), let userEmail = Optional.some(route[route.index(after: range.upperBound)..<route.endIndex]), String(userEmail).isValidEmail {
            return .share(userEmail: String(userEmail))
        }
        return nil
    }
}
