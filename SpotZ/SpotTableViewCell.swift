//
//  SpotTableViewCell.swift
//  SpotZ
//
//  Created by Ziyang Tan on 3/7/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class SpotTableViewCell: UITableViewCell {

    @IBOutlet var placeNameLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
