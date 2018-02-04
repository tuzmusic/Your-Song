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
		
		return true
	}
	
	
	
}




