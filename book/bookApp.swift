import SwiftUI
import KakaoSDKCommon
import FirebaseCore
import KakaoSDKAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authVM = AuthViewModel()
    @State private var path = NavigationPath()
    
  
        
    init() {
        if let appKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String {
            KakaoSDK.initSDK(appKey: appKey)
        }
       }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                MainView(path: $path)
                    .navigationDestination(for: String.self) { value in
                        switch value {
                        case "login":
                            LoginEmailView(path: $path)
                        case "main":
                            MainView(path: $path)
                        default:
                            EmptyView()
                        }
                    }
            }.environmentObject(authVM)
            
            .tint(.black)
        }
    }
}

