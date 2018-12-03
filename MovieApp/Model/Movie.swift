//
//  Movie.swift
//  MovieApp
//
//  Created by Junier Damian on 12/1/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import Foundation

struct Movies: Codable {
    var results: [Movie]?
}

struct Movie: Codable {
    var id: Int?
    var title: String?
    var overview: String?
    var posterPath: String?
    var posterImage: Data? = nil
    var backgroundPath: String?
    var backgroundImage: Data? = nil
    var voteAverage: Double?
    var releaseDate: String?
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backgroundPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}
