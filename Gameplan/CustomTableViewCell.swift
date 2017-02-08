//
//  CustomTableViewCell.swift
//  Gameplan
//
//  Created by Jason Jin on 1/19/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    var event:Event? {
        didSet{
            self.textLabel?.text = event?.title
            self.detailTextLabel?.text = event?.eventDescription
            self.detailTextLabel?.textColor = .lightGray
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
