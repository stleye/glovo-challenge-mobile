//
//  WorkingArea.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 21/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation
import Polyline
import CoreLocation
import GoogleMaps
import MapKit

class WorkingArea {
    let countryCode: String
    let cityCode: String
    let cityName: String

    private let encoded: String

    lazy var coordinates: [CLLocationCoordinate2D] = {
        return decodePolyline(self.encoded) ?? []
    }()

    lazy var polyline: GMSPolyline = {
        let path = GMSMutablePath()
        for coordinate in coordinates {
            path.add(coordinate)
        }
        return GMSPolyline(path: path)
    }()

    lazy var boundingArea: GMSCoordinateBounds = {
        return GMSCoordinateBounds(path: GMSMutablePath(fromEncodedPath: encoded)!)
    }()

    init(countryCode: String, cityCode: String, cityName: String, encoded: String) {
        self.countryCode = countryCode
        self.cityCode = cityCode
        self.cityName = cityName
        self.encoded = encoded
    }

    func contains(location: CLLocationCoordinate2D) -> Bool {
        return GMSGeometryContainsLocation(location, GMSPath(fromEncodedPath: encoded)!, true)
    }

}
