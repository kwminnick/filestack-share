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

    func constraintWidth(width: CGFloat) {
        let constraintWidth = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: width)
        self.addConstraint(constraintWidth)
    }

    func constraintHeight(height: CGFloat) {
        let constraintHeight = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        self.addConstraint(constraintHeight)
    }

    func spreadOutOnView(view: UIView) {
        let top = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)

        view.addConstraints([top, bottom, left, right])
    }

    func topConstraintToItem(item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .Top, constant: constant)
    }

    func bottomConstraintToItem(item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .Bottom, constant: constant)
    }

    func leftConstraintToItem(item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .Left, constant: constant)
    }

    func rightConstraintToItem(item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .Right, constant: constant)
    }

    func centerXToItem(item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .CenterX, constant: constant)
    }

    func centerYToItem(item: UIView, constant: CGFloat) {
        constraintToItem(item, attribute: .CenterY, constant: constant)
    }

    private func constraintToItem(item: UIView, attribute: NSLayoutAttribute, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: item, attribute: attribute, multiplier: 1, constant: constant)
        item.addConstraint(constraint)
    }
}