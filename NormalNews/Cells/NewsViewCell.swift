//
//  NewsViewCell.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/3/22.
//

import UIKit

class NewsViewCell: UITableViewCell {

    @IBOutlet var lbltitle: UILabel!
    
    @IBOutlet var lblautortimer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
