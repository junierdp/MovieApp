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
import CoreData

class MovieDetailViewModel {
    
    let id: Int
    let title: String
    let date: String
    let ratingImage: UIImage
    let overview: String
    let posterPath: String
    var isFavorite: Bool
    var posterImage: Data?
    
    init(movie: Movie) {
        self.title = movie.title ?? ""
        self.date = movie.releaseDate ?? ""
        self.ratingImage = UIImage()
        self.overview = movie.overview ?? ""
        self.posterPath = movie.posterPath ?? ""
        self.isFavorite = movie.isFavorite
        self.id = movie.id ?? 0
        self.posterImage = movie.posterImage ?? nil
    }
    
    func downloadImage(whenLoaded: @escaping (UIImage) -> Void) {
        if self.posterImage != nil {
            whenLoaded(UIImage(data: self.posterImage!)!)
        } else {
            let url: String = "https://image.tmdb.org/t/p/original" + self.posterPath
            Alamofire.request(url).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    whenLoaded(image)
                    self.saveMoviePosterImage(image: response.data!)
                } else {
                    //                onError()
                }
            })
        }
    }
    
    private func saveMoviePosterImage(image: Data) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        request.predicate = NSPredicate(format: "id == %@", "\(self.id)")
        
        do {
            let fetchedData = try context.fetch(request) as! [NSManagedObject]
            if let data = fetchedData.first {
                data.setValue(image, forKey: "posterImage")
            }
            try context.save()
        } catch let error {
            print(error)
        }
    }
}
