import RIBs

protocol MemosDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var email: String { get }
}

final class MemosComponent: Component<MemosDependency>, AddMemoDependency {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    fileprivate var email: String {
        return dependency.email
    }
}

// MARK: - Builder

protocol MemosBuildable: Buildable {
    func build(withListener listener: MemosListener) -> MemosRouting
}

final class MemosBuilder: Builder<MemosDependency>, MemosBuildable {

    override init(dependency: MemosDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MemosListener) -> MemosRouting {
        let component = MemosComponent(dependency: dependency)
        let viewController = MemosViewController.instantiate(with: component.email)
        let interactor = MemosInteractor(presenter: viewController)
        interactor.listener = listener
        let addMemoBuilder = AddMemoBuilder(dependency: component)
        return MemosRouter(interactor: interactor,
                           viewController: viewController,
                           addMemoBuilder: addMemoBuilder)
    }
}
