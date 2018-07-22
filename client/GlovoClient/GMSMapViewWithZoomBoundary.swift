//
//  GMSMapViewWithZoomBoundary.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 22/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import Foundation
import GoogleMaps

protocol GMSMapViewWithZoomBoundaryDelegate: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapViewWithZoomBoundary, didChangeZoomBoundary zoom: Float)
    func mapView(_ mapView: GMSMapViewWithZoomBoundary, didTap marker: GMSMarker) -> Bool
}

class GMSMapViewWithZoomBoundary: GMSMapView, GMSMapViewDelegate {

    var boundary: Float = 7.0

    var myDelegate: GMSMapViewWithZoomBoundaryDelegate?

    private var currentZoom: Float = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = self
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if position.zoom <= boundary && currentZoom > boundary {
            myDelegate?.mapView(self, didChangeZoomBoundary: position.zoom)
        } else {
            if position.zoom >= boundary && currentZoom < boundary {
                myDelegate?.mapView(self, didChangeZoomBoundary: position.zoom)
            }
        }
        currentZoom = position.zoom
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return myDelegate?.mapView(self, didTap: marker) ?? false
    }

}
