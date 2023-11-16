//
//  ViewController.swift
//  NewsApp
//
//  Created by Pulkit Dhirana on 23/10/23.
//

import UIKit
import SafariServices

// TableView
// Custom Cell
// API Caller
// Open the News Story

class ViewController: UIViewController {
    
    static var pageNumber = 1
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinnerView = UIActivityIndicatorView()
        spinnerView.center = footerView.center
        footerView.addSubview(spinnerView)
        spinnerView.startAnimating()
        return footerView
    }
    
    private var articles = [Article]()
    private var viewModels = [NewsTableViewCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        fetchTopStories(with: ViewController.pageNumber)
    }
    
    private func fetchTopStories(with pageNumber: Int) {
        APICaller.shared.getTopStories(pageNumber: pageNumber) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No Description",
                        imageURL: URL(string: $0.urlToImage ?? "")
                    )
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

}
//MARK: - TableView Delegate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url) else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
//MARK: - ScrollView Delegate Methods
extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height-300 - scrollView.frame.size.height) {
            
            print("\(ViewController.pageNumber) pageNumber")
            guard !APICaller.shared.isPaginating else {
                return
            }
            self.tableView.tableFooterView = createSpinnerFooter()
            
            ViewController.pageNumber += 1
            
            
            APICaller.shared.getTopStories(pageNumber: ViewController.pageNumber+1, pagination: true) { [weak self] result in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.tableView.tableFooterView = nil
                }
                
                switch result {
                case .success(let newArticles):
                     var newViewModels = [NewsTableViewCellViewModel]()
                    
                    self?.articles.append(contentsOf: newArticles)
                    
                    newViewModels = newArticles.compactMap({
                        NewsTableViewCellViewModel(
                            title: $0.title,
                            subtitle: $0.description ?? "No Description",
                            imageURL: URL(string: $0.urlToImage ?? "")
                        )
                    })
                    
                    self?.viewModels.append(contentsOf: newViewModels)
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
    }
}
