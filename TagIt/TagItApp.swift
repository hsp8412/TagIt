import SwiftUI
import FirebaseCore

// AppDelegate class to handle Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()
      
//      // Initialize Firestore collections using DatabaseInitializationService
//      DatabaseInitializationService.shared.initializeAllCollections { success in
//          if success {
//              print("Firebase collections initialized successfully.")
//          } else {
//              print("Firebase collections initialization failed.")
//          }
//      }
      
    return true
  }

}

@main
struct TagItApp: App {
    // Connect AppDelegate to the SwiftUI App lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            MainView()
//            SearchResultView()
        }
    }
}

