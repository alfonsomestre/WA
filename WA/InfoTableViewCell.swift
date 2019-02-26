//
//  InfoTableViewCell.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var fieldValueNameLabelOutlet: UILabel!
    @IBOutlet weak var fieldNameLabelOutlet: UILabel!
    
    static let identifier = "InfoTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.fieldNameLabelOutlet.text = ""
        self.fieldValueNameLabelOutlet.text = ""
    }
    
}
