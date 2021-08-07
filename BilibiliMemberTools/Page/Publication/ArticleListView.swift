//
//  Created by ktiays on 2021/7/27.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI
import Introspect
import SDWebImageSwiftUI

struct ArticleListView: View {
    
    @StateObject private var cacher = UserDataManager.cacher
    private var articles: [ArticleModel] { cacher.articles.map { ArticleModel(article: $0) } }
    
    @Environment(\.innerBottomPadding) private var innerBottomPadding
    
    var body: some View {
        List {
            ForEach(articles) { article in
                ArticleCard(article: article.article)
                    .padding(.bottom, 20)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .ignoresSafeArea()
        .introspectTableView { tableView in
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
            tableView.verticalScrollIndicatorInsets = .init(
                top: 0, left: 0, bottom: innerBottomPadding, right: 0
            )
            tableView.contentInset = .init(top: 8, left: 0, bottom: innerBottomPadding - 36, right: 0)
        }
        .task {
            if articles.isEmpty { UserDataManager.default.requestArticles() }
        }
    }
    
}

fileprivate struct ArticleModel: Identifiable {
    
    var id: String { article.cv }
    var article: Article
    
}

// MARK: - Article Card View

fileprivate struct ArticleCard: View {
    
    var article: Article
    
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: article.coverURL))
                .placeholder {
                    Image(uiImage: UIImage())
                        .resizable()
                        .redacted(reason: .placeholder)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .unredacted()
                .frame(width: 120, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .foregroundColor(.init(.label))
                    .font(.system(size: 13))
                    .lineSpacing(4)
                Text(article.publishedTime.formattedString)
                    .font(.system(size: 12))
                    .foregroundColor(.init(.label).opacity(0.7))
                HStack(spacing: 12) {
                    InteractiveTag(image: Image(systemName: "eye"),
                                   value: article.status.views.integerDescription)
                    InteractiveTag(image: Image(systemName: "text.bubble.fill"),
                                   value: article.status.replies.integerDescription)
                }
            }
        }
    }
    
}

// MARK: - Preview

struct ArticleListView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleListView()
        ArticleCard(article: Article(cv: "23333", title: "一篇很长很长很长很长很长很长很长很长的文章", summary: "哈哈哈", coverURL: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201701%2F04%2F20170104173817_TsG8t.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1629973613&t=904750b16ba06812933535bc9cc13d4e", url: "", publishedTime: Date(), status: Article.Status(views: 100, replies: 289328, likes: 3487, dislikes: 3987, coins: 89768, favorites: 9879, shares: 9871)))
    }
}
