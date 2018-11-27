//
//  AlbumTableViewCell.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var assetsCountLabel: UILabel!
    
    var representedAssetIdentifier: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
