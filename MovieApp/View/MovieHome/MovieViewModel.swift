//
//  MovieHomeViewModel.swift
//  MovieApp
//
//  Created by Junier Damian on 12/1/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import Foundation
import Moya

class MovieViewModel {
    let movieProvider: MoyaProvider = MoyaProvider<MovieApi>()
    
    var movies: [Movie]?
    
    var whileLoading: (() -> Void) = { }
    var whenLoaded: (() -> Void) = { }
    var onError: ((String) -> Void) = { _ in }
    
    func getMovies(page: Int) {
        self.whileLoading()
        self.movieProvider.request(.nowPlaying(page: page), completion: { result in
            switch result {
            case .success(let result):
                do {
                    let response = try JSONDecoder().decode(Movies.self, from: result.data)
                    self.movies = response.results
                    self.whenLoaded()
                } catch let error {
                    print(error)
                    self.onError("Error") // TODO: Add descripting error
                }
            case .failure(let error):
                print(error)
                self.onError("Error") // TODO: Add descripting error
            }
        })
    }
}
