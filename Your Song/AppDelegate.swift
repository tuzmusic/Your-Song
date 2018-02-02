//
//  AppDelegate.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
//import GoogleSignIn
//import GGLCore
//import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate//, GIDSignInDelegate
{
	
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //print("Documents folder: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
		//googleSignIn()
        //YPB.setupRealm()
		//customizeFonts()
		return true
	}
	
	func customizeFonts() {
		UILabel.appearance().font = UIFont(name: "Oswald-Regular", size: UIFont.labelFontSize)
	}
}




