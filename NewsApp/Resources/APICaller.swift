//
//  APICaller.swift
//  NewsApp
//
//  Created by Pulkit Dhirana on 23/10/23.
//

import Foundation

final class APICaller {
    
    public var isPaginating = false

    static let shared = APICaller()
    
    private init() {}
    
    public func getTopStories(pageNumber: Int, pagination: Bool = false,completion: @escaping (Result<[Article],Error>) -> Void) {
        
        if pagination {
            isPaginating = true
        }
        
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=tesla&from=2023-10-16&pageSize=20&page=\(pageNumber)&sortBy=publishedAt&apiKey=3f76bb094a8045bfb04b3b5e89ea45ba") else {
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {[weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIResponseModel.self, from: data)
                    print("No. of articles: \(result.articles.count)")
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
            if pagination {
                self?.isPaginating = false
            }
            
        })
        task.resume()
    }
}
