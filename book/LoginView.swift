import SwiftUI
import FirebaseFirestore

struct LoginView: View {
    @Binding var path: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var userInfo: String = ""
    
    var body: some View {
        VStack{
            Text("로그인")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, 100)
                
        }.padding(.top, 70)
        
        VStack{
            // 이메일 로그인 버튼
            NavigationLink(destination: LoginEmailView(path: $path)) {
                Text("이메일로 로그인하기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.bottom, 10)
            }
             
            HStack{
                Text("아직 회원이 아니신가요?")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                NavigationLink(destination: RegisterView()) {
                    Text("가입하기")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .padding(.trailing,5)
                }
                
            }
            .padding(.top, 15)
            
        }
        .padding(.horizontal)
        .padding(.bottom, 170)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
