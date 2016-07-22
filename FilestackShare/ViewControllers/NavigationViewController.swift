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

        navigationBar.barStyle = .Black
        navigationBar.translucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = FSColor.lightGrey
        navigationBar.barTintColor = FSColor.darkGrey
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                                             NSFontAttributeName: UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)]

    }
}
