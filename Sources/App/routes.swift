import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let todoController = TodoController()   
    router.get("getTickers", use: todoController.getTickers)
}
