//
//  UIViewController+Navigation.swift
//  RSSNews
//
//  Created by Prometei on 11/25/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import RxSwift
import RxCocoa
import Rswift
import SegueManager

extension Reactive where Base: UIViewController & SeguePerformer {
    
    func navigate<Segue, Destination, Value>(with segue: StoryboardSegueIdentifier<Segue, Base, Destination>,
                                             segueHandler: ((TypedStoryboardSegueInfo<Segue, Base, Destination>, Value) -> Void)? = nil) -> Binder<Value> {
        return Binder(base) { viewController, value in
            if let handler = segueHandler {
                viewController.performSegue(withIdentifier: segue) { handler($0, value) }
            } else {
                viewController.performSegue(withIdentifier: segue)
            }
        }
    }
}
