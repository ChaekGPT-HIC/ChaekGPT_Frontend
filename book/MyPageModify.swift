import SwiftUI
import FirebaseFirestore

struct MyPageModify: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var nickname: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            HStack {
                Text("닉네임")
                    .font(.headline)
                Spacer()
            }
            
            TextField("닉네임을 입력하세요", text: $nickname)
                .padding(15)
                .font(.system(size: 18))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.bottom, 20)
        }
        .padding(20)
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    updateNickname()
                }
                .foregroundColor(.black)
            }
        }
        .onAppear {
            loadCurrentNickname()
        }
    }
}

extension MyPageModify {
    
    // Firestore에서 현재 닉네임 불러오기
    func loadCurrentNickname() {
        guard let uid = authVM.userId else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { document, error in
            if let data = document?.data(),
               let currentNickname = data["userNickname"] as? String {
                nickname = currentNickname
            }
        }
    }
    
    // Firestore에 닉네임 업데이트
    func updateNickname() {
        guard let uid = authVM.userId else { return }
        let db = Firestore.firestore()
        
        isLoading = true
        
        // 문서가 없을 때 자동 생성 + 기존 필드는 유지하도록
        db.collection("users").document(uid).setData(
            ["userNickname": nickname],
            merge: true
        ) { error in
            isLoading = false
            if let error = error {
                print("닉네임 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("닉네임 업데이트 성공: \(nickname)")
                DispatchQueue.main.async {
                    authVM.nickname = nickname
                    dismiss()
                }
            }
        }
    }

}

