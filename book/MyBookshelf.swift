import SwiftUI
import SDWebImageSwiftUI

struct MyBookshelf: View {
    @ObservedObject var viewModel: BookViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                ForEach(viewModel.allBooks.filter { $0.isBookmarked }) { book in
                    NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                        HStack(spacing: 15) {
                            AsyncImage(url: URL(string: book.cover)) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchUserBookmarks()
        }
        .navigationTitle("내 서재")
    }
}
