//
//  LiveNewsUseCase.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import RxSwift
import RxCocoa

struct LiveNewsAndAnalysticsUseCase {
    
    private let liveNews = PublishRelay<[RSSItem]>()
    private let analystics = PublishRelay<[RSSItem]>()
    private let isEndLiveNews = PublishRelay<Bool>()
    private let isEndAnalystics = PublishRelay<Bool>()
    private let bag = DisposeBag()
    
    let parser: XMLParserManager?
    let realmService: RealmService?
    let rssItemService: RSSItemService?
    
    init(parser: XMLParserManager, realmService: RealmService) {
        self.parser = parser
        self.realmService = realmService
        self.rssItemService = RSSItemService(realmService: realmService)
    }
    
    struct Input {
        let paginationLiveNewsIndex: Driver<Int>
        let paginationAnalisticsIndex: Driver<Int>
    }
    
    struct Output {
        var liveNews: Driver<[RSSItem]>
        var analistics: Driver<[RSSItem]>
        var isEndLiveNews: Driver<Bool>
        var isEndAnalystics: Driver<Bool>
    }
    
    func produce(input: Input) -> Output {
        checkInternetConnection(input: input)
        return Output(liveNews: liveNews.asDriver(onErrorJustReturn: [RSSItem]()),
                      analistics: analystics.asDriver(onErrorJustReturn: [RSSItem]()),
                      isEndLiveNews: isEndLiveNews.asDriver(onErrorJustReturn: false),
                      isEndAnalystics: isEndAnalystics.asDriver(onErrorJustReturn: false))
    }
}

private extension LiveNewsAndAnalysticsUseCase {
    
    func checkInternetConnection(input: Input) {
        guard Connectivity().isConnectedToInternet else {
            drivePaginationIndex(input: input)
            return
        }
        self.downloadData(input: input)
    }
    
    func downloadData(input: Input) {
        guard let rssItemService = self.rssItemService,
              let parser = self.parser else { return }
        let channel = RSSChannel()
        
        parser.parseData(by: channel.liveNews) { items in
            let sortedItems = rssItemService.getUpdatedAndSortedItemsArray(by: "liveNews",
                                                                           with: items)
            self.saveDataInRealm(rssItems: sortedItems, by: "liveNews")
            let paginationItems = self.getPaginationDataFromRealm(by: "liveNews",
                                                                  paginationIndex: Constants.RealmConstants().limitedGettingRecords - 1)
            self.liveNews.accept(paginationItems)
            DispatchQueue.main.async {
                self.drivePaginationIndex(input: input)
            }
        }
        
        parser.parseData(by: channel.analistycs) { items in
            let sortedItems = rssItemService.getUpdatedAndSortedItemsArray(by: "analystics",
                                                                           with: items)
            self.saveDataInRealm(rssItems: sortedItems, by: "analystics")
            let paginationItems = self.getPaginationDataFromRealm(by: "analystics",
                                                                  paginationIndex: Constants.RealmConstants().limitedGettingRecords - 1)
            self.analystics.accept(paginationItems)
        }
    }
    
    func drivePaginationIndex(input: Input) {
        input.paginationLiveNewsIndex.drive(onNext: { index in
            guard index != 0 else { return }
            let paginationItems = self.getPaginationDataFromRealm(by: "liveNews",
                                                                  paginationIndex: index)
            self.liveNews.accept(paginationItems)
        }).disposed(by: bag)
        
        input.paginationAnalisticsIndex.drive(onNext: { index in
            guard index != 0 else { return }
            let paginationItems = self.getPaginationDataFromRealm(by: "analystics",
                                                                  paginationIndex: index)
            self.analystics.accept(paginationItems)
        }).disposed(by: bag)
    }
}

// MARK: - Realm
private extension LiveNewsAndAnalysticsUseCase {
    
    func getPaginationDataFromRealm(by key: String, paginationIndex: Int) -> [RSSItem] {
        guard let realm = realmService else { return [RSSItem]() }
        let paginationItems = realm.getPaginationItems(by: key, paginationIndex: paginationIndex)
        let allItems = realm.getAllItems(by: key)
        
        guard allItems.count < paginationIndex else { return paginationItems }
        switch key {
        case "liveNews":
            isEndLiveNews.accept(true)
        case "analystics":
            isEndAnalystics.accept(true)
        default:
            break
        }
        
        return paginationItems
    }
    
    func saveDataInRealm(rssItems: [RSSItem], by key: String) {
        guard let realm = realmService else { return }
        realm.save(rssItems: rssItems, id: key)
    }
}
