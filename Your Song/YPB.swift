//
//  YPB.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class YPB {
	
	static var currentRequest: Request?
	
	static var realmSynced: Realm!
	static var realmLocal = try! Realm() {
		didSet {
			if YPB.realmLocal.objects(Song.self).isEmpty {
				SongImporter().importSongs()
			}
		}
	}
	
	static var ypbUser: YpbUser!
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
	}
	
    class func setupRealm() {
        
        let onlineRealm = false
        struct RealmConstants {
            static let ec2ip = "54.159.244.247"
            static let ec2ipDash = ec2ip.replacingOccurrences(of: ".", with: "-")
            static let localHTTP = URL(string:"http://" + ec2ip)!
            static let publicDNS = URL(string:"http://ec2-\(ec2ipDash).compute-1.amazonaws.com:9080")!
            static let realmAddress = URL(string:"realm://ec2-\(ec2ipDash).compute-1.amazonaws.com:9080/YourPianoBar/JonathanTuzman/")!
            
            static let userCred = SyncCredentials.usernamePassword(
                username: "tuzmusic@gmail.com", password: "tuzrealm")
            
            struct CommentedInfo {
                /*
			• To SSH into EC2: (THIRD realm)
				  ssh -i /Users/TuzsNewMacBook/Library/Mobile\ Documents/com\~apple\~CloudDocs/Misc\ Stuff\ -\ iCloud\ drive/Programming/IMPORTANT\ Server\ Stuff/KeyPairs/YourPianoBarKeyPair.pem ubuntu@ec2-54-159-244-247.compute-1.amazonaws.com
			
			• Finally installed ROS 2.0.18 onto server using:
				curl -s https://raw.githubusercontent.com/realm/realm-object-server/master/install.sh | bash
			However, "ros start" gives an error (i.e., it successfully starts to run, but fails).
				The error is saying "you already have something running here!" which refers to ROS 1.8.3
			Was able to free up the port (kill that task) by following this: https://stackoverflow.com/questions/47214593/realm-object-server-not-starting-on-digital-ocean
			
			• Starting a 3rd ec2 instance had the same problem, perhaps because the AMI already has a version of realm running.
				However I'm not getting the "Cannot /GET" error or causing a response in terminal (like happened with the 2nd instance)

			• Ubuntu AMI instance (54.205.63.24)
				ros starts on first try, but gets to the same hanging spot.

			• THIRD Realm AMI instance
				Created 11/15/17
				IP 54.159.244.247
			
			• NEW Realm AMI instance
				  Created 11/10/17
				  IP 54.227.135.125
                 first login in Chrome, creating Realm creds tm, PW tuzrealm
                 */
            }
        }
        
        struct RealmConstantsOLD {
            
            static let localHTTP = URL(string:"http://54.208.237.32:9080")!
            static let publicDNS = URL(string:"http://ec2-54-208-237-32.compute-1.amazonaws.com:9080")!
            static let realmAddress = URL(string:"realm://ec2-54-208-237-32.compute-1.amazonaws.com:9080/YourPianoBar/JonathanTuzman/")!
            
            static func tokenString() -> String { return "ewoJImlkZW50aXR5IjogIl9fYXV0aCIsCgkiYWNjZXNzIjogWyJ1cGxvYWQiLCAiZG93bmxvYWQiLCAibWFuYWdlIl0KfQo=:H1qgzZHbRSYdBs0YoJON7ehUZdVDQ8wGKwgYWsQUoupYPycq1cC4PlGZlDZ++Q+gB2ouYcw4bRRri2Z3F5dlWALLWvARgEwB2bDmuOQRcH30IKkdhFp11PnE3StiMn30TDZWWzX31QAyPDvaUyES7/VK/y8CDHmJ8L/UJ/y8w422bmIFTlectnuXBzMRboBZ8JD/PSrXciaPhm9hd/jEEfgYTwB7oyuuch9XrWvPbSrcpWXEr/6j526nuoips1+KTA/h25LzAgCs1+ZeO63RFKi/K3q7y/HkRBB8OWgK9kBQZGIx8eiH4zu7ut4mLGBcs38JnJr4OEvSTSfdZdhGxw==" }
            
            static let userCred = SyncCredentials.usernamePassword(username: "tuzmusic@gmail.com", password: "***REMOVED***")
            static let tokenCred = SyncCredentials.accessToken(RealmConstantsOLD.tokenString(), identity: "admin")
            //static let tokenCred = SyncCredentials.accessToken("wrong string", identity: "admin")
            
            struct CommentedInfo {
                /*
                 Paste into terminal to SSH into EC2:
                 ssh -i /Users/TuzsNewMacBook/Library/Mobile\ Documents/com\~apple\~CloudDocs/Misc\ Stuff\ -\ iCloud\ drive/Programming/IMPORTANT\ Server\ Stuff/KeyPairs/YourPianoBarKeyPair.pem ubuntu@ec2-54-208-237-32.compute-1.amazonaws.com
                 
                 NEW Realm AMI instance
                 Created 11/10/17
                 IP 54.227.135.125
                 first login in Chrome, creating Realm creds tm, PW tuzrealm
                 (Realm Studio still times out...)
                 */
            }
        }
        
        guard onlineRealm else {
            if YPB.realmLocal.objects(Song.self).isEmpty {
                SongImporter().importSongs()
            }
            return
        }
        SyncUser.logIn(with: RealmConstants.userCred, server: RealmConstants.publicDNS) {
            
            // Log in the user. If not, use local Realm config. If unable, return nil.
            user, error in
            guard let user = user else {
                print("Could not access server. Using local Realm [default configuration].")
                if YPB.realmLocal.objects(Song.self).isEmpty {
                    SongImporter().importSongs()
                }
                return
            } // guard else
            
            DispatchQueue.main.async {
                
                // Open the online Realm
                let syncConfig = SyncConfiguration (user: user, realmURL: RealmConstants.realmAddress)
                let configuration = Realm.Configuration(syncConfiguration: syncConfig)
                
                YPB.realmSynced = try! Realm(configuration: configuration)
                
                /*
                 try! YPB.realmSynced.write {
                 YPB.realmSynced.deleteAll()
                 }
                 try! YPB.realmLocal.write {
                 YPB.realmLocal.deleteAll()
                 }
                 */
                
                if YPB.realmLocal.objects(Song.self).isEmpty {
                    if YPB.realmSynced.objects(Song.self).isEmpty {
                        // this isn't quite right... or at least it should be named something else
                        YPB.populateSyncedRealmFromLocalRealm()
                    }
                    YPB.populateLocalRealmFromSyncedRealm()
                }
                YPB.deleteDuplicateCategories(in: YPB.realmLocal)
            }
        }
    }


	class func populateLocalRealmFromSyncedRealm() {
		let onlineSongs = YPB.realmSynced.objects(Song.self)
		for song in onlineSongs {
			try! YPB.realmLocal.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmLocal)
			}
		}
	}
	
	class func emptyLocalRealm() {
		try! YPB.realmLocal.write { YPB.realmLocal.deleteAll() }
	}
	
	class func populateSyncedRealmFromLocalRealm() {
		let offlineSongs = YPB.realmLocal.objects(Song.self)
		if offlineSongs.isEmpty {
			SongImporter().importSongs()
		}
		
		for song in offlineSongs {
			try! YPB.realmSynced.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmSynced)
			}
		}
	}
	
}


