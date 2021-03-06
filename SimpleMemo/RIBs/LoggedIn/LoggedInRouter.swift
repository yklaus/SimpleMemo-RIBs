import RIBs

protocol LoggedInInteractable: Interactable, MemosListener {
    var router: LoggedInRouting? { get set }
    var listener: LoggedInListener? { get set }
}

protocol LoggedInViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class LoggedInRouter: Router<LoggedInInteractable>, LoggedInRouting {

    private let viewController: LoggedInViewControllable
    private let memosBuilder: MemosBuildable
    private var memosRouting: MemosRouting?
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: LoggedInInteractable,
         viewController: LoggedInViewControllable,
         memosBuilder: MemosBuildable) {
        self.viewController = viewController
        self.memosBuilder = memosBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }
    
    override func didLoad() {
        super.didLoad()
        routeToMemosRIB()
    }
    
    func routeToMemosRIB() {
        let memosRouting = memosBuilder.build(withListener: interactor)
        self.memosRouting = memosRouting
        attachChild(memosRouting)
        let navigationController = UINavigationController(root: memosRouting.viewControllable)
        viewController.present(viewController: navigationController)
    }
    
    func detachMemosRIB() {
        guard let memosRouting = memosRouting else { return }
        detachChild(memosRouting)
        if let navigationController = memosRouting.viewControllable.uiviewController.navigationController {
            viewController.dismiss(viewController: navigationController)
        } else {
            viewController.dismiss(viewController: memosRouting.viewControllable)
        }
        self.memosRouting = nil
    }
}
