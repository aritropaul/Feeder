//
//  ReleaseViewController.swift
//  Feeder
//
//  Created by Aritro Paul on 7/5/21.
//

import UIKit
import MarkdownView

class ReleaseViewController: UIViewController {

    var repoName: String!
    var body: String!
    @IBOutlet weak var markdownView: MarkdownView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.topItem?.title = repoName
        markdownView.load(markdown: body)
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
