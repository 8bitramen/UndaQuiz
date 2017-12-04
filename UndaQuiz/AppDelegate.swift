import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        requestNotificationAuthorization()
        registerQuestionNotificationCategory()
        clearBadgeNumber()

        return true
    }

    private func requestNotificationAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            guard granted else { return }

            self.registerRemoteNotifications()
        }
    }

    private func registerRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register remote notifications: \(error)")
    }

    private func registerQuestionNotificationCategory() {
        let questionCategory =  UNNotificationCategory(identifier: "question",
                                                       actions: [],
                                                       intentIdentifiers: [],
                                                       options: [])

        UNUserNotificationCenter.current().setNotificationCategories([questionCategory])
    }

    private func clearBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
