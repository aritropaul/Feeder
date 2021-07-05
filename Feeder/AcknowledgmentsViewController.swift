//
//  AcknowledgmentsViewController.swift
//  Feeder
//
//  Created by Aritro Paul on 7/5/21.
//

import UIKit
import SafariServices

class AcknowledgmentsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func loadBrowser(url: String) {
        let vc = SFSafariViewController(url: URL(string: url)!)
        self.present(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: loadBrowser(url: "https://github.com/keitaoouchi/MarkdownView")
        case 1: loadBrowser(url: "https://github.com/kean/Nuke")
        case 2: loadBrowser(url: "https://github.com/ivanvorobei/SPIndicator")
        default:
            break
        }
    }

}
