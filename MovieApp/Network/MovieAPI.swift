//
//  MovieAPI.swift
//  MovieApp
//
//  Created by Junier Damian on 12/1/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import Foundation
import Moya

public enum MovieApi {
    case nowPlaying(page: Int)
}

extension MovieApi: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    public var path: String {
        switch self {
        case .nowPlaying: return "/movie/now_playing"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .nowPlaying: return .get
        }
    }
    
    public var sampleData: Data {
        return Data() // TODO: return example data for unit test
    }
    
    public var task: Task {
        var parameters: [String: Any] = ["api_key": "858bc833199ca918eff478a89b8f64d9"]
        switch self {
        case .nowPlaying(let page):
            parameters["page"] = page
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
}
