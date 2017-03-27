//
//  NavigationViewController.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 31/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit

final class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barStyle = .black
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = FSColor.lightGrey
        navigationBar.barTintColor = FSColor.darkGrey
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                             NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)]

    }
}
