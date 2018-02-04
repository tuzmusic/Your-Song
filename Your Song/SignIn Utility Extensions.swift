//
//  SignIn Utility Extensions.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 2/4/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

extension SignInTableViewController {
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 1 {
			switch indexPath.row {
			case 0: YPB.deleteDuplicateSongs(in: realm!)
			case 1: YPB.deleteDuplicateCategories(in: realm!)
			case 2: YPB.populateNilArtists(in: realm!)
			default: break
			}
		}
	}
	
	func setPermissions() {
		if let user = SyncUser.current {
			// let path = RealmConstants.realmAddress.absoluteString//.replacingOccurrences(of: ":9080", with: "")
			let permission = SyncPermission(realmPath: "*", identity: "*", accessLevel: .write)
			user.apply(permission) { (error) in
				if let error = error {
					pr(error)
				} else {
					pr("Permission change succeeded?")
				}
			}
		}
	}
	
	func getPermissions() {
		SyncUser.current?.retrievePermissions { (results, error) in
			if let results = results {
				pr(results.description)
			} else if let error = error {
				pr(error)
			}
		}
	}
}
