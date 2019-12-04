//
//  Connectivity.swift
//  RSSNews
//
//  Created by Prometei on 12/3/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    
    var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
