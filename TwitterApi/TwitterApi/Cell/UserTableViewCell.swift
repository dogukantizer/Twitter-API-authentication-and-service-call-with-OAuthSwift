//
//  UserTableViewCell.swift
//  TwitterApi
//
//  Created by Doğukan Tizer on 1.10.2019.
//

import UIKit

protocol customCellProtocol{
    func follow(screen_name: String)
}

class UserTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var button: UIButton!
    
    var cellDelegate: customCellProtocol?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func buttonClick(_ sender: Any) {
        cellDelegate?.follow(screen_name: self.name.text!)
    }
    
    
}
