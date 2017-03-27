//
//  ViewControoler_Helper.swift
//  GCD_GET_Images
//
//  Created by Eric zhang on 2017-03-26.
//  Copyright © 2017 lei zhang. All rights reserved.
//

import UIKit

extension UIViewController {
    func prompt(title: String, msg:String) {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(OK)
        present(alertVC, animated: true, completion: nil)
    }
}
