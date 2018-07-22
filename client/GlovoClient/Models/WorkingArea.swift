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
    let cityCode: String

    private let encoded: String

    lazy var decodedCoordinates: [CLLocationCoordinate2D] = {
        return decodePolyline(self.encoded) ?? []
    }()

    lazy var polyline: GMSPolyline = {
        let path = GMSMutablePath()
        for coordinate in decodedCoordinates {
            path.add(coordinate)
        }
        return GMSPolyline(path: path)
    }()

    lazy var boundingArea: GMSCoordinateBounds = {
        return GMSCoordinateBounds(path: GMSMutablePath(fromEncodedPath: encoded)!)
    }()

    lazy var center: CLLocationCoordinate2D = {
        let latitude = (boundingArea.northEast.latitude + boundingArea.southWest.latitude)/2
        let longitude = (boundingArea.northEast.longitude + boundingArea.southWest.longitude)/2
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }()

    init(cityCode: String, encoded: String) {
        self.cityCode = cityCode
        self.encoded = encoded
    }

    func contains(location: CLLocationCoordinate2D) -> Bool {
        return GMSGeometryContainsLocation(location, GMSPath(fromEncodedPath: encoded)!, true)
    }

}
