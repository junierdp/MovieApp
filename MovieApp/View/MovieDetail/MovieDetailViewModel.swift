//
//  MovieDetailViewModel.swift
//  MovieApp
//
//  Created by Junier Damian on 12/2/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire

class MovieDetailViewModel {
    
    let title: String
    let date: String
    let ratingImage: UIImage
    let overview: String
    let posterPath: String
    
    init(movie: Movie) {
        self.title = movie.title ?? ""
        self.date = movie.releaseDate ?? ""
        self.ratingImage = UIImage()
        self.overview = movie.overview ?? ""
        self.posterPath = movie.posterPath ?? ""
    }
    
    func downloadImage(whenLoaded: @escaping (UIImage) -> Void) {
        let url: String = "https://image.tmdb.org/t/p/original" + self.posterPath
        Alamofire.request(url).responseImage(completionHandler: { response in
            if let image = response.result.value {
                whenLoaded(image)
            } else {
                //                onError()
            }
        })
    }
}
