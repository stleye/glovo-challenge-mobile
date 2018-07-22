//
//  WorkingAreaMarker.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 22/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation
import GoogleMaps

class WorkingAreaMarker: GMSMarker {
    var workingArea: WorkingArea?

    convenience init(position: CLLocationCoordinate2D, workingArea: WorkingArea) {
        self.init(position: position)
        self.workingArea = workingArea
    }
}
