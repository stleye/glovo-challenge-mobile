//
//  Alerts.swift
//  CyclistAnt
//
//  Created by Sebastian Tleye on 18/12/16.
//  Copyright © 2016 HumileAnts. All rights reserved.
//

import Foundation

class Alerts {

    class func showAlert(viewController: UIViewController,
                         title: String,
                         message: String,
                         okTitle: String,
                         cancelTitle: String,
                         okHandler: ((UIAlertAction) -> Void)?,
                         cancelHandler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        alertController.addAction(UIAlertAction(title: okTitle, style: .default, handler: okHandler))
        alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        viewController.present(alertController, animated: true, completion: nil)
    }

    class func showAlert(viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
