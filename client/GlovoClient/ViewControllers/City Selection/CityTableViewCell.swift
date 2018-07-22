//
//  CityTableViewCell.swift
//  GlovoClient
//
//  Created by Sebastian Tleye on 20/07/2018.
//  Copyright © 2018 HumileAnts. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    var city: City? {
        didSet {
            cityLabel.text = city!.name
        }
    }

}
