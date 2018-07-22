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

    private lazy var locationManager: CLLocationManager! = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.distanceFilter = 30
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return locationManager
    }()

    private var workingAreas: [String: [WorkingArea]] = [:]
    private var locationMethod: LocationMethod = .NotDefined
    private var markers: [GMSMarker] = []

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
            positionOn(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            if locationMethod == .GPS && currentWorkingArea == nil {
                goToSelectCityScreen()
            }
        }
    }

    private var currentWorkingArea: WorkingArea? {
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
        AVHUD.show()
        Cities.fetch(onCompletionHandler: { (jsonCollection) in
            AVHUD.dismiss()
            let cities = (jsonCollection as! JsonArray).decodables as! [City]
            for city in cities {
                self.workingAreas[city.code] = city.workingAreas()
                for workingArea in self.workingAreas[city.code] ?? [] {
                    workingArea.polyline.map = self.mapView
                }
                let _ = self.locationManager
            }
        }) { (error) in
            AVHUD.dismiss()
            print("Error")
        }
    }

    private func positionOn(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        updateCurrentWorkingArea()
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView?.animate(to: camera)
    }

    private func positionOn(workingArea: WorkingArea) {
        currentWorkingArea = workingArea
        mapView?.animate(with: GMSCameraUpdate.fit(workingArea.boundingArea))
    }

    private func goToSelectCityScreen() {
        locationMethod = .ManuallySelected
        locationManager.stopUpdatingLocation()
        self.performSegue(withIdentifier: "citySelectionSegue", sender: self)
    }

    private func updateCurrentWorkingArea() {
        currentWorkingArea = nil
        if currentLocation == nil { return }
        for (_, workingAreas) in self.workingAreas {
            for workingArea in workingAreas {
                if workingArea.contains(location: currentLocation!) {
                    currentWorkingArea = workingArea
                    break
                }
            }
        }
    }

    private func createMarkers() {
        if markers.first?.map != nil { return }
        if markers.isEmpty {
            for (_, workingAreas) in self.workingAreas {
                markers.append(createMarkerFor(workingArea: workingAreas.first!))
            }
        }
        markers.forEach { (marker) in marker.map = mapView }
    }

    private func clearMarkers() {
        if markers.first?.map == nil { return }
        markers.forEach { (marker) in marker.map = nil }
    }

    private func createMarkerFor(workingArea: WorkingArea) -> WorkingAreaMarker {
        let marker = WorkingAreaMarker(position: workingArea.center, workingArea: workingArea)
        let icon = UIImageView(image: UIImage(named: "LocationIcon"))
        marker.iconView = icon
        return marker
    }

    private func shouldShowIcons() -> Bool {
        if mapView == nil { return false }
        return mapView!.camera.zoom <= Float(7.0)
    }

}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationMethod = .GPS
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

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.positionOn(workingArea: (marker as! WorkingAreaMarker).workingArea!)
        return true
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if position.zoom <= 7.0 {
            createMarkers()
        } else {
            clearMarkers()
        }
    }

}
