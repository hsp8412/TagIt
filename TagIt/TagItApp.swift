import FirebaseCore
import SwiftUI

/// `AppDelegate` class is responsible for handling app lifecycle events
/// and performing initial setup, including Firebase configuration.
class AppDelegate: NSObject, UIApplicationDelegate {
    /// This method is called when the application has finished launching.
    ///
    /// - Parameters:
    ///   - application: The application instance.
    ///   - launchOptions: A dictionary containing information about the reason the app was launched.
    /// - Returns: A boolean indicating successful launch completion.
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Initialize Firebase to enable Firebase services like Firestore, Authentication, and Storage.
        FirebaseApp.configure()
        return true
    }
}

/// The main entry point for the `TagIt` app, managing the app lifecycle with SwiftUI.
@main
struct TagItApp: App {
    /// Connects the custom `AppDelegate` class to the SwiftUI App lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    /// Defines the main user interface of the app.
    var body: some Scene {
        WindowGroup {
            /// The root view of the app, responsible for determining whether to display
            /// the login screen or the main content based on authentication status.
            LaunchScreenTransitionView {
                MainView()
            }
            .preferredColorScheme(.light)
        }
    }
}
