//
//  MovieHomeViewModel.swift
//  MovieApp
//
//  Created by Junier Damian on 12/1/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import AlamofireImage

class MovieViewModel {
    enum MovieFilter {
        case rating
        case name
        case year
    }
    
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
    
    func getMovieName(index: Int) -> String {
        return self.movies![index].title ?? ""
    }
    
    func getRatingImage(index: Int) -> UIImage {
        let rating = self.movies![index].voteAverage!
        switch rating {
        case 0..<2.5:
            return #imageLiteral(resourceName: "no_star")
        case 2.5..<4.5:
            return #imageLiteral(resourceName: "one_star")
        case 4.5..<6.5:
            return #imageLiteral(resourceName: "two_star")
        case 6.5..<8.5:
            return #imageLiteral(resourceName: "three_star")
        case let rating where rating >= 8.5:
            return #imageLiteral(resourceName: "five_star")
        default:
            return #imageLiteral(resourceName: "no_star")
        }
    }
    
    func downloadImage(index: Int, whenLoaded: @escaping (UIImage) -> Void) {
        let url: String = "https://image.tmdb.org/t/p/original\(self.movies![index].backgroundPath ?? "")"
        Alamofire.request(url).responseImage(completionHandler: { response in
            if let image = response.result.value {
                whenLoaded(image)
            } else {
//                onError()
            }
        })
    }
}
