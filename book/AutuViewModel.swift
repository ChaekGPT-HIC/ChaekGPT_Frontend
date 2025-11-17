import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    @Published var userId: String? = nil
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var provider: String? = nil
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let db = Firestore.firestore()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                DispatchQueue.main.async {
                    self.userId = user.uid
                    self.isLoggedIn = true
                    print("세션 복원됨: \(user.uid)")
                }
            } else {
                DispatchQueue.main.async {
                    self.userId = nil
                    self.isLoggedIn = false
                    print("로그아웃 또는 세션 없음")
                }
            }
        }
    }

    
    // MARK: - 이메일 로그인
    func loginWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("이메일 로그인 실패: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let user = result?.user {
                self.userId = user.uid
                self.email = user.email ?? email
                self.provider = "email"
                self.isLoggedIn = true
                
                // Firestore에서 유저 데이터 불러오기
                let docRef = self.db.collection("users").document(user.uid)
                docRef.getDocument { document, _ in
                    if let document = document, document.exists {
                        self.nickname = document.data()?["userNickname"] as? String ?? ""
                    } else {
                        // 문서가 없으면 생성
                        let userData: [String: Any] = [
                            "uid": user.uid,
                            "userEmail": self.email,
                            "userNickname": self.nickname.isEmpty ? "새로운 유저" : self.nickname,
                            "provider": "email",
                            "createdAt": Timestamp(date: Date())
                        ]
                        docRef.setData(userData, merge: true)
                    }
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    
    // MARK: - Firestore 유저 정보 새로고침
    func refreshUserInfo() {
        guard let uid = userId else { return }
        
        db.collection("users").document(uid).getDocument { document, _ in
            if let data = document?.data() {
                DispatchQueue.main.async {
                    self.nickname = data["userNickname"] as? String ?? self.nickname
                    self.email = data["userEmail"] as? String ?? self.email
                }
            }
        }
    }

    
    // MARK: - 로그아웃
    func logout() {
        do {
            try Auth.auth().signOut()
            print("Firebase 로그아웃 완료")
        } catch {
            print("Firebase 로그아웃 실패: \(error.localizedDescription)")
        }

        // 로컬 상태 초기화
        resetLocalAuthState()
    }

    
    // MARK: - 회원탈퇴
    func withdraw() {
        guard provider == "email" else {
            self.alertMessage = "현재 카카오 계정은 삭제 기능이 없습니다."
            self.showAlert = true
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let firebaseUid = currentUser.uid
        
        currentUser.delete { error in
            if let error = error {
                print("이메일 회원탈퇴 실패: \(error)")
                return
            }
            print("이메일 계정 삭제 성공")
            self.deleteUserFromFirestore(uid: firebaseUid, email: self.email)
        }
    }

    
    // MARK: - Firestore 사용자 삭제
    private func deleteUserFromFirestore(uid: String? = nil, email: String? = nil) {
        if let uid = uid, !uid.isEmpty {
            let q = db.collection("users").whereField("uid", isEqualTo: uid)
            q.getDocuments { snapshot, error in
                if let _ = error {
                    self.deleteDocumentByDocIDIfNeeded(email)
                    return
                }
                
                guard let docs = snapshot?.documents, !docs.isEmpty else {
                    self.deleteDocumentByDocIDIfNeeded(email)
                    return
                }
                
                let group = DispatchGroup()
                for doc in docs {
                    group.enter()
                    self.deleteSubcollections(for: doc.reference) {
                        doc.reference.delete { _ in group.leave() }
                    }
                }
                
                group.notify(queue: .main) {
                    self.resetLocalAuthState()
                }
            }
            return
        }
        
        if let email = email, !email.isEmpty {
            deleteDocumentByDocID(email)
            return
        }
        
        resetLocalAuthState()
    }

    
    // MARK: - 하위 컬렉션 삭제
    private func deleteSubcollections(for docRef: DocumentReference, completion: @escaping () -> Void) {
        let subcollections = ["bookshelf"]
        let group = DispatchGroup()
        
        for sub in subcollections {
            group.enter()
            docRef.collection(sub).getDocuments { snapshot, _ in
                let batch = self.db.batch()
                snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
                batch.commit { _ in group.leave() }
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }

    
    // MARK: - 문서 직접 삭제
    private func deleteDocumentByDocID(_ docID: String) {
        db.collection("users").document(docID).delete { _ in
            self.resetLocalAuthState()
        }
    }
    
    private func deleteDocumentByDocIDIfNeeded(_ email: String?) {
        if let email = email, !email.isEmpty {
            deleteDocumentByDocID(email)
        } else {
            resetLocalAuthState()
        }
    }

    
    // MARK: - 로컬 상태 초기화
    private func resetLocalAuthState() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.userId = nil
            self.nickname = ""
            self.email = ""
            self.provider = nil
        }
    }
}

