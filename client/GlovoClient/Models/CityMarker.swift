//
//  CityMarker.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 22/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import GoogleMaps

class CityMarker: GMSMarker {
    var city: City?

    convenience init(city: City) {
        self.init(position: city.getPointInside())
        self.city = city
    }
}
