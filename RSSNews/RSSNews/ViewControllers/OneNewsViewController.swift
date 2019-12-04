//
//  OneNewsViewController.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import UIKit

class OneNewsViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    private var rssItem = RSSItem(title: "", description: "", pubDate: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func configure(rssItem: RSSItem) {
        self.rssItem = rssItem
    }
}

// MARK: - Setup
private extension OneNewsViewController {
    
    func setup() {
        setupLabels()
    }
    
    func setupLabels() {
        titleLabel.text = rssItem.title
        dateLabel.text = rssItem.pubDate
        descriptionLabel.text = rssItem.description
    }
}

