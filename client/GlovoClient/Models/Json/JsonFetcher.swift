//
//  JsonFetcher.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 19/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation
import Alamofire

class JsonCollection {
}

class JsonArray: JsonCollection {
    var decodables: [Decodable]
    init(from decodables: [Decodable]) {
        self.decodables = decodables
    }
}

class JsonDictionary: JsonCollection {
    var decodable: Decodable
    init(from decodable: Decodable) {
        self.decodable = decodable
    }
}

class JsonFetcher {

    class func fetch(onCompletionHandler: @escaping (JsonCollection) -> Void, onErrorHandler: ((Error) -> Void)?) {
        Alamofire.request(url()).responseJSON(completionHandler: { response in
            if response.error != nil {
                onErrorHandler?(response.error!)
                return
            }
            do {
                let parsedJson = try self.parseJsonArray(data: response.data!)
                onCompletionHandler(parsedJson)
            } catch let jsonError {
                onErrorHandler?(jsonError)
            }
        })
    }

    class internal func url() -> String {
        return "http://localhost:3000/api"
    }

    class internal func parseJsonArray(data: Data) throws -> JsonCollection {
        do {
            let parsedJson = try decodeJsonFromData(data)
            return parsedJson
        } catch let error {
            throw error
        }
    }

    class internal func decodeJsonFromData(_ data: Data) throws -> JsonCollection {
        fatalError("Must override")
    }

}
