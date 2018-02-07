//
//  MasterViewController.swift
//  News
//
//  Created by Marton Kerekes on 07/02/2018.
//  Copyright © 2018 Marton Kerekes. All rights reserved.
//

import UIKit

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

    var detailViewController: DetailViewController? = nil
    var objects = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=dff8c6df3b934520a5fb63c547cdda1a") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

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
        }

        task.resume()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed        
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
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
}

