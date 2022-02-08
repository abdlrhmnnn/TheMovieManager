//
//  PostSession.swift
//  TheMovieManager
//
//  Created by Abdelrahman on 13/01/2022.
//  Copyright © 2022 Udacity. All rights reserved.
//

import Foundation

struct PostSession: Codable {
    
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
    
}
