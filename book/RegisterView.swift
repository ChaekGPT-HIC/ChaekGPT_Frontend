
import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct RegisterView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var userEmail: String = ""
    @State private var newPassword: String = ""
    @State private var newPasswordConfirm: String = ""
    @State private var userNickname: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var isEmailMatching: Bool {
        userEmail.isEmpty
    }
    
    var isNicknameMatching: Bool {
        userNickname.isEmpty
    }
     
    var isNewPasswordMatching: Bool {
        newPasswordConfirm.isEmpty || newPassword == newPasswordConfirm
    }
    
    func registerUser() {
        let db = Firestore.firestore()
        
        guard !userEmail.isEmpty, !newPassword.isEmpty, !userNickname.isEmpty else {
            alertMessage = "모든 정보를 입력해주세요."
            showAlert = true
            return
        }
        
        // Firestore에서 이메일 중복확인
        db.collection("users")
            .whereField("userEmail", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    alertMessage = "중복확인 중 오류 발생: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                if let docs = snapshot?.documents, !docs.isEmpty {
                    // 이미 같은 이메일이 존재함
                    alertMessage = "이미 사용 중인 이메일입니다."
                    showAlert = true
                } else {
                    // 중복 없음 → Firebase Auth 계정 생성
                    Auth.auth().createUser(withEmail: userEmail, password: newPassword) { result, error in
                        if let error = error {
                            alertMessage = "회원가입 실패: \(error.localizedDescription)"
                            showAlert = true
                            return
                        }
                        
                        guard let uid = result?.user.uid else { return }
                        
                        // Firestore에 uid를 문서ID로 저장
                        let userRef = db.collection("users").document(uid)
                        
                        let userData: [String: Any] = [
                            "provider": "email",
                            "uid": uid,
                            "userEmail": userEmail,
                            "userNickname": userNickname,
                            "createdAt": Timestamp(date: Date())
                        ]
                        
                        userRef.setData(userData) { error in
                            if let error = error {
                                alertMessage = "데이터 저장 실패: \(error.localizedDescription)"
                            } else {
                                alertMessage = "회원가입이 완료되었습니다!"
                                dismiss()
                            }
                            showAlert = true
                        }
                    }
                }
            }
    }

    
    
    var body: some View {
        ScrollView{
            HStack {
                Text("이메일")
                    .font(.headline)
                Spacer()
            }.padding(.top, 20)
            
            HStack{
                TextField("이메일을 입력하세요", text: $userEmail)
                    .padding(15)
                    .padding(.leading, 3)
                    .font(.system(size: 18))
                    .fontWeight(.thin)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: userEmail) { oldValue, newValue in
                        let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@."
                        let filtered = newValue.filter { allowed.contains($0) }
                        if filtered != newValue {
                            userEmail = filtered
                        }
                    }
                
                Button("중복확인") {
                    let db = Firestore.firestore()
                    
                    guard !userEmail.isEmpty else {
                        alertMessage = "이메일을 입력해주세요."
                        showAlert = true
                        return
                    }
                    
                    let userRef = db.collection("users").document(userEmail)
                    userRef.getDocument { document, error in
                        if let error = error {
                            alertMessage = "에러 발생: \(error.localizedDescription)"
                            showAlert = true
                            return
                        }
                        
                        if let document = document, document.exists {
                            alertMessage = "이미 존재하는 이메일입니다."
                            showAlert = true
                        } else {
                            alertMessage = "사용 가능한 이메일입니다!"
                            showAlert = true
                        }
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .padding(15)
                .foregroundColor(.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                .frame(width: UIScreen.main.bounds.width / 4, height: 60, alignment: .trailing)
            }.frame(maxWidth: .infinity)
            
            if isEmailMatching {
                Text("이메일을 입력해주세요.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            
            HStack {
                Text("비밀번호")
                    .font(.headline)
                Spacer()
            }.padding(.top, 20)
            
            TextField("비밀번호를 입력하세요", text: $newPassword)
                .padding(15)
                .padding(.leading, 3)
                .font(.system(size: 18))
                .fontWeight(.thin)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1) 
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .onChange(of: newPassword) { oldValue, newValue in
                    let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
                    let filtered = newValue.filter { allowed.contains($0) }
                    if filtered != newValue {
                        newPassword = filtered
                    }
                }
            
            
            HStack {
                Text("비밀번호 확인")
                    .font(.headline)
                Spacer()
            }.padding(.top, 20)
            
            TextField("비밀번호를 다시 입력하세요", text: $newPasswordConfirm)
                .padding(15)
                .padding(.leading, 3)
                .font(.system(size: 18))
                .fontWeight(.thin)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .onChange(of: newPasswordConfirm) { oldValue, newValue in
                    let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
                    let filtered = newValue.filter { allowed.contains($0) }
                    if filtered != newValue {
                        newPasswordConfirm = filtered
                    }
                }
            
            if !isNewPasswordMatching {
                Text("입력한 비밀번호가 서로 다릅니다.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Text("닉네임")
                    .font(.headline)
                Spacer()
            }.padding(.top, 20)
            
            TextField("닉네임을 입력하세요", text: $userNickname)
                .padding(15)
                .padding(.leading, 3)
                .font(.system(size: 18))
                .fontWeight(.thin)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            
            
            if isNicknameMatching {
                Text("닉네임을 입력해주세요.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
        }
        .frame(maxWidth: .infinity)
        
        .padding(20)
        .padding(.horizontal, 5)
        .navigationTitle("가입하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    if !isNewPasswordMatching {
                        alertMessage = "비밀번호가 일치하지 않습니다."
                        showAlert = true
                    } else {
                        registerUser()
                    }
                }
                .foregroundColor(.black)
                
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }
    
}
    
    #Preview {
        RegisterView()
    }
    
