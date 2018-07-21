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

    init(fromEncoded encoded: String) {
        self.encoded = encoded
    }

    func contains(location: CLLocationCoordinate2D) -> Bool {
        return GMSGeometryContainsLocation(location, GMSPath(fromEncodedPath: encoded)!, true)
    }

}
