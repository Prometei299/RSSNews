//
//  RSSItemService.swift
//  RSSNews
//
//  Created by Prometei on 12/4/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import Foundation

struct RSSItemService {
    
    let realmService: RealmService?
    
    func getUpdatedAndSortedItemsArray(by key: String, with items: [RSSItem]) -> [RSSItem] {
        guard let realm = realmService else { return [RSSItem]() }
        var itemsRealm = realm.getAllItems(by: key)
        var counter = 0
        
        for index in 0..<items.count {
            guard !itemsRealm.contains(items[index]) else { continue }
            guard itemsRealm.count == Constants.RealmConstants().recordsCount else {
                itemsRealm.append(items[index])
                continue
            }
            counter += 1
            itemsRealm.remove(at: itemsRealm.count - counter)
            itemsRealm.append(items[index])
        }
        
        return self.getSortedItems(items: itemsRealm)
    }
    
    func getSortedItems(items: [RSSItem]) -> [RSSItem] {
        var sortedItems = items
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        sortedItems.sort { (firstItem, secondItem) -> Bool in
            guard let firstDate = dateFormatter.date(from: firstItem.pubDate),
                  let secondDate = dateFormatter.date(from: secondItem.pubDate) else { return false }
            return firstDate > secondDate
        }
        
        return sortedItems
    }
}
