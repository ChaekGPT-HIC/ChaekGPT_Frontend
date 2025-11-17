import SwiftUI
import FirebaseAuth

struct LoginEmailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @Binding var path: NavigationPath
    
    @State private var userEmail: String = ""
    @State private var userPW: String = ""
 
    
    var body: some View{
        VStack{
            Text("로그인")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, 40)
            
            HStack {
                Text("아이디")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                TextField("이메일을 입력하세요", text: $userEmail)
                    .padding(15)
                    .padding(.leading, 3)
                    .font(.system(size: 18))
                    .fontWeight(.thin)
                    .cornerRadius(10)
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
            }.padding(.bottom, 10)
            
            HStack {
                Text("비밀번호")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                SecureField("비밀번호를 입력하세요", text: $userPW) // 🔒 보안 입력 권장
                    .padding(15)
                    .padding(.leading, 3)
                    .font(.system(size: 18))
                    .fontWeight(.thin)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: userPW) { oldValue, newValue in
                        let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
                        let filtered = newValue.filter { allowed.contains($0) }
                        if filtered != newValue {
                            userPW = filtered
                        }
                    }
            }
            
            // path.removeLast(path.count)
            // path.append("main")
            
            Button(action: {
                authVM.loginWithEmail(email: userEmail, password: userPW) { success in
                    if success {
                        print("이메일 로그인 성공")
                        
                        path = NavigationPath()   // 스택 비우고
                                path.append("main")
                    } else {
                        print("이메일 로그인 실패")
                    }
                }
            }) {
                Text("로그인")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.top, 30)
            }
        }.padding(20)
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
    }
}

