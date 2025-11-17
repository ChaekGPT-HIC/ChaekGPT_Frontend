import SwiftUI

struct MyPassword: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var password: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var newPasswordConfirm: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var isNewPasswordMatching: Bool {
        newPasswordConfirm.isEmpty || newPassword == newPasswordConfirm
    }
    
    
    var body: some View {
        ScrollView{
            HStack {
                Text("현재 비밀번호")
                    .font(.headline)
                Spacer()
            }
            
            TextField("현재 비밀번호를 입력하세요", text: $currentPassword)
                .padding(15)
                .padding(.leading, 3)
                .font(.system(size: 18))
                .fontWeight(.thin)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1) // 테두리 선
                )
                .padding(.bottom, 20)
            
            
            HStack {
                Text("새로운 비밀번호")
                    .font(.headline)
                Spacer()
            }
            
            TextField("새로운 비밀번호를 입력하세요", text: $newPassword)
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
                .padding(.bottom, 20)
            
            HStack {
                Text("새로운 비밀번호 확인")
                    .font(.headline)
                Spacer()
            }
            
            TextField("새로운 비밀번호를 입력하세요", text: $newPasswordConfirm)
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
            
            if !isNewPasswordMatching {
                Text("입력한 비밀번호가 서로 다릅니다.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
            }
            
        }.padding(20)
        
        
            .navigationTitle("비밀번호 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        if currentPassword != password {
                            alertMessage = "현재 비밀번호가 올바르지 않습니다."
                            showAlert = true
                        } else if !isNewPasswordMatching {
                            alertMessage = "새로운 비밀번호가 일치하지 않습니다."
                            showAlert = true
                        } else {
                            print("비밀번호 변경 완료")
                        }}
                    .foregroundColor(.black) // 버튼 색상 조절 가능
                    
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("비밀번호 오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
    }
}


#Preview {
    MyPassword()
}

