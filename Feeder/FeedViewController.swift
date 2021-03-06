//
//  FeedViewController.swift
//  Feeder
//
//  Created by Aritro Paul on 6/20/21.
//

import UIKit
import Nuke
import SafariServices
import SPIndicator

class FeedViewController: UITableViewController {

    var user: User!
    var events: [Event] = []
    
    //releaseView
    var selectedRepoName = ""
    var releaseBody = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "@\(user.login)'s feed"
        
        API.shared.eventsDelegate = self
        API.shared.getEvents(user: user)
    
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl

        self.tableView.setEmptyMessage("Loading Feed. Please Wait.")
        self.tableView.contentInset = UIEdgeInsets(top: -32, left: 0, bottom: -30, right: 0)
         
        let profileView = UIAction(title: "View Profile", image: UIImage(systemName: "person.fill")) { action in
            let url = self.user.html_url
            let safariVC = SFSafariViewController(url: URL(string: url)!)
            self.present(safariVC, animated: true, completion: nil)
        }
        
        let logout = UIAction(title: "Logout", image: UIImage(systemName: "arrow.up.forward.square.fill"), attributes: .destructive) { action in
            API.token = ""
            UserDefaults.standard.set(nil, forKey: "token")
            self.dismiss(animated: true, completion: nil)
        }
        
        let menu = UIMenu(title: user.login, children: [profileView, logout])
        
        let profileBarButtonView = ImageBarButton(withUrl: URL(string: user.avatar_url), menu: menu)
        
