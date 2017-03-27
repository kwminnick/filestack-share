//
//  AppDelegate.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 31/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let mainViewController = MainCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let navigationController = NavigationViewController(rootViewController: mainViewController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        Fabric.with([Crashlytics.self])

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DataStore.saveDB()
    }
}

