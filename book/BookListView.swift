import SwiftUI

struct BookListView: View {
    @StateObject private var viewModel = BookViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.allBooks) { book in
                NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                    HStack(alignment: .top, spacing: 10) {
                        AsyncImage(url: URL(string: book.cover)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 120)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 120)
                                    .cornerRadius(8)
                                    .clipped()
                            case .failure:
                                Image(systemName: "xmark.octagon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 120)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }

                        // 책 정보
                        VStack(alignment: .leading, spacing: 6) {
                            Text(book.title)
                                .font(.headline)
                                .lineLimit(2)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(book.description)
                                .lineLimit(3)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .navigationTitle("전체 도서 목록")
            .onAppear {
                viewModel.fetchAllBooks()
            }
        }
    }
}

#Preview {
    BookListView()
}

