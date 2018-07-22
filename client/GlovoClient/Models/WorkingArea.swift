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

    lazy var path: GMSPath = {
        let p = GMSMutablePath()
        for coordinate in coordinates {
            p.add(coordinate)
        }
        return p
    }()

    lazy var polygon: GMSPolygon = {
        let p = GMSPolygon(path: path)
        p.fillColor = UIColor(red: 0.28, green: 0.49, blue: 0.75, alpha: 0.5)
        return p
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
