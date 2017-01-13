//
//  ViewController.swift
//  NewsApp
//
//  Created by 黃毓皓 on 2017/1/13.
//  Copyright © 2017年 ice elson. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    var articles:[Article]? = []//產生一個陣列裡面是放article物件
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
    }
    
    func fetchArticles(){
        let urlRequest  = URLRequest(url: URL(string: "https://newsapi.org/v1/articles?source=techcrunch&sortBy=top&apiKey=56b2313b160b4672b6201129a2a54565")!)  //先取得request
        let task = URLSession.shared.dataTask(with: urlRequest){ //建立task
            (data,response,error) in
            if error != nil {
                print(error)
                return
            }
            self.articles = [Article]() //將articles陣列裡設為空的
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject] //解析json會丟出throw 要用try接
                if let articlesFromJson = json["articles"] as? [[String:AnyObject]] {
                    for articleFromJson in articlesFromJson {
                        let article = Article() //建立article物件
                        if let title = articleFromJson["title"] as? String,let author = articleFromJson["author"] as? String , let desc = articleFromJson["description"] as? String,let url = articleFromJson["url"] as? String , let urlToImage = articleFromJson["urlToImage"] as? String{
                            
                            article.author = author
                            article.desc = desc
                            article.headline = title
                            article.url = url
                            article.imageUrl = urlToImage
                            
                        }
                        self.articles?.append(article)
                    }
                }
                DispatchQueue.main.async {
                    self.tableview.reloadData() //畫面更新要寫在主執行緒
                }
            }
            catch let error{
                print(error)
            }
        }
        task.resume() //記得執行task
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
        cell.title.text = self.articles?[indexPath.item].headline
        cell.desc.text = self.articles?[indexPath.item].desc
        cell.author.text = self.articles?[indexPath.item].author
        
        cell.imgView.downloadImage(from: (self.articles?[indexPath.item].imageUrl)!)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles?.count ?? 0
    }


}

extension UIImageView{
    func downloadImage(from url:String){
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            (data,response,error) in
            if error != nil {
                print(error)
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
