//
//  Logout.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct Logout: Codable {
    let session : String
    
    
    enum CodingKeys: String , CodingKey {
        case session = "session_id"
    }
}

