//
//  SimpleConstraints.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 02/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func constraintWidth(_ width: CGFloat) {
        let constraintWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        self.addConstraint(constraintWidth)
    }

    func constraintHeight(_ height: CGFloat) {
        let constraintHeight = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        self.addConstraint(constraintHeight)
    }

    func spreadOutOnView(_ view: UIView) {
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)

        view.addConstraints([top, bottom, left, right])
    }

    func topConstraintToItem(_ item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .top, constant: constant)
    }

    func bottomConstraintToItem(_ item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .bottom, constant: constant)
    }

    func leftConstraintToItem(_ item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .left, constant: constant)
    }

    func rightConstraintToItem(_ item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .right, constant: constant)
    }

    func centerXToItem(_ item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .centerX, constant: constant)
    }

    func centerYToItem(_ item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .centerY, constant: constant)
    }

    fileprivate func constraintToItem(_ item: UIView, attribute: NSLayoutAttribute, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: item, attribute: attribute, multiplier: 1, constant: constant)
        item.addConstraint(constraint)
    }
}
