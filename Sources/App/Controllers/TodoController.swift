import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    
    func getTickers(_ req: Request) throws -> String {
        
        var tickers = [String : AnyObject]()
        
        let group = DispatchGroup()
        
        let url = URL(string: "https://api.newdex.io/v1/ticker/all")!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        
        group.enter()
        let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if let dat = data {
                
                do {
                    
                    if let array = try JSONSerialization.jsonObject(with: dat, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : AnyObject], let data = array["data"] as? [[String : AnyObject]] {
                        
                        let eosTicker = data.filter{($0["currency"] as! String) == "EOS"}.first
                        guard let eos = eosTicker, let eosPrice = eos["last"] as? Double, let eosChange = eos["change"] as? Double else {return}
                        
                       _ = data.filter{($0["symbol"] as! String).suffix(3) == "eos"}.map({ val -> Void in
                            
                            if let price = val["last"] as? Double, let change = val["change"] as? Double, let symbol = val["currency"] as? String {
                                
                                let tickerPrice = price * eosPrice
                                
                                let yesterdayPrice = (eosPrice / (1 + eosChange)) * (price / (1 + change))
                                
                                let tickerChange = (tickerPrice - yesterdayPrice) / yesterdayPrice
                                
                                
                                let dict = ["price" : tickerPrice,
                                            "change" : tickerChange]
                                
                                tickers[symbol] = dict as AnyObject
                            }
                        })
                        group.leave()
                    }
                } catch {
                    
                }
            }
        }
        
        mData.resume()
        
        group.wait()
        
        
        let json = try JSONSerialization.data(withJSONObject: tickers, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let str = String(data: json, encoding: .utf8)
        
        return str!
    }
    
}
