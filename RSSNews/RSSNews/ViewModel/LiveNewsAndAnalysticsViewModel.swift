//
//  LiveNewsAndAnalysticsViewModel.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import RxSwift
import RxCocoa

class LiveNewsAndAnalysticsViewModel {
    
    private var liveNewsAndAnalysticsUseCase = LiveNewsAndAnalysticsUseCase(parser: XMLParserManager(),
                                                                            realmService: RealmService())
}

// MARK: - ViewModelType
extension LiveNewsAndAnalysticsViewModel: ViewModelType {
    
    struct Input {
        let paginationLiveNewsIndex: Driver<Int>
        let paginationAnalisticsIndex: Driver<Int>
    }
    
    struct Output {
        let news: Driver<[RSSItem]>
        let analistics: Driver<[RSSItem]>
        let isEndLiveNews: Driver<Bool>
        let isEndAnalystics: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let liveNewsAndAnalysticsOutput =
            liveNewsAndAnalysticsUseCase.produce(input: .init(paginationLiveNewsIndex: input.paginationLiveNewsIndex,
                                                              paginationAnalisticsIndex: input.paginationAnalisticsIndex))
        return Output(news: liveNewsAndAnalysticsOutput.liveNews,
                      analistics: liveNewsAndAnalysticsOutput.analistics,
                      isEndLiveNews: liveNewsAndAnalysticsOutput.isEndLiveNews,
                      isEndAnalystics: liveNewsAndAnalysticsOutput.isEndAnalystics)
    }
}
