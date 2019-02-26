//
//  ForecastCollectionViewCell.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import UIKit
import Kingfisher

class ForecastCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tempLabelOutlet: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var timeLabelOutlet: UILabel!
    
    static var identifier = "ForecastCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.iconImageView.kf.cancelDownloadTask()
        self.iconImageView.image = nil
        self.tempLabelOutlet.text = ""
        self.timeLabelOutlet.text = ""
    }

}
