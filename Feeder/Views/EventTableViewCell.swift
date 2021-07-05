//
//  EventTableViewCell.swift
//  Feeder
//
//  Created by Aritro Paul on 6/20/21.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    var repository: Repository!
    @IBOutlet weak var repoLabel: UILabel!
    @IBOutlet weak var repoDescLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var langColorView: UIView!
    @IBOutlet weak var repoLang: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
