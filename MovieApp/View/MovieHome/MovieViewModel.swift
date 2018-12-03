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
    
    func getMovieName(index: Int) -> String {
        return self.movies[index].title ?? ""
    }
    
    func getMovieIsFavorite(index: Int) -> Bool {
        return self.movies[index].isFavorite
    }
    
    func getRatingImage(index: Int) -> UIImage {
        let rating = self.movies[index].voteAverage!
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
        let movie = self.movies[index]
        if movie.backgroundImage != nil {
            whenLoaded(UIImage(data: movie.backgroundImage!)!)
        } else {
            let url: String = "https://image.tmdb.org/t/p/original\(self.movies[index].backgroundPath ?? "")"
            Alamofire.request(url).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    whenLoaded(image)
                    self.saveMovieImage(attribute: "backgroundImage", image: response.data!, movieId: self.movies[index].id!)
                } else {
                    //                onError()
                }
            })
        }
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
    
    private func saveMovieImage(attribute: String, image: Data, movieId: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        request.predicate = NSPredicate(format: "id == %@", "\(movieId)")
        
        do {
            let fetchedData = try context.fetch(request) as! [NSManagedObject]
            if let data = fetchedData.first {
                data.setValue(image, forKey: attribute)
            }
            try context.save()
        } catch let error {
            print(error)
        }
        
    }
    
    public func setFavoriteMovie(id: Int, isFavorite: Bool) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let fetchedData = try context.fetch(request) as! [NSManagedObject]
            if let data = fetchedData.first {
                data.setValue(isFavorite, forKey: "isFavorite")
                for i in 0..<self.movies.count {
                    if self.movies[i].id == id {
                        self.movies[i].isFavorite = isFavorite
                    }
                }
            }
            try context.save()
        } catch let error {
            print(error)
        }
    }
}
