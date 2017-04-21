//
//  AppDelegate.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	/*

	Realm management stuff:
	✔︎ 1. Delete all songs in local Realm but 3
	✔︎ 2. Make sure the offline Realm never imports songs
	✔︎ -- When no internet, app should only ever show 3 songs --
	3. Implement update from online realm (when online realm is open, set the config, and refresh results)
		Actually, the song count is printed so quickly that the tableview SHOULD populate correctly.
	
	Try to solve the schema conflict:
	✔︎ 1. Delete entire online AND offline Realms
	✔︎ 2. Run the app. It should recreate and repopulate both realms.
	3. Do all these steps again.
	
	✔︎ (sort of) 4. Also have the console print the number of songs in realm to make sure where in the right place (in case we are but the app isn't showing the right things)
	-- When online, song list should show 3 songs, until realm is opened, then all songs should show --
	
	*** AH HA! It's now saying "3 songs in Online realm" which means it's counting songs from the wrong realm.
	
	Once this works (and we know we're accessing the online realm the way we want to):
	5. Copy songs from online realm to offline realm.
	6. Run without internet, and full song database should show (can also check in realm browser)
	
	*/
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		print("Documents folder: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
		
		
		
		return true
	}
}

