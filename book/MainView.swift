import SwiftUI
import SDWebImageSwiftUI

struct MainView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = BookViewModel()
    
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // 상단 바
                    HStack {
                        Spacer()
                        NavigationLink(destination: SearchView(viewModel: viewModel)) {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                        NavigationLink(destination: MyPage(path: $path, viewModel: viewModel)) {
                            Image(systemName: "line.horizontal.3")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                        }
                    }
                    .frame(height: 60)
                    .background(Color.white)
                    
                    // 검색창
                    NavigationLink(destination: SearchView(viewModel: viewModel)) {
                        HStack {
                            Text("검색어를 입력하세요")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .padding(.bottom, 10)
                        .padding(.top, 5)
                    }
                    
                    // 오늘의 책 추천
                    VStack(alignment: .leading, spacing: 10) {
                        Text("오늘의 책 추천 📚")
                                .font(.system(size: 25, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if viewModel.recommendedBooks.isEmpty {
                                ProgressView("책을 불러오는 중...")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .multilineTextAlignment(.center)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .font(.subheadline)
                            } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.recommendedBooks) { book in
                                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                WebImage(url: URL(string: book.cover)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 120, height: 180)
                                                .cornerRadius(10)
                                                .shadow(radius: 2)
                 
                                                Text(book.title)
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                                    .lineLimit(2)
                                                    .frame(width: 120, alignment: .leading)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 15)
                    
                    // 감정 태그별 추천
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(viewModel.selectedEmotionTag) 감정의 책 추천 📚")
                            .font(.system(size: 25, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                      
                        if viewModel.recommendedBooks.isEmpty {
                            ProgressView("책을 불러오는 중...")
                                .frame(maxWidth: .infinity) // 가로 전체 차지
                                .padding(.vertical, 20)
                                .multilineTextAlignment(.center)
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .font(.subheadline)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.emotionRecommendedBooks) { book in
                                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                WebImage(url: URL(string: book.cover)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 120, height: 180)
                                                .cornerRadius(10)
                                                .shadow(radius: 2)


                                                Text(book.title)
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                                    .lineLimit(2)
                                                    .frame(width: 120, alignment: .leading)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            viewModel.fetchAllBooks()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

