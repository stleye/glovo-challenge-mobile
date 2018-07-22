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

    @IBOutlet weak var mapView: GMSMapView? {
        didSet {
            mapView?.delegate = self
        }
    }

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!

    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            if navigationController?.topViewController != self { return }
            updateCurrentWorkingArea()
            positionOn(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            if checkWorkingAreas && currentWorkingArea == nil {
                goToSelectCityScreen()
            }
        }
    }

    private var currentZoom: Float = 15.0
    private var locationManager: CLLocationManager!
    private var workingAreas: [String: [WorkingArea]] = [:]
    private var checkWorkingAreas = true
    private var markers: [GMSMarker] = []

    private var currentWorkingArea: (cityCode: String, workingArea: WorkingArea)? {
        didSet {
            if currentWorkingArea == nil { return }
            CityDetails.getFor(cityCode: currentWorkingArea!.cityCode, onCompletionHandler: { (city) in
                let details = ((city as! JsonDictionary).decodable as! CityDetail)
                self.cityLabel.text = details.name
                self.currencyLabel.text = "Currency - \(details.currency)"
                self.timeZoneLabel.text = details.time_zone
                self.languageLabel.text = "Language - \(details.language_code)"
            }) { (error) in
                Alerts.showAlert(viewController: self, message: "There has been a problem obtaining city details")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createLocationManager()

        Cities.fetch(onCompletionHandler: { (jsonCollection) in
            let cities = (jsonCollection as! JsonArray).decodables as! [City]
            for city in cities {
                self.workingAreas[city.code] = city.workingAreas()
                for workingArea in self.workingAreas[city.code] ?? [] {
                    workingArea.polyline.map = self.mapView
                }
            }
        }) { (error) in
            print("Error")
        }
    }

    private func createLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.distanceFilter = 30
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    private func positionOn(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView?.animate(to: camera)
    }

    private func goToSelectCityScreen() {
        checkWorkingAreas = false
        locationManager.stopUpdatingLocation()
        self.performSegue(withIdentifier: "citySelectionSegue", sender: self)
    }

    private func updateCurrentWorkingArea() {
        currentWorkingArea = nil
        if currentLocation == nil { return }
        for (cityCode, workingAreas) in self.workingAreas {
            for workingArea in workingAreas {
                if workingArea.contains(location: currentLocation!) {
                    currentWorkingArea = (cityCode, workingArea)
                    break
                }
            }
        }
    }

}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted, .denied:
            goToSelectCityScreen()
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }
}

extension MapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if position.zoom <= 7.0 && currentZoom > 7.0 {
            if markers.isEmpty {
                for (_, workingAreas) in self.workingAreas {
                    let firstWorkingArea = workingAreas.first!
                    let marker = WorkingAreaMarker(position: firstWorkingArea.center(), workingArea: firstWorkingArea)
                    let icon = UIImageView(image: UIImage(named: "LocationIcon"))
                    marker.iconView = icon
                    markers.append(marker)
                }
            }
            markers.forEach { (marker) in marker.map = mapView }
        } else {
            if position.zoom >= 7.0 && currentZoom < 7.0 {
                markers.forEach { (marker) in marker.map = nil }
            }
        }
        currentZoom = position.zoom
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let workingArealocation = (marker as! WorkingAreaMarker).workingArea!.center()
        self.positionOn(latitude: workingArealocation.latitude, longitude: workingArealocation.longitude)
        return true
    }

}
