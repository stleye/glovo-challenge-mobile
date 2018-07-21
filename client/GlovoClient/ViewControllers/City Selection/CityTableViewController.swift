//
//  CountryTableViewController.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 20/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import UIKit
import CoreLocation

class CityTableViewController: UITableViewController {

    private var countries: [Country] = []
    private var cities: [String: [City]] = [:] //The key of this dictionary is the country code

    override func viewDidLoad() {
        super.viewDidLoad()
        AVHUD.show(status: "Loading")
        Countries.fetch(onCompletionHandler: { (jsonCollection) in
            self.countries = ((jsonCollection as! JsonArray).decodables as! [Country]).sorted(by: { (c1, c2) -> Bool in c1.name <= c2.name })
            Cities.fetch(onCompletionHandler: { (jsonCollection) in
                AVHUD.dismiss()
                Alerts.showAlert(viewController: self, message: "You are not inside a working area, please select one from the list")
                let cities = (jsonCollection as! JsonArray).decodables as! [City]
                for city in cities {
                    if self.cities[city.country_code] != nil {
                        self.cities[city.country_code]?.append(city)
                    } else {
                        self.cities[city.country_code] = [city]
                    }
                }
                self.tableView.reloadData()
            }) { (error) in
                AVHUD.dismiss()
                Alerts.showAlert(viewController: self, message: "There has been an error loading the cities")
            }
        }) { (error) in
            AVHUD.dismiss()
            Alerts.showAlert(viewController: self, message: "There has been an error loading the countries")
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countries[section].name
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities[countries[section].code]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        if let cityCell = dequeuedCell as? CityTableViewCell {
            let city = cities[countries[indexPath.section].code]![indexPath.row]
            cityCell.cityLabel.text = city.name
            cityCell.workingAreas = city.workingAreas()
        }
        return dequeuedCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mapVC = self.navigationController?.viewControllers.first as? MapViewController {
            self.navigationController?.popToRootViewController(animated: true)
            let city = cities[countries[indexPath.section].code]![indexPath.row]
            mapVC.currentLocation = city.workingAreas().first!.decodedCoordinates.first!
        }
    }

}
