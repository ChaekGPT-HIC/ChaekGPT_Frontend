import SwiftUI
import FirebaseAuth

struct BookDetailView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject var viewModel: BookViewModel
    @State var book: Book
    @State private var showLoginAlert = false

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(alignment: .bottom, spacing: 10) {
                    Spacer()
                    
                    AsyncImage(url: URL(string: book.cover.decodedHTMLcover)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 250)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 250)
                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                                .overlay(alignment: .bottomLeading) {
                                    if let bookurl = URL(string: book.link) {
                                        Link(destination: bookurl) {
                                            Image(systemName: "book.closed.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 21, height: 21)
                                                .foregroundColor(.black.opacity(0.8))
                                                .padding(6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                        }
                                        .offset(x: -50, y: 0)
                                    }
                                }
                            
                                // 하트(북마크) 버튼
                                .overlay(alignment: .bottomTrailing) {
                                    Button {
                                        if authVM.isLoggedIn {
                                            // 로그인 상태 → 북마크 토글
                                            viewModel.toggleBookmark(for: book)
                                            book.isBookmarked.toggle()
                                        } else {
                                            // 로그인 안 되어 있으면 알림만 띄우기
                                            showLoginAlert = true
                                        }
                                    } label: {
                                        Image(systemName: book.isBookmarked ? "heart.fill" : "heart")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 21, height: 21)
                                            .foregroundColor(authVM.isLoggedIn
                                                             ? (book.isBookmarked ? .red : .black.opacity(0.8))
                                                             : .gray.opacity(0.5)) // 로그인 안 된 상태 → 회색
                                            .padding(6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    }
                                    .disabled(!authVM.isLoggedIn) // 로그인 안 되어 있으면 버튼 자체 비활성화
                                    .offset(x: 50, y: 0)
                                    .alert("로그인이 필요합니다", isPresented: $showLoginAlert) {
                                        Button("확인", role: .cancel) { }
                                    }
                                }

                            
                        case .failure:
                            Image(systemName: "xmark.octagon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.title2)
                        .bold()

                    Text("\(book.author) | \(book.publisher)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                
                    HStack(alignment: .top, spacing: 10){
                        Text("카테고리")
                            .font(.subheadline)
                            .foregroundColor(Color.black.opacity(0.7))
                        Text(book.categoryName)
                            .font(.subheadline)
                            .foregroundColor(Color.black.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if !book.emotion.isEmpty {
                        HStack(alignment: .top, spacing: 10){
                            Text("감정태그")
                                .font(.subheadline)
                                .foregroundColor(Color.black.opacity(0.7))
                            Text(book.emotion)
                                .font(.subheadline)
                                .foregroundColor(emotionColor(for: book.emotion))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Divider()
                        .frame(height: 1)
                        .background(Color.black.opacity(0.3))
                        .padding(.vertical, 10)

                    Text("책소개")
                        .font(.headline)
                        .foregroundColor(Color.black)
                        .padding(.bottom, 10)
                    
                    Text(book.description.decodedHTMLdescription)
                        .font(.body)
                        .foregroundColor(Color.black.opacity(0.8))
                        .lineSpacing(6)
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchUserBookmarks()
            if let updated = viewModel.allBooks.first(where: { $0.isbn13 == book.isbn13 }) {
                book.isBookmarked = updated.isBookmarked
            }
            
        }
    }
}


// 감정별 폰트 색상 변경
func emotionColor(for emotion: String) -> Color {
    switch emotion {
    case "감동":
        return Color(red: 1.0, green: 0.72, blue: 0.45)
    case "공포":
        return Color(red: 0.55, green: 0.50, blue: 0.72)
    case "분노":
        return Color(red: 0.82, green: 0.40, blue: 0.40)
    case "불안":
        return Color(red: 0.42, green: 0.48, blue: 0.60)
    case "쉬움":
        return Color(red: 20/255, green: 32/255, blue: 55/255)
    case "슬픔":
        return Color(red: 0.50, green: 0.65, blue: 0.82)
    case "중립":
        return Color(red: 0.70, green: 0.70, blue: 0.70)
    case "흥미":
        return Color(red: 0.85, green: 0.60, blue: 0.70)
    default:
        return Color(red: 20/255, green: 32/255, blue: 55/255)
    }
}

extension String {
    var decodedHTMLcover: String {
        return self
            .replacingOccurrences(of: "coversum", with: "cover")
    }
    
    var decodedHTMLdescription: String {
        return self
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}

