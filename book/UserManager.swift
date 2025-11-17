import Foundation
import FirebaseFirestore

struct User: Codable {
    let uid: String
    let name: String
    let email: String
}

class UserManager {
    static let shared = UserManager()
    private init() {}

    private let userDefaultsKey = "currentUser"

    func fetchUserDataAndSave(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let user = User(
                    uid: uid,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                )
                self.saveUserToUserDefaults(user: user)
                completion(true)
            } else {
                print("사용자 문서를 찾을 수 없음: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }

    func saveUserToUserDefaults(user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            print("사용자 정보 저장 완료")
        } else {
            print("사용자 정보를 인코딩하는 데 실패함")
        }
    }

    func loadUserFromUserDefaults() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            print("저장된 사용자 정보가 없음")
            return nil
        }
        return user
    }

    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("사용자 정보 삭제 완료")
    }
}
