import SwiftUI

struct SearchResultView: View {
    @State private var allResults: [Book] = []
    @State private var pagedResults: [Book] = []
    @State private var isLoading = true
    @State private var currentPage: Int = 1
    @State private var hasLoaded = false

    @ObservedObject var viewModel: BookViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let query: String
    let emotion: String

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isLoading {
                ProgressView("검색 중...")
                    .font(.title3)
                    .padding()
            }
            else if allResults.isEmpty {
                VStack {
                    Text("“\(query)”")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                }
            }
            else {
                VStack {
                    Text("“\(query)”")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)

                    
                    ScrollView {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                            spacing: 16
                        ) {
                            ForEach(pagedResults) { book in
                                BookDetailView(viewModel: viewModel, book: book)
                                } label: {
                                    BookItemView(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                    }

                    // 페이지 버튼
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { page in
                            Button(action: {
                                currentPage = page
                                updatePagedResults()
                            }) {
                                Text("\(page)")
                                    .font(.system(size: 15))
                                    .fontWeight(currentPage == page ? .bold : .regular)
                                    .foregroundColor(currentPage == page ? .black : .gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle("검색결과")
        .onAppear {
            guard !hasLoaded else { return }
                        hasLoaded = true
            
            if viewModel.allBooks.isEmpty {
                viewModel.fetchAllBooks()
            }
            
            fetchPageSequentially(query: query, emotion: emotion, page: 1)
        }
    }

    // 순차 페이지 로딩
    func fetchPageSequentially(query: String, emotion: String, page: Int) {
        if page > 5 {
            // 모든 페이지 완료
            DispatchQueue.main.async {
                self.allResults.sort { $0.similarity > $1.similarity }
                self.updatePagedResults()
                self.isLoading = false
            }
            return
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // https://katia-surbased-lester.ngrok-free.dev 민서
        // https://wailful-appreciatingly-juli.ngrok-free.dev 현지
        guard let url = URL(string:
            "https://wailful-appreciatingly-juli.ngrok-free.dev/v1/recommend?q=\(encodedQuery)&emotion=\(emotion)&page=\(page)&page_size=9"
        ) else {
            fetchPageSequentially(query: query, emotion: emotion, page: page + 1)
            return
        }

        var request = URLRequest(url: url, timeoutInterval: 60) // 타임아웃 60초로 증가
        request.httpMethod = "GET"
        request.addValue("true", forHTTPHeaderField: "ngrok-skip-browser-warning")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Error on page \(page):", error)
                // 다음 페이지로 넘어감 (앱 안 멈춤)
                fetchPageSequentially(query: query, emotion: emotion, page: page + 1)
                return
            }

            if let data = data,
               let decoded = try? JSONDecoder().decode(RecommendResponse.self, from: data) {

                let items = decoded.items.map { item in
                    Book(
                        title: item.title,
                        author: item.author,
                        description: "",
                        cover: item.cover,
                        isbn13: item.isbn13,
                        publisher: item.publisher,
                        categoryName: "",
                        emotion: emotion,
                        link: "",
                        similarity: item.similarity,
                        isBookmarked: false
                    )
                }

                DispatchQueue.main.async {
                    self.allResults.append(contentsOf: items)
                }
            }

            // 다음 페이지로 이동
            fetchPageSequentially(query: query, emotion: emotion, page: page + 1)

        }.resume()
    }

    func updatePagedResults() {
        let start = (currentPage - 1) * 9
        let end = min(start + 9, allResults.count)

        if start < end {
            self.pagedResults = Array(allResults[start..<end])
        } else {
            self.pagedResults = []
        }
    }
}

struct BookItemView: View {
    let book: Book

    var body: some View {
        VStack(spacing: 6) {
            AsyncImage(url: URL(string: book.cover)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 140)
                    .cornerRadius(8)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 140)
                    .cornerRadius(8)
            }

            Text(book.title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 30)

            Text("유사도 \(Int(book.similarity * 100))%")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(4)
        .frame(width: 110)
    }
}

