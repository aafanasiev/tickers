import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    func index(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }
    
    let todoController = TodoController()   
    router.get("getTickers", use: todoController.getTickers)
}
