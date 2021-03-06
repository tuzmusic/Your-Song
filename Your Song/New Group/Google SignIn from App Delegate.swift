/* GOOGLE STUFF

func googleSignIn() {
// Initialize Google sign-in
var configureError: NSError?
GGLContext.sharedInstance().configureWithError(&configureError)
assert(configureError == nil, "Error configuring Google services: \(String(describing:configureError))")
GIDSignIn.sharedInstance().delegate = self

// For automatic sign-in?
// GIDSignIn.sharedInstance().signInSilently()
}

func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

// Gets called after sign-in succeeds in Safari (probably also if it fails), before it returns to this app

return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
annotation: options[UIApplicationOpenURLOptionsKey.annotation])
}

func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
// The sign-in flow has finished (asyncronously) and was successful if |error| is |nil|.
guard error == nil else {
print("\(error.localizedDescription)")
return
}
YPB.ypbUser = YpbUser.user(firstName: user.profile.givenName,
lastName: user.profile.familyName,
email: user.profile.email,
in: YPB.realmSynced ?? YPB.realmLocal)

// Some more google user info
/*
let userId = user.userID                  // For client-side use only!
let idToken = user.authentication.idToken // Safe to send to the server
*/
}

func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
// ...
}
*/
