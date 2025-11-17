import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
    @State private var selectedSearch: String? = nil
    @State private var navigateToResults = false
    @State private var lastQuery: String = ""
    @State private var detectedEmotion: String = ""

    @StateObject var viewModel = BookViewModel()

    
    
    var body: some View {
        NavigationStack {
            
            VStack {
                // 검색창
                HStack {
                    TextField("검색어를 입력하세요", text: $searchText)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        performSearch()   // 버튼 누르면 검색 + 이동
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .padding(5)
                
                // 최근 검색어
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("최근 검색어")
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("전체 삭제") {
                                recentSearches.removeAll()
                                UserDefaults.standard.removeObject(forKey: "RecentSearches")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top)
                        }
                        .padding(.bottom, 10)
                        
                        ForEach(recentSearches, id: \.self) { term in
                            HStack {
                                Text(term)
                                    .foregroundColor(.gray)
                                    .onTapGesture {
                                        searchText = term
                                        performSearch()
                                        selectedSearch = term
                                        navigateToResults = true
                                    }
                                
                                Spacer()
                                
                                Button(action: {
                                    deleteSearch(term)
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 7)
                    }
                    .padding(.horizontal)
                } else {
                    Text("최근 검색 내역이 없습니다.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.top, 10)
                }
                
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            .navigationTitle("")
            .navigationDestination(isPresented: $navigateToResults) {
                SearchResultView(viewModel: viewModel, query: lastQuery, emotion: detectedEmotion)

            }

            

        }
    }
    
    // 검색 수행 함수
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // 최근 검색어 업데이트
        if let index = recentSearches.firstIndex(of: searchText) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(searchText, at: 0)
        if recentSearches.count > 3 {
            recentSearches = Array(recentSearches.prefix(3))
        }
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
        
        lastQuery = searchText
        callNgrokAPI(query: searchText)
        
        navigateToResults = true
        searchText = ""
    }
    
    // ngrok API 요청
    func callNgrokAPI(query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://wailful-appreciatingly-juli.ngrok-free.dev/analyze?query=\(encodedQuery)") else {
            print("잘못된 URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("true", forHTTPHeaderField: "ngrok-skip-browser-warning")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("API Error:", error)
            }

            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let emotion = json["emotion"] as? String {
                        DispatchQueue.main.async {
                            self.detectedEmotion = emotion
                            self.navigateToResults = true
                        }
                    }
                } else {
                    print(String(data: data, encoding: .utf8) ?? "")
                }
            }
        }.resume()
    }


    
    func deleteSearch(_ term: String) {
        if let index = recentSearches.firstIndex(of: term) {
            recentSearches.remove(at: index)
            UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
        }
    }
}