        self.navigationItem.leftBarButtonItem = profileBarButtonView.load()
    }
    
    @objc func refresh() {
        API.shared.getEvents(user: user)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if events.count == 0 {
            return 0
        }
        else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if events.count == 0 {
            self.tableView.setEmptyMessage("Loading Feed. Please Wait.")
        }
        else {
            self.tableView.restore()
        }

        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        let event = events[indexPath.row]
        let imageRequest = ImageRequest(url: URL(string: event.actor.avatar_url)!)
        Nuke.loadImage(with: imageRequest, into: cell.avatarImage)
        var action: NSAttributedString!
        switch event.type {
        case "WatchEvent":
            action = NSMutableAttributedString()
                    .bold("\(event.actor.login)")
                    .normal(" starred ")
                    .bold("\(event.repo.name)")
        case "ForkEvent":
            action = NSMutableAttributedString()
                .bold("\(event.actor.login)")
                .normal(" forked ")
                .bold("\(event.payload?.forkee?.full_name ?? "")")
                .normal(" from ")
                .bold("\(event.repo.name)")
        case "CreateEvent":
            action = NSMutableAttributedString()
                .bold("\(event.actor.login)")
                .normal(" created a repository ")
                .bold("\(event.repo.name)")
        case "ReleaseEvent":
            action = NSMutableAttributedString()
                .bold("\(event.actor.login)")
                .normal(" released ")
                .bold("\(event.payload?.release?.tag_name ?? "")")
                .normal(" of ")
                .bold("\(event.repo.name)")
        case "PublicEvent":
            action = NSMutableAttributedString()
                .bold("\(event.actor.login)")
                .normal(" made ")
                .bold("\(event.repo.name)")
                .normal(" public. ")
        default:
            break
        }
        cell.actionLabel.attributedText = action
        cell.avatarImage.layer.cornerRadius = 16
        cell.repoLabel.text = event.repository?.full_name
        cell.repoDescLabel.text = event.repository?.description
        cell.timeLabel.text = getDate(date: event.created_at)
        cell.repoLang.text = event.repository?.language
        if event.repository?.language == nil {
            cell.langColorView.backgroundColor = .clear

        }
        else {
            cell.langColorView.backgroundColor = UIColor(hex: (colors?[event.repository?.language ?? "Markdown"]?.color) ?? "#cccccc")

        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        var event = events[indexPath.row]
        let identifier = NSString(string: "\(indexPath.row)")
        let config =  UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { suggestedActions in
    
            let user = UIAction(title: "View Github", image: UIImage(systemName: "person.crop.circle.fill"), discoverabilityTitle: event.actor.login) { action in
                let url = event.actor.url.replacingOccurrences(of: "api.", with: "").replacingOccurrences(of: "/users", with: "")
                let safariVC = SFSafariViewController(url: URL(string: url)!)
                self.present(safariVC, animated: true, completion: nil)
            }

            let repo = UIAction(title: "View Repository", image: UIImage(systemName: "book.closed.fill"), discoverabilityTitle: event.repo.name) { action in
                let url = event.repo.url.replacingOccurrences(of: "api.", with: "").replacingOccurrences(of: "/repos", with: "")
                print(url)
                let safariVC = SFSafariViewController(url: URL(string: url)!)
                self.present(safariVC, animated: true, completion: nil)
            }

            var starred: UIAction?
            if event.repo.isStarred ?? false {
                starred = UIAction(title: "Unstar", image: UIImage(systemName: "star.fill"), discoverabilityTitle: "\(event.repository?.stargazers_count ?? 0) Stars", handler: { ACTION in
                    API.shared.star(type: .delete, repo: event.repo) { status in
                        DispatchQueue.main.async {
                            SPIndicator.present(title: "Unstarred", message: "\(event.repo.name)", preset: .custom(UIImage(systemName: "star")!))
                            event.repo.isStarred = false
                            self.events[indexPath.row] = event
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
            }
            else {
                starred = UIAction(title: "Star", image: UIImage(systemName: "star"), discoverabilityTitle: "\(event.repository?.stargazers_count ?? 0) Stars", handler: { ACTION in
                    API.shared.star(type: .put, repo: event.repo) { status in
                        DispatchQueue.main.async {
                            SPIndicator.present(title: "Starred", message: "\(event.repo.name)", preset: .custom(UIImage(systemName: "star.fill")!))
                            event.repo.isStarred = true
                            self.events[indexPath.row] = event
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
            }
            
            let share = UIAction(title: "Share", image: UIImage(systemName: "photo.fill")) { action in
                let view = tableView.cellForRow(at: indexPath)
                let renderer = UIGraphicsImageRenderer(size: (view?.bounds.size)!)
                let image = renderer.image { ctx in
                    view!.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
                }
                
                let items = [image]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                DispatchQueue.main.async {
                    self.present(ac, animated: true)
                }
            }
            
            let viewRelease = UIAction(title: "View Release Notes", image: UIImage(systemName: "doc.richtext.fill"), discoverabilityTitle: "Everything about release \(event.payload?.release?.tag_name ?? "")") { action in
                guard let release = event.payload?.release else { return }
                self.selectedRepoName = event.repo.name
                self.releaseBody = "# \(release.tag_name) \n ###### \(event.repo.name) \n\n" + release.body
                self.performSegue(withIdentifier: "viewRelease", sender: Any?.self)
                
            }
            
            if event.type == "ReleaseEvent" {
                return UIMenu(title: "", children: [user, repo, starred!, viewRelease, share])
            }
            else {
                return UIMenu(title: "", children: [user, repo, starred!, share])
            }
        }
        
        return config
    }
    
    override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let index = Int(configuration.identifier as! String) ?? -1
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
        let params = UIPreviewParameters()
        params.visiblePath = UIBezierPath(roundedRect: cell?.bounds ?? CGRect(), cornerRadius: 12)
        params.backgroundColor = .clear
        return UITargetedPreview(view: cell ?? EventTableViewCell(), parameters: params)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let releaseVC = segue.destination as? ReleaseViewController {
            releaseVC.repoName = selectedRepoName
            releaseVC.body = releaseBody
        }
    }
    
}

extension FeedViewController: EventsDelegate {
    func didGetEvents(events: [Event]) {
        self.events = events.filter({ event in
            if event.type == "CreateEvent" || event.type == "WatchEvent" || event.type == "ForkEvent" || event.type == "ReleaseEvent" || event.type == "PublicEvent" {
                return true
            }
            return false
        })
        
        var repos = 0
        for index in self.events.indices {
            var event = self.events[index]
            API.shared.getRepository(name: event.repo.name) { result in
                switch result {
                case .success(let repo):
                    event.repository = repo
                    API.shared.star(type: .get, repo: event.repo) { status in
                        event.repo.isStarred = status
                        self.events[index] = event
                        repos += 1
                        DispatchQueue.main.async {
                            if repos == self.events.count {
                                self.events = self.events.filter({ event in
                                    return event.repository != nil
                                })
                                
                                SPIndicator.present(title: "Long press", message: "to interact with your feed", preset: .custom(UIImage(systemName: "sparkles")!), from: .top, completion: nil)
                                self.tableView.reloadData()
                                self.refreshControl?.endRefreshing()
                            }
                        }
                    }
                case .failure(let error):
                    event.repository = nil
                    repos += 1
                    print("???? This Repo has disappeared.")
                    print(error)
                }
            }
        }
        
        if self.events.count == 0 {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.setEmptyMessage("Could not load feed.")
            }
        }
    }
    
    func didFailWith(error: Error) {
        print(error)
    }
        
}

