//
//  RealmServiceType.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmServiceType {
    func save(rssItems: [RSSItem], id: String)
    func getPaginationItems(by key: String, paginationIndex: Int) -> [RSSItem]
    func getAllItems(by key: String) -> [RSSItem]
}
