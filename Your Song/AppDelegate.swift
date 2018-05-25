//
//  AppDelegate.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleSignIn
//import GGLCore
//import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
	
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		GIDSignIn.sharedInstance().clientID = "111693765997-vbcs27e46c6fdh6osh4494dvjfsacmut.apps.googleusercontent.com"
		GIDSignIn.sharedInstance().delegate = self
		
		if let splitVC = window?.rootViewController as? UISplitViewController,
			let masterNav = splitVC.viewControllers.first as? UINavigationController,
			let masterVC = masterNav.topViewController as? MasterViewController,
			let detailNav = splitVC.viewControllers.last as? UINavigationController,
			let detailVC = detailNav.topViewController
		{
//			detailVC.navigationItem.leftItemsSupplementBackButton = true
//			detailVC.navigationItem.leftBarButtonItem = detailVC.splitViewController?.displayModeButtonItem
			masterVC.navDelegate = detailNav
		}
		
		/*
		guard let splitViewController = window?.rootViewController as? UISplitViewController,
		let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
		let masterViewController = leftNavController.topViewController as? MasterViewController,
		let detailViewController = splitViewController.viewControllers.last as? DetailViewController

*/
		
		return true
	}
	
	
	
}




