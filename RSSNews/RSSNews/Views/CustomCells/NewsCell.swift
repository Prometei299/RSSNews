//
//  NewsCell.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    
    func configure(model: RSSItem) {
        titleLabel.text = model.title
        dateLabel.text = model.pubDate
    }
}
