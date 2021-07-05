//
//  SettingsViewController.swift
//  Feeder
//
//  Created by Aritro Paul on 7/5/21.
//

import UIKit
import MessageUI
import SPIndicator
import SafariServices

enum MailRequest {
    case bug
    case feature
}

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func loadBrowser(url: String) {
        let vc = SFSafariViewController(url: URL(string: url)!)
        self.present(vc, animated: true)
    }

    func openMail(request: MailRequest) {
        let emailTitle = "Feedback"
        var messageBody = ""
        switch request {
        case .bug:
            messageBody = "Bug report"
        case .feature:
            messageBody = "Feature request"
        }
        let toRecipents = ["hello@aritro.xyz"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        self.present(mc, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: section0Handler(indexPath: indexPath)
        case 1: section1Handler(indexPath: indexPath)
        case 2: section2Handler(indexPath: indexPath)
        default: break
        }
    }
    
    func section0Handler(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: openMail(request: .bug)
        case 1: openMail(request: .feature)
        default: break
        }
    }
    
    func section1Handler(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: break
        case 1: break
        case 2: break
        default:
            break
        }
    }
    
    func section2Handler(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: loadBrowser(url: "https://aritro.xyz")
        case 1: loadBrowser(url: "https://twitter.com/aritrotwt")
        case 2: loadBrowser(url: "https://buymeacoffee.com/aritropaul")
        default: break
        }
    }
}


extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            SPIndicator.present(title: "Mail Cancelled", preset: .custom(UIImage(systemName: "xmark.circle")!))
        case .saved:
            SPIndicator.present(title: "Mail Saved", preset: .custom(UIImage(systemName: "xmark.circle")!))
        case .sent:
            SPIndicator.present(title: "Mail Saved", preset: .done)
        case .failed:
            SPIndicator.present(title: "Mail Saved", preset: .error)
        @unknown default: break
        }
        self.dismiss(animated: true, completion: nil)
    }
}
