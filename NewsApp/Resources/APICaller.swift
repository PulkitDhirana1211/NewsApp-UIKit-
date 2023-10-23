//
//  APICaller.swift
//  NewsApp
//
//  Created by Pulkit Dhirana on 23/10/23.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    private init() {
        
    }
    
    public func getTopStories(completion: @escaping (Result<[Article],Error>) -> Void) {
        
        guard let url = Constant.topHeadlines else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
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
            
        })
        task.resume()
    }
}
