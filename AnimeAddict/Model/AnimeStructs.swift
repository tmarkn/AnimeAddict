//
//  AnimeStruct.swift
//  AnimeAddict
//
//  Created by Tony Mark on 4/11/19.
//  Copyright © 2019 Tony Mark. All rights reserved.
//

import Foundation

struct Anime: Decodable {
    let mal_id: Int
    let title: String?
    let video_url: String?
    let url: String?
    let image_url: String?
    let type: String?
    var watching_status: Int
    var score: Int
    var watched_episodes: Int
    let total_episodes: Int?
    let airing_status: Int
    let season_name: String?
    let season_year: String?
    let has_episode_video: Bool
    let has_promo_video: Bool
    let has_video: Bool
    let is_rewatching: Bool
    var tags: String?
    let rating: String?
    let start_date: String?
    let end_date: String?
    let watch_start_date: String?
    let watch_end_date: String?
    let days: Int?
    let storage: String?
    let priority: String?
    let added_to_list: Bool
    let studios: [String]
    let licensors: [String]
}

struct AiringAnime: Decodable {
    let mal_id: Int
    let rank: Int
    let title: String?
    let url: String?
    let image_url: String?
    let type: String?
    let episodes: Int?
    let start_date: String?
    let end_date: String?
    let members: Int
    let score: Float
}

struct Jikan: Decodable {
    let request_hash: String?
    let request_cached: Bool
    let request_cache_expiry: Int
    let anime: [Anime]
}

struct AiringJikan: Decodable {
    let request_hash: String?
    let request_cached: Bool
    let request_cache_expiry: Int
    let top: [AiringAnime]
}
