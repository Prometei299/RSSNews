//
//  RxTableView + RxSwift.swift
//  RSSNews
//
//  Created by Prometei on 11/25/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import RxCocoa
import RxSwift
import Rswift

extension Reactive where Base: UITableView {
    
    public func items<Identifier: ReuseIdentifierType, S: Sequence, O : ObservableType>
        (cellIdentifier: Identifier)
        -> (_ source: O)
        -> (_ configureCell: @escaping (Int, S.Iterator.Element, Identifier.ReusableType) -> Void)
        -> Disposable where O.Element == S, Identifier.ReusableType: UITableViewCell {
            return items(cellIdentifier: cellIdentifier.identifier, cellType: Identifier.ReusableType.self)
    }
}
