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
import CoreData

class MovieViewModel {
    enum MovieFilter {
        case rating
        case name
        case year
    }
    
    let movieProvider: MoyaProvider = MoyaProvider<MovieApi>()
    
    var movies: [Movie] = []
    
    var whileLoading: (() -> Void) = { }
    var whenLoaded: (() -> Void) = { }
    var onError: ((String) -> Void) = { _ in }
    
    var currentPage: Int = 0
    
    func getMovies() {
        self.whileLoading()
        let savedMovies = self.getSavedMovies(limit: 20, page: self.currentPage + 1)
        
        if savedMovies != nil {
            savedMovies?.forEach({ movie in
                self.appedSavedMovie(savedMovie: movie)
            })
            self.currentPage += 1
        } else {
            Utility.util.loadRemoteConfig {
                self.movieProvider.request(.nowPlaying(page: self.currentPage + 1), completion: { result in
                    switch result {
                    case .success(let result):
                        do {
                            let response = try JSONDecoder().decode(Movies.self, from: result.data)
                            self.movies = response.results!
                            self.whenLoaded()
                            self.saveMovies(movies: response.results!)
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
    }
    
    func getMovieName(id: Int) -> String {
        return self.getMovieById(id: id)?.title ?? ""
    }
    
    func getMovieIsFavorite(id: Int) -> Bool {
        return self.getMovieById(id: id)?.isFavorite ?? false
    }
    
    func getRatingImage(id: Int) -> UIImage {
        let average: Double = (self.getMovieById(id: id)?.voteAverage)!

        let rating = average
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
    
    func downloadImage(id: Int, whenLoaded: @escaping (UIImage) -> Void) {
        let movie = self.getMovieById(id: id)
        
        if movie!.backgroundImage != nil {
            whenLoaded(UIImage(data: movie!.backgroundImage!)!)
        } else {
            let url: String = "https://image.tmdb.org/t/p/original\(movie!.backgroundPath ?? "")"
            Alamofire.request(url).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    whenLoaded(image)
                    self.saveMovieBackgroundImage(image: response.data!, movieId: (movie?.id)!)
                } else {
                    //                onError()
                }
            })
        }
    }
    
    func getMovieById(id: Int) -> Movie? {
        if let movie = self.movies.first(where: { $0.id == id }) {
            return movie
        }
        return nil
    }
    
    private func appedSavedMovie(savedMovie: NSManagedObject) {
        var movie: Movie = Movie()
        movie.id = savedMovie.value(forKey: "id") as? Int
        movie.title = savedMovie.value(forKey: "title") as? String
        movie.overview = savedMovie.value(forKey: "overview") as? String
        movie.posterPath = savedMovie.value(forKey: "posterPath") as? String
        movie.backgroundPath = savedMovie.value(forKey: "backgroundPath") as? String
        movie.voteAverage = savedMovie.value(forKey: "voteAverage") as? Double
        movie.releaseDate = savedMovie.value(forKey: "releaseDate") as? String
        movie.isFavorite = savedMovie.value(forKey: "isFavorite") as? Bool ?? false
        movie.backgroundImage = savedMovie.value(forKey: "backgroundImage") as? Data
        movie.posterImage = savedMovie.value(forKey: "posterImage") as? Data
        
        self.movies.append(movie)
    }
    
    private func saveMovies(movies: [Movie]) {
        for movie in movies {
            if self.getSavedMovies(id: movie.id!) == nil {
                let entity = NSEntityDescription.entity(forEntityName: "MovieEntity", in: context)
                let movieEntity = NSManagedObject(entity: entity!, insertInto: context)
                
                movieEntity.setValue(movie.backgroundPath, forKey: "backgroundPath")
                movieEntity.setValue(movie.posterPath, forKey: "posterPath")
                movieEntity.setValue(movie.id, forKey: "id")
                movieEntity.setValue(movie.overview, forKey: "overview")
                movieEntity.setValue(movie.releaseDate, forKey: "releaseDate")
                movieEntity.setValue(movie.title, forKey: "title")
                movieEntity.setValue(movie.voteAverage, forKey: "voteAverage")
                
                do {
                    try context.save()
                } catch {
                    self.onError("Error saving movie localy.")
                }
            }
        }
    }
    
    private func getSavedMovies(id: Int = 0, limit: Int = 20, page: Int = 1) -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        if id != 0 {
            request.predicate = NSPredicate(format: "id == %@", "\(id)")
        } else {
            let fetchOffset = limit * (page - 1)
            request.fetchOffset = fetchOffset
        }
        do {
            let fetchedData = try context.fetch(request)
            if fetchedData.isEmpty {
                return nil
            } else {
                return fetchedData as? [NSManagedObject]
            }
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func saveMovieBackgroundImage(image: Data, movieId: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        request.predicate = NSPredicate(format: "id == %@", "\(movieId)")
        
        do {
            let fetchedData = try context.fetch(request) as! [NSManagedObject]
            if let data = fetchedData.first {
                data.setValue(image, forKey: "backgroundImage")
            }
            try context.save()
        } catch let error {
            print(error)
        }
    }
    
    public func setFavoriteMovie(id: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let fetchedData = try context.fetch(request) as! [NSManagedObject]
            if let data = fetchedData.first {
                data.setValue(!(self.getMovieById(id: id)?.isFavorite)!, forKey: "isFavorite")
                for i in 0..<self.movies.count {
                    if self.movies[i].id == id {
                        self.movies[i].isFavorite = !self.movies[i].isFavorite
                    }
                }
            }
            try context.save()
        } catch let error {
            print(error)
        }
    }
}
