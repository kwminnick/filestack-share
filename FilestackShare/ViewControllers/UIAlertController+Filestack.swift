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
        self.init(title: "", message: message, preferredStyle: .Alert)
        addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    }

    convenience init(message: String, noButtons: Bool) {
        if noButtons {
            self.init(title: "", message: message, preferredStyle: .Alert)
        } else {
            self.init(message: message)
        }
    }
}