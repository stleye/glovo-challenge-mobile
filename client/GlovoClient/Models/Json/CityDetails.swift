//
//  CityDetails.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 19/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation

struct CityDetail: Decodable {
    let code: String
    let name: String
    let description: String?
    let currency: String
    let country_code: String
    let enabled: Bool
    let time_zone: String
    private let working_area: [String]
    let busy: Bool
    let language_code: String
}

class CityDetails: JsonFetcher {

    private static var cityCode: String = ""

    class func getFor(cityCode: String, onCompletionHandler: @escaping (JsonCollection) -> Void, onErrorHandler: ((Error) -> Void)?) {
        self.cityCode = cityCode
        fetch(onCompletionHandler: onCompletionHandler, onErrorHandler: onErrorHandler)
    }

    override internal class func decodeJsonFromData(_ data: Data) throws -> JsonDictionary {
        return try JsonDictionary(from: JSONDecoder().decode(CityDetail.self, from: data))
    }

    override internal class func url() -> String {
        return "\(super.url())/cities/\(self.cityCode)"
    }

}
