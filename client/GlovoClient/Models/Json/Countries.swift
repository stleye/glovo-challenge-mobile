//
//  Countries.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 19/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation

struct Country: Decodable, Hashable {
    var hashValue: Int { return code.hashValue }
    let code: String
    let name: String
}

class Countries: JsonFetcher {

    override class internal func decodeJsonFromData(_ data: Data) throws -> JsonArray {
        return try JsonArray(from: JSONDecoder().decode([Country].self, from: data))
    }

    override internal class func url() -> String {
        return "\(super.url())/countries/"
    }

}
