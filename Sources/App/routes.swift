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

struct Ticker: Content, Codable {
    
    let symbol: String
    let price: Double
    let change: Double
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

    
    router.get("example") { req -> Future<[Ticker]> in
        
        
        let res = try req.client().get("https://api.newdex.io/v1/ticker/all")
        
        return res.flatMap({ response -> EventLoopFuture<[Ticker]> in
            
            let a = try response.content.decode(ExampleData.self)
            
            var eosPrice: Double = 0
            var eosChange: Double = 0
            
            _ = a.map({ datas -> Void in
                
                let eos = datas.data.filter{$0.currency == "EOS"}.first!
                eosPrice = eos.last
                eosChange = eos.change
            })
            
            
            let q = a.map({ (ed) -> [Ticker] in
                
                let resp = ed.data.filter{$0.symbol.suffix(3) == "eos"}.map({ data -> Ticker in
                    
                    let tickerPrice = data.last * eosPrice
                    
                    let yesterdayPrice = (eosPrice / (1 + eosChange)) * (data.last / (1 + data.change))
                    
                    let tickerChange = (tickerPrice - yesterdayPrice) / yesterdayPrice
                    
                    let newData = Ticker(symbol: data.currency, price: tickerPrice, change: tickerChange)
                    
                    return newData
                    
                })
                return resp
                
            })
            

            return q
            
//
//            let resp = tickers.filter{$0.symbol.suffix(3) == "eos"}.map({ data -> Ticker in
//
//                let tickerPrice = data.last * eosPrice
//
//                let yesterdayPrice = (eosPrice / (1 + eosChange)) * (data.last / (1 + data.change))
//
//                let tickerChange = (tickerPrice - yesterdayPrice) / yesterdayPrice
//
//                let newData = Ticker(symbol: data.currency, price: tickerPrice, change: tickerChange)
//
//                return newData
//
//            })
//
//
//
//
//
//
//
//            return ccc
            
            
        
            
//            let c = a.map({ datas -> Ticker in
//
//
//               let resp = datas.data.filter{$0.symbol.suffix(3) == "eos"}.map({ data -> Ticker in
//
//                    let tickerPrice = data.last * eosPrice
//
//                    let yesterdayPrice = (eosPrice / (1 + eosChange)) * (data.last / (1 + data.change))
//
//                    let tickerChange = (tickerPrice - yesterdayPrice) / yesterdayPrice
//
//                    let newData = Ticker(symbol: data.currency, price: tickerPrice, change: tickerChange)
//
//                    return newData
//
//                })
//
//                return resp
//
//
//            })
//
//            return c
            
        
            
//            _ = a.filter{($0["symbol"] as! String).suffix(3) == "eos"}.map({ val -> Void in
//
//                if let price = val["last"] as? Double, let change = val["change"] as? Double, let symbol = val["currency"] as? String {
//
//                    let tickerPrice = price * eosPrice
//
//                    let yesterdayPrice = (eosPrice / (1 + eosChange)) * (price / (1 + change))
//
//                    let tickerChange = (tickerPrice - yesterdayPrice) / yesterdayPrice
//
//
//                    let dict = ["price" : tickerPrice,
//                                "change" : tickerChange]
//
//                    tickers[symbol] = dict as Any
//                }
//            })
            
            
            
            
            
//            return b
            
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
