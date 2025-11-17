import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine 

class BookViewModel: ObservableObject {
    @Published var allBooks: [Book] = []
    @Published var recommendedBooks: [Book] = []
    @Published var emotionRecommendedBooks: [Book] = []
    @Published var selectedEmotionTag: String = ""       
    @Published var searchResults: [Book] = []
    @Published var bookmarkedBooks: [Book] = []
    
    private var db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    
    private let recommendationKey = "savedRecommendedBooks"
    private let recommendationDateKey = "recommendationDate"
    private let emotionTagKey = "savedEmotionTag"
    private let emotionBooksKey = "savedEmotionBooks"
    private let emotionDateKey = "emotionRecommendationDate"
    
    // MARK: - 전체 도서 불러오기
    func fetchAllBooks() {
        db.collection("books").getDocuments { snapshot, error in
            if let error = error {
                print("Firestore 에러: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("문서 없음")
                return
            }
            
            let loadedBooks = documents.compactMap { doc -> Book? in
                let data = doc.data()
                guard
                    let title = data["title"] as? String,
                    let author = data["author"] as? String,
                    let description = data["description"] as? String,
                    let cover = data["cover"] as? String,
                    let isbn13 = data["isbn13"] as? String,
                    let publisher = data["publisher"] as? String,
                    let categoryName = data["categoryName"] as? String,
                    let emotion = data["emotion"] as? String,
                    let link = data["link"] as? String
                    
                else { return nil }
                
                return Book(
                    title: title,
                    author: author,
                    description: description,
                    cover: cover,
                    isbn13: isbn13,
                    publisher: publisher,
                    categoryName: categoryName,
                    emotion: emotion,
                    link: link
                )
            }
            DispatchQueue.main.async {
                self.allBooks = loadedBooks
                self.loadOrGenerateDailyRecommendations()
                self.loadOrGenerateDailyEmotionRecommendations()
            }

        }
    }

    // 오늘의 책 추천 (하루에 한 번)
    private func loadOrGenerateDailyRecommendations() {
        let today = formattedToday()
        
        if let savedDate = userDefaults.string(forKey: recommendationDateKey),
           savedDate == today,
           let savedISBNs = userDefaults.array(forKey: recommendationKey) as? [String] {
            
            self.recommendedBooks = self.allBooks.filter { savedISBNs.contains($0.isbn13) }
        } else {
            generateNewDailyRecommendations()
        }
    }

    private func generateNewDailyRecommendations() {
        let selected = Array(allBooks.shuffled().prefix(10))
        self.recommendedBooks = selected
        
        let isbnList = selected.map { $0.isbn13 }
        userDefaults.set(isbnList, forKey: recommendationKey)
        userDefaults.set(formattedToday(), forKey: recommendationDateKey)
    }

    // 감정태그별 추천 (앱 실행 시 한 번만)
    private func loadOrGenerateDailyEmotionRecommendations() {
        // 이미 감정이 설정되어 있다면 다시 생성하지 않음
        guard self.selectedEmotionTag.isEmpty else {
            return
        }
        
        // Firestore 데이터가 아직 비어 있으면 잠시 대기 후 다시 시도
        guard !allBooks.isEmpty else {
            print("allBooks 비어 있음")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.loadOrGenerateDailyEmotionRecommendations()
            }
            return
        }
        
        // 감정 랜덤 선택
        let possibleTags = ["감동", "공포", "분노", "불안", "쉬움", "슬픔", "중립", "흥미"]
        guard let randomTag = possibleTags.randomElement() else { return }
        self.selectedEmotionTag = randomTag
        
        // 해당 감정의 책 중 랜덤 10권
        let filteredBooks = allBooks.filter { $0.emotion == randomTag }
        let selected = Array(filteredBooks.shuffled().prefix(10))
        self.emotionRecommendedBooks = selected
    }


    func searchBooks(keyword: String) {
        let lowerKeyword = keyword.lowercased()
        DispatchQueue.main.async {
            self.searchResults = self.allBooks.filter {
                $0.title.lowercased().contains(lowerKeyword) ||
                $0.author.lowercased().contains(lowerKeyword) ||
                $0.publisher.lowercased().contains(lowerKeyword)
            }
        }
    }

    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

extension BookViewModel {

    // 북마크 토글
    func toggleBookmark(for book: Book) {
        
        if let user = Auth.auth().currentUser {
            print("로그인된 이메일:", user.email ?? "익명", "UID:", user.uid)
        } else {
            print("아직 로그인 안 됨")
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            print("로그인된 유저 없음")
            return
        }
        print("현재 로그인 UID:", Auth.auth().currentUser?.uid ?? "nil")


        let docRef = db.collection("users").document(uid).collection("bookshelf").document(book.isbn13)

        if book.isBookmarked {
            // 이미 북마크된 경우 → 삭제
            docRef.delete { error in
                if let error = error {
                    print("북마크 삭제 실패: \(error.localizedDescription)")
                } else {
                    print("북마크 해제됨: \(book.title)")
                    DispatchQueue.main.async {
                        if let index = self.allBooks.firstIndex(where: { $0.isbn13 == book.isbn13 }) {
                            self.allBooks[index].isBookmarked = false
                        }
                    }
                }
            }
        } else {
            // 북마크 추가
            let data: [String: Any] = [
                "title": book.title,
                "author": book.author,
                "cover": book.cover,
                "isbn13": book.isbn13,
                "timestamp": FieldValue.serverTimestamp()
            ]
            docRef.setData(data) { error in
                if let error = error {
                    print("북마크 추가 실패: \(error.localizedDescription)")
                } else {
                    print("북마크 추가됨: \(book.title)")
                    DispatchQueue.main.async {
                        if let index = self.allBooks.firstIndex(where: { $0.isbn13 == book.isbn13 }) {
                            self.allBooks[index].isBookmarked = true
                        }
                    }
                }
            }
        }
    }

    // 유저의 bookshelf 불러오기
    func fetchUserBookmarks() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("bookshelf").getDocuments { snapshot, error in
            if let error = error {
                print("북마크 불러오기 실패: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            
            let bookmarkedISBNs = documents.map { $0.documentID }
            DispatchQueue.main.async {
                self.allBooks = self.allBooks.map { book in
                    var updatedBook = book
                    updatedBook.isBookmarked = bookmarkedISBNs.contains(book.isbn13)
                    return updatedBook
                }
            }
        }
    }
}

extension BookViewModel {
    func fetchBookDetail(by isbn13: String, completion: @escaping (Book?) -> Void) {
        let db = Firestore.firestore()
        db.collection("books").whereField("isbn13", isEqualTo: isbn13)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("책 불러오기 실패:", error)
                    completion(nil)
                    return
                }

                if let doc = snapshot?.documents.first {
                    do {
                        let book = try doc.data(as: Book.self)
                        completion(book)
                    } catch {
                        print("디코딩 실패:", error)
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
    }
}
