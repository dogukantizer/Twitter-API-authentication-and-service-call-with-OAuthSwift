//
//  FollowerModel.swift
//  TwitterApi
//
//  Created by Dogukan Tizer on 01.10.19.
//  Copyright © 2019 Dogukan Tizer. All rights reserved.
//

import Foundation

typealias FollowerResponse = FollowerArray

struct FollowerArray: Codable {
    let users: [Follower]?
    let next_cursor: Int?
    let next_cursor_str: String?
    let previous_cursor: Int?
    let previous_cursor_str: String?
    let profile_image_url_https: String?
    
    private enum CodingKeys: String, CodingKey {
        case users = "users"
        case next_cursor = "next_cursor"
        case next_cursor_str = "next_cursor_str"
        case previous_cursor = "previous_cursor"
        case previous_cursor_str = "previous_cursor_str"
        case profile_image_url_https = "profile_image_url_https"
       
    }
}


struct Follower: Codable {
    let id: Int?
    let id_str: String?
    let name: String?
    let screen_name: String?
    let followers_count: Int?
    let profile_image_url_https: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case id_str
        case name
        case screen_name
        case followers_count
        case profile_image_url_https
    }
}
