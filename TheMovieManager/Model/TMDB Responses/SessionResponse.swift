//
//  SessionResponse.swift
//  TheMovieManager
//
//  Created by Abdelrahman on 13/01/2022.
//  Copyright © 2022 Udacity. All rights reserved.
//

import Foundation
struct SessionResponse: Codable {
    
    let success: Bool
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
    
}
