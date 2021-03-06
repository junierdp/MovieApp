//
//  MovieCollectionViewCell.swift
//  MovieApp
//
//  Created by Junier Damian on 12/1/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import UIKit

protocol MovieDelegate {
    func showMovieDetail(movie: Movie)
    func setFavoriteMovie(id: Int)
    func loadNewMovies(index: Int)
}

class MoviePagerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieTableView: UITableView! {
        didSet {
            self.movieTableView.delegate = self
            self.movieTableView.dataSource = self
        }
    }
    
    var movieViewModel: MovieViewModel = MovieViewModel()
    var movieDelegate: MovieDelegate?
    var section: Int = 0
}

// Mark: - TableViewDelegate, TableViewDatasource
extension MoviePagerCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieViewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        let movie = self.movieViewModel.movies[indexPath.row]
        
        cell.movieNameLabel.text = self.movieViewModel.getMovieName(id: (movie.id)!)
        cell.movieRatingImage.image = self.movieViewModel.getRatingImage(id: (movie.id)!)
        
        if (self.movieViewModel.getMovieIsFavorite(id: (movie.id)!)) {
            cell.movieFavoriteButton.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else {
            cell.movieFavoriteButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        
//        cell.movieBackgroundImage.image = UIImage()
        self.movieViewModel.downloadImage(id: (movie.id)!, whenLoaded: { image in
            DispatchQueue.main.async {
                cell.movieBackgroundImage.image = image
            }
        })
        
        cell.movie = self.movieViewModel.movies[indexPath.row]
        cell.movieDelegate = self.movieDelegate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movieDelegate?.showMovieDetail(movie: (self.movieViewModel.movies[indexPath.row]))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if section == 0 {
            self.movieDelegate?.loadNewMovies(index: indexPath.row)
        }
    }
}
