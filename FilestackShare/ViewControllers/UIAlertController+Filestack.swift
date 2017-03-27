//
//  UIAlertController+Filestack.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 09/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import Foundation

extension UIAlertController {

    convenience init(message: String) {
        self.init(title: "", message: message, preferredStyle: .alert)
        addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }

    convenience init(message: String, noButtons: Bool) {
        if noButtons {
            self.init(title: "", message: message, preferredStyle: .alert)
        } else {
            self.init(message: message)
        }
    }
}
