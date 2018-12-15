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
    let priceUSD: Double
    let changeUSD: Double
    let priceBTC: Double
    let changeBTC: Double
}

struct BitcoinResponse: Content, Codable {
    let data: Bitcoin
    let timestamp: Int64
}

struct Bitcoin: Content, Codable {
    
    let id: String
    let rank: String
    let symbol: String
    let name: String
    let supply: String
    let maxSupply: String
    let marketCapUsd: String
    let volumeUsd24Hr: String
    let priceUsd: String
    let changePercent24Hr: String
    let vwap24Hr: String
    
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

    
//    router.get("example") { req -> Future<[Ticker]> in
//
//
//        let res = try req.client().get("https://api.newdex.io/v1/ticker/all")
//
//        return res.flatMap({ response -> EventLoopFuture<[Ticker]> in
//
//            let a = try response.content.decode(ExampleData.self)
//
//            var eosPrice: Double = 0
//            var eosChange: Double = 0
//
//            _ = a.map({ datas -> Void in
//
//                let eos = datas.data.filter{$0.currency == "EOS"}.first!
//                eosPrice = eos.last
//                eosChange = eos.change
//            })
//
//
//            let q = a.map({ (ed) -> [Ticker] in
//
//                let resp = ed.data.filter{$0.symbol.suffix(3) == "eos"}.map({ data -> Ticker in
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
//                return resp
//
//            })
//
//
//            return q
//
//
//        })
//    }
    
    router.get("tickers") { req -> Future<[Ticker]> in
        
        var bitcoin: Bitcoin!
        
        let bitRes = try req.client().get("https://api.coincap.io/v2/assets/bitcoin")
        
        return bitRes.flatMap({ resp -> EventLoopFuture<[Ticker]> in
            let bitcoinResp = try resp.content.decode(BitcoinResponse.self)
            
            return bitcoinResp.flatMap({ bitok -> EventLoopFuture<[Ticker]> in
                bitcoin = bitok.data
                
                let btcPrice = Double(bitcoin.priceUsd) ?? 0
                let btcChange = Double(bitcoin.changePercent24Hr) ?? 0
                
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
                        
                        let resp = ed.data.filter{$0.symbol.suffix(3) == "eos" || $0.contract == "eosio.token"}.map({ data -> Ticker in
                            
                            if data.contract == "eosio.token" {
                                //EOS
                                let tickerPrice = eosPrice
                                let tickerPriceBTC = tickerPrice / btcPrice
                                let tickerChange = eosChange
                                
                                
                                let yesterdayPrice = (eosPrice / (1 + eosChange))
                                
                                let yesterdayPriceBTC = btcPrice / (1 + btcChange / 100)
                                let yesterdayAssetPriceBTC = yesterdayPrice / yesterdayPriceBTC
                                
                                let tickerChangeBTC = (tickerPriceBTC - yesterdayAssetPriceBTC) / yesterdayAssetPriceBTC
                                
                                let newData = Ticker(symbol: data.currency, priceUSD: tickerPrice, changeUSD: tickerChange, priceBTC: tickerPriceBTC, changeBTC: tickerChangeBTC)
                                return newData
                                
                            } else {
                                let tickerPrice = data.last * eosPrice
                                let tickerPriceBTC = tickerPrice / btcPrice
                                
                                let yesterdayPrice = (eosPrice / (1 + eosChange)) * (data.last / (1 + data.change))
                                
                                let tickerChange = (tickerPrice - yesterdayPrice) / yesterdayPrice
                                
                                let yesterdayPriceBTC = btcPrice / (1 + btcChange / 100)
                                let yesterdayAssetPriceBTC = yesterdayPrice / yesterdayPriceBTC
                                
                                let tickerChangeBTC = (tickerPriceBTC - yesterdayAssetPriceBTC) / yesterdayAssetPriceBTC
                                
                                let newData = Ticker(symbol: data.currency, priceUSD: tickerPrice, changeUSD: tickerChange, priceBTC: tickerPriceBTC, changeBTC: tickerChangeBTC)
                                
                                return newData
                            }
                        })
                        return resp
                        
                    })
                    return q
                })
            })
        })
    }
    
}
