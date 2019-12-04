//
//  LiveNewsViewController.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD
import SegueManager

enum TypePagination {
    case liveNews
    case analystics
}

class LiveNewsAndAnalysticsViewController: SegueManagerViewController {

    @IBOutlet private var liveNewsTableView: UITableView!
    @IBOutlet private var analysticsTableView: UITableView!
    
    private var newsArray = [RSSItem]()
    private var analistycsArray = [RSSItem]()
    private var viewModel = LiveNewsAndAnalysticsViewModel()
    private var currentLiveNewsPaginationIndex = 0
    private var currentAnalisticsPaginationIndex = 0
    private var isEndLiveNews = false
    private var isEndAnalystics = false
    
    private let paginationLiveNewsIndex = PublishRelay<Int>()
    private let paginationAnalisticsIndex = PublishRelay<Int>()
    private let realmLimitedRecordsConstant = Constants.RealmConstants().limitedGettingRecords
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
}

// MARK: - Setup
private extension LiveNewsAndAnalysticsViewController {
    
    func setup() {
        navigationItem.title = "News"
        HUD.show(.progress, onView: self.view)
        currentAnalisticsPaginationIndex = realmLimitedRecordsConstant
        currentLiveNewsPaginationIndex = realmLimitedRecordsConstant
        setupTableViews()
        bind()
    }
    
    func setupTableViews() {
        liveNewsTableView.dataSource = nil
        analysticsTableView.dataSource = nil
        liveNewsTableView.register(R.nib.newsCell)
        analysticsTableView.register(R.nib.newsCell)
    }
    
    func hideHUD() {
        guard newsArray.isEmpty else {
            guard !analistycsArray.isEmpty else { return }
            HUD.hide()
            return
        }
        return
    }
    
    func getDeltaOffset(in tableView: UITableView) -> CGFloat {
        let currentOffset = tableView.contentOffset.y
        let maximumOffset = tableView.contentSize.height - tableView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        return deltaOffset
    }
}

// MARK: - Bind
private extension LiveNewsAndAnalysticsViewController {
    
    func bind() {
        let output = viewModel.transform(input: .init(paginationLiveNewsIndex: paginationLiveNewsIndex.asDriver(onErrorJustReturn: 0),
                                                      paginationAnalisticsIndex: paginationAnalisticsIndex.asDriver(onErrorJustReturn: 0)))
        
        output.news
            .drive(liveNewsTableView.rx.items(cellIdentifier: R.reuseIdentifier.newsCell)) { [unowned self] _, model, cell in
                cell.configure(model: model)
                self.hideHUD()
                guard !self.newsArray.contains(model) else { return }
                self.newsArray.append(model)
        }.disposed(by: bag)
        
        output.analistics
            .drive(analysticsTableView.rx.items(cellIdentifier: R.reuseIdentifier.newsCell)) { [unowned self] _, model, cell in
                cell.configure(model: model)
                self.hideHUD()
                guard !self.analistycsArray.contains(model) else { return }
                self.analistycsArray.append(model)
        }.disposed(by: bag)
        
        output.isEndLiveNews
            .drive(onNext: { [unowned self] value in
                self.isEndLiveNews = value
        }).disposed(by: bag)
        
        output.isEndAnalystics
            .drive(onNext: { [unowned self] value in
                self.isEndAnalystics = value
        }).disposed(by: bag)
        
        paginationLiveNewsIndex.accept(currentLiveNewsPaginationIndex)
        paginationAnalisticsIndex.accept(currentAnalisticsPaginationIndex)
        
        liveNewsTableView.rx.willEndDragging
            .subscribe(onNext: { [unowned self] _ in
                guard !self.isEndLiveNews, self.getDeltaOffset(in: self.liveNewsTableView) <= 0 else { return }
                self.currentLiveNewsPaginationIndex += self.realmLimitedRecordsConstant
                self.paginationLiveNewsIndex.accept(self.currentLiveNewsPaginationIndex)
        }).disposed(by: bag)
        
        analysticsTableView.rx.willEndDragging
            .subscribe(onNext: { [unowned self] _ in
                guard !self.isEndAnalystics, self.getDeltaOffset(in: self.analysticsTableView) <= 0 else { return }
                self.currentAnalisticsPaginationIndex += self.realmLimitedRecordsConstant
                self.paginationAnalisticsIndex.accept(self.currentAnalisticsPaginationIndex)
        }).disposed(by: bag)
        
        internalBinding()
    }
    
    func internalBinding() {
        liveNewsTableView.rx.itemSelected
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: rx.navigate(with: R.segue.liveNewsAndAnalysticsViewController.showOneNews) { [unowned self] segue, indexPath in
                self.liveNewsTableView.deselectRow(at: indexPath, animated: true)
                segue.destination.configure(rssItem: self.newsArray[indexPath.row])
        }).disposed(by: bag)
        
        analysticsTableView.rx.itemSelected
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: rx.navigate(with: R.segue.liveNewsAndAnalysticsViewController.showOneNews) { [unowned self] segue, indexPath in
                self.analysticsTableView.deselectRow(at: indexPath, animated: true)
                segue.destination.configure(rssItem: self.analistycsArray[indexPath.row])
        }).disposed(by: bag)
    }
}
