//
//  RSSChannelRealm.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import Foundation
import RealmSwift

class RSSItemRealm: Object {
    @objc dynamic var id = ""
    var items = List<ItemRealm>()
    
    override static func primaryKey() -> String? {
        return #keyPath(id)
    }
}

class ItemRealm: Object {
    @objc dynamic var title = ""
    @objc dynamic var itemDescription = ""
    @objc dynamic var pubDate = ""
}
