//
//  APIResponseModel.swift
//  NewsApp
//
//  Created by Pulkit Dhirana on 23/10/23.
//

import Foundation

// MARK: - APIResponseModel
struct APIResponseModel: Codable {
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
//    let id: String?
//    var hashValue: Int { get { return id.hashValue } }
//    static func == (lhs: Article, rhs: Article) -> Bool {
//        lhs.source.id == rhs.source.id
//    }
    
    let source: Source
//    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
//    let content: String?
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}
