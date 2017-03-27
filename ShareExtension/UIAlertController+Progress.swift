//
//  UIAlertController+Progress.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 07/07/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {

    convenience init(title: String?, message: String?, progressView: UIProgressView?) {
        self.init(title: title, message: message, preferredStyle: .alert)

        setupProgressView(progressView: progressView)
    }

    private func setupProgressView(progressView: UIProgressView?) {
        guard let progressView = progressView else {
            return
        }

        progressView.trackTintColor = UIColor(red:0.62, green:0.66, blue:0.69, alpha:1.00)
        progressView.progressTintColor = UIColor(red:0.94, green:0.29, blue:0.15, alpha:1.00)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(progressView)

        progressView.constraintWidth(240)
        progressView.constraintHeight(2)
        progressView.centerXToItem(view, constant: 0)
        progressView.centerYToItem(view, constant: 10)

        view.bringSubview(toFront: progressView)
    }
}
