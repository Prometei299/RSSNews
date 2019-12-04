//
//  RealmService.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

struct RealmService: RealmServiceType {
    
    func save(rssItems: [RSSItem], id: String) {
        let realm = try! Realm()
        let rssItemRealm = RSSItemRealm()
        
        rssItemRealm.id = id
        rssItems.forEach { item in
            let itemReal = ItemRealm()
            itemReal.title = item.title
            itemReal.itemDescription = item.description
            itemReal.pubDate = item.pubDate
            rssItemRealm.items.append(itemReal)
        }
        try! realm.write {
            realm.add(rssItemRealm, update: .modified)
        }
    }
    
    func getPaginationItems(by key: String, paginationIndex: Int) -> [RSSItem] {
        let realm = try! Realm()
        guard !realm.isEmpty,
              let object = realm.object(ofType: RSSItemRealm.self, forPrimaryKey: key) else { return [RSSItem]() }
        var count = 0
        
        if paginationIndex > object.items.count {
            count = object.items.count
        } else {
            count = paginationIndex
        }
        
        let rssItems = (0..<count).map { index -> RSSItem in
            return RSSItem(title: object.items[index].title,
                           description: object.items[index].itemDescription,
                           pubDate: object.items[index].pubDate)
        }
    
        return rssItems
    }
    
    func getAllItems(by key: String) -> [RSSItem] {
        let realm = try! Realm()
        guard !realm.isEmpty,
              let object = realm.object(ofType: RSSItemRealm.self,
                                        forPrimaryKey: key) else { return [RSSItem]() }
        
        let rssItems = (0..<object.items.count).map { index -> RSSItem in
            return RSSItem(title: object.items[index].title,
                           description: object.items[index].itemDescription,
                           pubDate: object.items[index].pubDate)
        }

        return rssItems
    }
}
