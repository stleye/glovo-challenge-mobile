//
//  Cities.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 19/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation
import GoogleMaps

struct City: Decodable, Hashable {
    var hashValue: Int { return code.hashValue }
    let working_area: [String]
    let code: String
    let name: String
    let country_code: String

    func workingAreas() -> [WorkingArea] {
        let notEmptyWorkingAreas = working_area.filter { (encoded) -> Bool in !encoded.isEmpty }
        return notEmptyWorkingAreas.map{(encodedWorkingArea) -> WorkingArea in WorkingArea(countryCode: country_code,
                                                                                           cityCode: code,
                                                                                           cityName: name,
                                                                                           encoded: encodedWorkingArea)}
    }

    func boundingArea() -> GMSCoordinateBounds {
        let workingAreas = self.workingAreas()
        let firstCoordinate = workingAreas.first!.coordinates.first!
        var bounds = GMSCoordinateBounds(coordinate: firstCoordinate, coordinate: firstCoordinate)
        for workingArea in workingAreas {
            for coordinate in workingArea.coordinates {
                bounds = bounds.includingCoordinate(coordinate)
            }
        }
        return bounds
    }

    func center() -> CLLocationCoordinate2D {
        let boundingArea = self.boundingArea()
        let latitude = (boundingArea.northEast.latitude + boundingArea.southWest.latitude)/2
        let longitude = (boundingArea.northEast.longitude + boundingArea.southWest.longitude)/2
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func contains(location: CLLocationCoordinate2D) -> Bool {
        for workingArea in workingAreas() {
            if workingArea.contains(location: location) {
                return true
            }
        }
        return false
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
