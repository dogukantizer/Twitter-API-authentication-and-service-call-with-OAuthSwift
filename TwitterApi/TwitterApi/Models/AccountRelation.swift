//
//  FollowerModel.swift
//  TwitterApi
//
//  Created by Dogukan Tizer on 01.10.19.
//  Copyright © 2019 Dogukan Tizer. All rights reserved.
//

import Foundation

typealias AccountRelationResponse = [AccountRelation]

struct AccountRelation: Codable {
    let name: String?
    let screen_name: String?
    let id: Int?
    let id_str: String?
    let connections: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case screen_name
        case id
        case id_str
        case connections
    }
}
