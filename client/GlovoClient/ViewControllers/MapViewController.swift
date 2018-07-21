//
//  ViewController.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 19/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    private var locationManager: CLLocationManager!
    private var mapView: GMSMapView!
    private var workingAreas: [WorkingArea] = []
    private var checkWorkingAreas = true

    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            if navigationController?.topViewController != self { return }
            positionOn(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            if !checkWorkingAreas { return }
            var userIsInsideWorkingArea = false
            for workingArea in workingAreas {
                if workingArea.contains(location: currentLocation!) {
                    userIsInsideWorkingArea = true
                    break
                }
            }
            if !userIsInsideWorkingArea {
                goToSelectCityScreen()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createLocationManager()
        createMapView()

        Cities.fetch(onCompletionHandler: { (jsonCollection) in
            let cities = (jsonCollection as! JsonArray).decodables as! [City]
            for city in cities {
                self.workingAreas.append(contentsOf: city.workingAreas())
//                for workingArea in city.workingAreas() {
//                    workingArea.polyline.map = self.mapView
//                }
            }
        }) { (error) in
            print("Error")
        }

//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView

//        CityDetails.getFor(cityCode: "BCN", onCompletionHandler: { (city) in
//            let working_areas = ((city as! JsonDictionary).decodable as! CityDetail).working_area
//            let a = 2
//        }) { (error) in
//            print ("Error")
//        }
    }

    private func createLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.distanceFilter = 30
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    private func createMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
    }

    private func positionOn(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView.animate(to: camera)
    }

    private func goToSelectCityScreen() {
        checkWorkingAreas = false
        locationManager.stopUpdatingLocation()
        self.performSegue(withIdentifier: "citySelectionSegue", sender: self)
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            goToSelectCityScreen()
            break
        case .denied:
            goToSelectCityScreen()
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }
}
