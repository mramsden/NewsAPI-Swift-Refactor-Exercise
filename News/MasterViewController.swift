//
//  MasterViewController.swift
//  News
//
//  Created by Marton Kerekes on 07/02/2018.
//  Copyright © 2018 Marton Kerekes. All rights reserved.
//

import UIKit
import SafariServices

struct Response: Codable {
    var status: String?
    var totalResults: Int?
    var articles: [Article]?
}

struct Article: Codable {
    var author: String?
    var title: String?
    var desc: String?
    var imageUrl: String?
    var url: String?

    init(author: String, title: String, desc: String, imageUrl: String, url: String) {
        self.author = author
        self.title = title
        self.desc = desc
        self.imageUrl = imageUrl
        self.url = url
    }
}

class MasterViewController: UITableViewController {

    var objects = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=dff8c6df3b934520a5fb63c547cdda1a") else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, let results = try? JSONDecoder().decode(Response.self, from: data), let articles = results.articles else {

                guard let error = error else {
                    return
                }
                let alert = UIAlertController(title: "Oups", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                    alert.dismiss(animated: true)
                }))
                self.present(alert, animated: true)
                return
            }
            self.objects = articles
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = objects[indexPath.row]

        guard let value = object.url, let url = URL(string:value) else {
            return
        }
        present(SFSafariViewController(url: url), animated: true)
    }
}

