import Vapor

struct ExampleData: Content, Codable {
    var code : Int
    var data : [Datas]
}

struct Datas: Content, Codable {
    
    let symbol: String
    let contract: String
    let currency: String
    let last: Double
    let change: Double
    let high: Double
    let low: Double
    let amount: Double
    let volume: Double
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("getTickers", use: todoController.getTickers)

    
    router.get("example") { req -> Future<Datas> in
        
        
        let res = try req.client().get("https://api.newdex.io/v1/ticker/all")
        
        return res.flatMap({ response -> EventLoopFuture<Datas> in
            
            let a = try response.content.decode(ExampleData.self)
            
            let b = a.map({ datas -> Datas in
                
                return datas.data.filter{$0.currency == "EOS"}.first!
                
            })
            
            print(b)
            
            return b
            
//            return try response.content.decode(ExampleData.self)
            
            
        })
        
        
        
        
//        let client = try HTTPClient.connect(hostname: "https://api.newdex.io/v1/ticker/all", on: Application()).wait()
//        print(client) // HTTPClient
//        // Create an HTTP request: GET /
//        let httpReq = HTTPRequest(method: .GET, url: "/")
//        // Send the HTTP request, fetching a response
//        let httpRes = try client.send(httpReq).wait()
//        print(httpRes) // HTTPResponse
//        
//        
//        // Renders the `ExampleData` into a `View`
//        return ""
//            //try req.view().render("home", exampleData)

        
        
    }
    
}
