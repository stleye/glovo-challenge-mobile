//
//  Cities.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 19/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation

struct City: Decodable {
    private let working_area: [String]
    let code: String
    let name: String
    let country_code: String
    func workingAreas() -> [WorkingArea] {
        let notEmptyWorkingAreas = working_area.filter { (encoded) -> Bool in !encoded.isEmpty }
        return notEmptyWorkingAreas.map{(encodedWorkingArea) -> WorkingArea in WorkingArea(fromEncoded: encodedWorkingArea)}
    }
}

class Cities: JsonFetcher {

    override internal class func decodeJsonFromData(_ data: Data) throws -> JsonArray {
        return try JsonArray(from: JSONDecoder().decode([City].self, from: data))
    }

    override internal class func url() -> String {
        return "\(super.url())/cities/"
    }

}
