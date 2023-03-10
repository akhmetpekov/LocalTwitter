//
//  PostsView.swift
//  LocalTwitter
//
//  Created by Erik on 26.01.2023.
//

import SwiftUI

struct PostsView: View {
    @State private var recentsPosts: [Post] = []
    @State private var createNewPost: Bool = false
    var body: some View {
        NavigationStack {
            ReusablePostsView(posts: $recentsPosts)
                .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                    .padding(15)
                }
                .navigationTitle("Post's")
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost { Post in
                recentsPosts.insert(Post, at: 0)
            }
        }
    }
    
    struct PostsView_Previews: PreviewProvider {
        static var previews: some View {
            PostsView()
        }
    }
}
