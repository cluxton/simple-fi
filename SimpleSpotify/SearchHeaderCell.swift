//
//  SearchHeaderCell.swift
//  SimpleSpotify
//
//  Created by Charles Luxton on 27/02/2016.
//  Copyright © 2016 Charles Luxton. All rights reserved.
//

import UIKit

class SearchHeaderCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(red: 0.016, green: 0.055, blue: 0.11, alpha: 1)
        self.clipsToBounds = true
        
        let size = self.contentView.frame.size
        let border = UIView(frame: CGRect(x: 10, y: size.height - 1, width: size.width - 10, height: 1))
        border.backgroundColor = UIColor.whiteColor()
        border.alpha = 0.1
        border.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin];
        
        self.contentView.addSubview(border)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
