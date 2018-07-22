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

    private var cities: [City: [WorkingArea]] = [:]
    private var locationMethod: LocationMethod = .NotDefined
    private var markers: [GMSMarker] = []

    @IBOutlet weak var mapView: GMSMapView? {
        didSet {
            mapView?.delegate = self
        }
    }

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!

    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            if navigationController?.topViewController != self { return }
            updateCurrentCity()
            positionOn(city: currentCity!)
            if locationMethod == .GPS && currentCity == nil {
                goToSelectCityScreen()
            }
        }
    }

    private var currentCity: City? {
        didSet {
            if currentCity == nil { return }
            CityDetails.getFor(cityCode: currentCity!.code, onCompletionHandler: { (city) in
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
                self.cities[city] = city.workingAreas()
                for workingArea in self.cities[city] ?? [] {
                    workingArea.polygon.map = self.mapView
                }
                let _ = self.locationManager
            }
        }) { (error) in
            AVHUD.dismiss()
            Alerts.showAlert(viewController: self, message: "There has been an error obtaining the cities from the server")
        }
    }

    private func positionOn(city: City) {
        currentCity = city
        self.mapView?.animate(with: GMSCameraUpdate.fit(city.boundingArea(), withPadding: 15.0))
    }

    private func goToSelectCityScreen() {
        locationMethod = .ManuallySelected
        locationManager.stopUpdatingLocation()
        self.performSegue(withIdentifier: "citySelectionSegue", sender: self)
    }

    private func updateCurrentCity() {
        currentCity = nil
        if currentLocation == nil { return }
        for city in self.cities.keys {
            if city.contains(location: currentLocation!) {
                currentCity = city
                return
            }
        }
    }

    private func createMarkers() {
        if markers.first?.map != nil { return }
        if markers.isEmpty {
            for city in self.cities.keys {
                markers.append(createMarkerFor(city: city))
            }
        }
        markers.forEach { (marker) in marker.map = mapView }
    }

    private func clearMarkers() {
        if markers.first?.map == nil { return }
        markers.forEach { (marker) in marker.map = nil }
    }

    private func createMarkerFor(city: City) -> CityMarker {
        let marker = CityMarker(city: city)
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
        self.positionOn(city: (marker as! CityMarker).city!)
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
