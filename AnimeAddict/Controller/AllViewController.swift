//
//  ViewController.swift
//  AnimeAddict
//
//  Created by Tony Mark on 4/8/19.
//  Copyright © 2019 Tony Mark. All rights reserved.
//

import UIKit
import NotificationCenter

class AllViewController: UITableViewController {
    var data = [CellData]()
    var malData = [Anime]()
    var profile = "Tmark"
    var url = ""
    let refreshButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    var cookies = [HTTPCookie]()
    var csrf: String?
    var date: Date?
    
    let dispatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        url = "https://api.jikan.moe/v3/user/" + profile + "/animelist/all"
        print(url)

        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
        self.tableView.indicatorStyle = UIScrollView.IndicatorStyle.white
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = 90
        self.tableView.separatorColor = .clear
        self.tableView.allowsSelection = false
        self.title = "All"
        self.tabBarItem.title = "All"
        self.navigationItem.title = "All"
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        let temp = httpHandler().get(url: url)
        if temp.1 == 200 || temp.1 == 304 {
            malData = temp.0
            loadData()
            date = Date()
        } else {
            print("didn't work")
        }
        
        makeButton()
        if malData.count > 0 {
            refreshButton.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        cell.mal_id = data[indexPath.row].mal_id!
        cell.title = data[indexPath.row].title! + " " + String(indexPath.row)
        cell.mainImage = data[indexPath.row].image
        cell.watching_status = data[indexPath.row].watching_status!
        cell.score = data[indexPath.row].score!
        cell.watched_episodes = data[indexPath.row].watched_episodes!
        cell.total_episodes = data[indexPath.row].total_episodes
        cell.tags = data[indexPath.row].tags
        cell.layoutSubviews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_ :)))
        cell.mainImageView.isUserInteractionEnabled = true
        cell.mainImageView.addGestureRecognizer(tap)
        cell.plusButton.addTarget(self, action: #selector(doUpdate), for: .touchUpInside)
        cell.plusButton.setTitle("<", for: .normal)
        if cell.watching_status == 1 {
            cell.plusButton.isHidden = true
        }
        //cell.fullButton.addTarget(self, action: #selector(doFullView), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = data.count
        if indexPath.row == lastItem - 1 {
            loadMoreData()
        }
    }
    
    func loadData() -> Int{
        if malData.count == 0 {
            return -1
        }
        print("removing data")
        data.removeAll()
        let max = (malData.count > 20 ? 20 : malData.count)
        print("adding data")
        for index in 0..<max {
            let image = try? UIImage(data: try! Data(contentsOf: URL(string: malData[index].image_url!)!))
            data.append(CellData.init(mal_id: malData[index].mal_id, title: malData[index].title, image: image!, watching_status: malData[index].watching_status, score: malData[index].score, watched_episodes: malData[index].watched_episodes, total_episodes: malData[index].total_episodes, tags: malData[index].tags))
        }
        tableView.reloadData()
        return max
    }
    
    func loadMoreData() {
        if data.count < malData.count {
            let maxRow = (malData.count - data.count > 19 ? data.count + 19 : malData.count-1)
            for index in data.count...maxRow {
                let image = try? UIImage(data: try! Data(contentsOf: URL(string: malData[index].image_url!)!))
                data.append(CellData.init(mal_id: malData[index].mal_id, title: malData[index].title, image: image!, watching_status: malData[index].watching_status, score: malData[index].score, watched_episodes: malData[index].watched_episodes, total_episodes: malData[index].total_episodes, tags: malData[index].tags))
            }
            tableView.reloadData()
        }
    }
    
    func makeButton() {
        refreshButton.isEnabled = true
        refreshButton.isHidden = false
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.titleLabel?.font = UIFont(name: "HiraginoSans-W6", size: 12)
        refreshButton.backgroundColor = .gray
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        refreshButton.center = self.view.center
        refreshButton.layer.masksToBounds = true
        refreshButton.layer.cornerRadius = 10
        self.view.addSubview(refreshButton)
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        newImageView.frame = self.tableView.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        newImageView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {newImageView.alpha = 1.0})
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {sender.view?.alpha = 0.0}) { (done:Bool) in
            sender.view?.removeFromSuperview()
            self.navigationController?.isNavigationBarHidden = false
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        print("start0")
        if date != nil {
            print(date?.timeIntervalSinceNow)
            if (date?.timeIntervalSinceNow)! < TimeInterval(-300) {
                let temp = httpHandler().get(url: url)
                if temp.1 == 200 || malData.isEmpty{
                    malData = temp.0
                    loadData()
                    date = Date()
                } else if temp.1 == 304 {
                    print("nothing to update")
                }
            }
        }
        if data.isEmpty {
            malData = httpHandler().get(url: url).0
            loadData()
            date = Date()
        }
        self.refreshControl?.endRefreshing()
        if malData.count > 0 {
            refreshButton.isHidden = true
        }
        print("done1")
    }
    
    @objc func doUpdate(_ sender: UIButton) {
        print("click")
        guard let cell = sender.superview as? CustomCell else { return }
        let index = tableView.indexPath(for: cell)?.row as! Int

        print("still clicked")
        
        if httpHandler().update(mal_id: cell.mal_id!, watched_episodes: cell.watched_episodes!, status: 1, tags: cell.tags, csrf_token: csrf!, cookies: cookies) == 200 {
            print("update worked")
            cell.plusButton.isHidden = true
        }
        print("unclick")
    }
    
    @objc func doFullView(_ sender: UIButton) {
        print("clicky")
    }
}
