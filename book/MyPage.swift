import SwiftUI
import KakaoSDKUser

struct MyPage: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject var viewModel: BookViewModel
    
    
    @State var showLogoutPopup: Bool = false
    @State var showWithdrawPopup: Bool = false
    
    var body: some View {
        ZStack {
            if authVM.isLoggedIn {
                loggedInView
            } else {
                loggedOutView
            }
            
            // 로그아웃 팝업
            if showLogoutPopup {
                logoutpopupView(
                    title: "로그아웃 하시겠습니까?",
                    confirmAction: {
                        authVM.logout()
                        showLogoutPopup = false
                    },
                    cancelAction: { showLogoutPopup = false }
                )
            }
            
            // 회원탈퇴 팝업
            if showWithdrawPopup {
                quitpopupView(
                    title: "탈퇴하시겠습니까?",
                    confirmAction: {
                        authVM.withdraw()
                        showWithdrawPopup = false
                    },
                    cancelAction: { showWithdrawPopup = false }
                )
            }
        }
        .animation(.easeInOut, value: showLogoutPopup)
        .animation(.easeInOut, value: showWithdrawPopup)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $authVM.showAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text(authVM.alertMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
    }
    
    
    private var loggedInView: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        NavigationLink(destination: MyPageModify()) {
                            Text("닉네임")
                                .padding(.leading, 5)
                            Spacer()
                            Text(authVM.nickname)
                            Image(systemName: "chevron.right")
                        }.padding(.top, 10)
                            .padding(.bottom, 10)
                    }
                    
                    Divider().padding(.vertical, 3)
                    
                    HStack {
                        NavigationLink(destination: MyBookshelf(viewModel: viewModel)) {
                            Text("내 서재")
                                .padding(.leading, 5)
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                    
                    .padding(.bottom, 36)
                    
                    VStack(spacing: 16) {
                        Button("로그아웃") { showLogoutPopup = true }
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                        
                        
                        if authVM.provider == "email" {
                            Button("회원탈퇴") { showWithdrawPopup = true }
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.top, 15)
                        }
                    }


                    
                }
                .padding(.horizontal)
                .onAppear{
                    if authVM.isLoggedIn {
                        authVM.refreshUserInfo()
                    }
                }
            }
        }
    }

    private var loggedOutView: some View {
        VStack(spacing: 10) {
            Text("로그인이 필요한 서비스입니다.")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("로그인하시겠습니까?")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.bottom, 40)
            
            
            NavigationLink(destination: LoginView(path: $path)) {
                Text("로그인 하러가기")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private func logoutpopupView(
        title: String,
        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 24) {
            // 메시지
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.top, 10)

            // 버튼 영역
            VStack(spacing: 12) {
                Button(action: confirmAction) {
                    Text("로그아웃")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.red)
                        .cornerRadius(12)
                }

                Button(action: cancelAction) {
                    Text("취소")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 320)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 40)
    }
    
    private func quitpopupView(
        title: String,
        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 24) {
            // 메시지
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.top, 10)

            // 버튼 영역
            VStack(spacing: 12) {
                Button(action: confirmAction) {
                    Text("탈퇴하기")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.red)
                        .cornerRadius(12)
                }

                Button(action: cancelAction) {
                    Text("취소")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 320)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 40)
    }

}


