//
//  AppDelegate.swift
//  FlickrPhotos
//
//  Created by john ledesma on 7/16/18.
//  Copyright © 2018 john ledesma. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let flowLayout = UICollectionViewFlowLayout()
        let photoViewController = PhotosViewController(collectionViewLayout: flowLayout)
        
        window?.rootViewController = UINavigationController(rootViewController: photoViewController)
        return true
    }
}
