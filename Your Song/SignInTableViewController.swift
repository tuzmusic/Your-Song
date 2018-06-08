//
//  SignInTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 2/1/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import GoogleSignIn



struct RealmConstants {
    static let address = "your-piano-bar.us1.cloud.realm.io"
    static let authURL = URL(string:"https://\(address)")!
    static let realmURL = URL(string:"realms://\(address)/YourPianoBar/JonathanTuzman/")!
}

class SignInTableViewController: UITableViewController, GIDSignInUIDelegate, RealmDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var realmLoginButtons: [UIButton]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        emailField.text = ""
        passwordField.text = ""
    }
    
    var spinner = UIActivityIndicatorView()
    var proposedUser = YpbUser()
    
    var realm: Realm?
    var subscriptionToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = SyncUser.current {
            pr("SyncUser was already logged in: \(user.identity!)")
            proposedUser.id = user.identity!
            openRealmWithUser(user: user)
        } else {
            realm = nil
        }
    }
    
    deinit {
        subscriptionToken?.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        spinner.stopAnimating()
        if let vc = segue.destination as? RegisterTableViewController {	// prepare for Register segue
            vc.email = emailField.text
            vc.password = passwordField.text
            vc.loginDelegate = self
        } else if let vc = segue.destination as? CreateRequestTableViewController { // prepare for CreateRequest segue
            vc.realm = self.realm
        }
    }
    
    // MARK: Realm-cred sign-in
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if SyncUser.current == nil {
            if let email = emailField.text, let password = passwordField.text {
                guard !password.isEmpty else {
                    nicknameLogin(with: email)
                    return
                }
                proposedUser.email = email // to see if we have a user with this EMAIL ADDRESS
                let cred = SyncCredentials.usernamePassword(username: email, password: password)
                realmCredLogin(cred: cred)
            }
        }
    }
    
    // YPB Realm login
    
    fileprivate func nicknameLogin(with name: String) {
        let alert = UIAlertController(title: "No password entered",
                                      message: "Do you want to login using \"nickname\" \(name)?", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yesButton = UIAlertAction(title: "OK", style: .default) { (_) in
            let nicknameCred = SyncCredentials.nickname(name)
            self.realmCredLogin(cred: nicknameCred)
        }
        alert.addAction(yesButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    func realmCredLogin(cred: SyncCredentials) {	// Should probably rename, since I think this may for all kinds of creds.
        spinner = view.addNewSpinner()
        
        SyncUser.logIn(with: cred, server: RealmConstants.authURL) { [weak self] (user, error) in
            if let user = user {    // can't check YpbUser yet because we're not in the realm, where YpbUsers are
                self?.openRealmWithUser(user: user); pr("SyncUser now logged in: \(user.identity!)")
            } else if let error = error {
                self?.present(UIAlertController.basic(title: "Login failed", message: error.localizedDescription), animated: true); pr("SyncUser.login Error: \(error)")
                self?.spinner.stopAnimating()
            }
        }
    }
    
    fileprivate func openRealmWithUser(user: SyncUser) {
        DispatchQueue.main.async { [weak self] in
            let config = user.configuration(realmURL: RealmConstants.realmURL, fullSynchronization: false, enableSSLValidation: true, urlPrefix: nil)
            self?.realm = try! Realm(configuration: config)
            self?.findYpbUser(in: (self?.realm)!)
            
            _ = self?.realm?.objects(Song.self).subscribe()
            _ = self?.realm?.objects(YpbUser.self).subscribe()
            self?.performSegue(withIdentifier: Storyboard.LoginToNewRequestSegue, sender: nil)
        }
    }
    
    fileprivate func findYpbUser(in realm: Realm) {
        // Once we're not dealing with SyncUsers created w/o YpbUsers, I think this is here to see if someone has already been registered as a YpbUser using a different authentication method.
        // The login handler for that method should set the proposedUser.email
        
        // note: I think there is a way to have this happen where the proposedUser is an optional, but for now we check against an initialized YpbUser instead of checking whether it's been set.
        if proposedUser != YpbUser() {
            let existingUser = YpbUser.existingUser(for: proposedUser, in: realm)
            guard existingUser == nil else { // If we find the YpbUser, set as current:
                try! realm.write {
                    pr("YpbUser found: \(existingUser!)")
                    YpbUser.current = existingUser }
                return
            }
            
            pr("YpbUser not found.") // i.e., SyncUser set, but no YpbUser found. i.e., creating a new YpbUser
            createNewYpbUser(for: proposedUser, in: realm)
        } else {
            pr("proposed user == YpbUser(). WTF?")
        }
    }
    
    fileprivate func createNewYpbUser(for info: YpbUser, in realm: Realm) {
        // Once we're not dealing with SyncUsers created w/o YpbUsers, I think this should only ever get called from RegisterVC (and so should reside there)
        let newYpbUser = YpbUser.user(id: SyncUser.current!.identity, email: info.email,
                                      firstName: info.firstName, lastName: info.lastName)
        try! realm.write {
            realm.add(newYpbUser)
            YpbUser.current = newYpbUser
            pr("YpbUser created: \(newYpbUser.firstName) \(newYpbUser.lastName) (\(newYpbUser.email)). Set as YpbUser.current.")
        }
    }
    
    func logOutAll() {
        SyncUser.current?.logOut()
        realm = nil
        proposedUser = YpbUser()
        emailField.text = ""
        passwordField.text = ""
    }
}

extension YpbUser {
    class func existingUser (for proposedUser: YpbUser, in realm: Realm) -> YpbUser? {
        if let idUser = realm.objects(YpbUser.self).filter("id = %@", proposedUser.id).first {
            return idUser
        }
        if let emailUser = realm.objects(YpbUser.self).filter("email = %@", proposedUser.email).first {
            return emailUser
        }
        return nil
    }
    class func existingUser (forSyncUser user: SyncUser, in realm: Realm) -> YpbUser? {
        let id = user.identity!
        return realm.objects(YpbUser.self).filter("id = %@", id).first
    }
    class func existingUser (forEmail email: String, in realm: Realm) -> YpbUser? {
        let user = realm.objects(YpbUser.self).filter("email = %@", email).first
        return user
    }
}
