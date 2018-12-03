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
    func setFavoriteMovie(movie: Movie)
}

class MoviePagerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieTableView: UITableView! {
        didSet {
            self.movieTableView.delegate = self
            self.movieTableView.dataSource = self
        }
    }
    
    var movieViewModel: MovieViewModel?
    var movieDelegate: MovieDelegate?
}

// MARK: - TableViewDelegate, TableViewDatasource
extension MoviePagerCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieViewModel?.movies.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        cell.movieNameLabel.text = self.movieViewModel?.getMovieName(index: indexPath.row)
        cell.movieRatingImage.image = self.movieViewModel?.getRatingImage(index: indexPath.row)
        
        if (self.movieViewModel?.getMovieIsFavorite(index: indexPath.row))! {
            cell.movieFavoriteButton.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else {
            cell.movieFavoriteButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        
        self.movieViewModel?.downloadImage(index: indexPath.row, whenLoaded: { image in
            cell.movieBackgroundImage.image = image
        })
        
        cell.movie = self.movieViewModel?.movies[indexPath.row]
        cell.movieDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let movie = self.movieViewModel?.movies[indexPath.row] {
            self.movieDelegate?.showMovieDetail(movie: movie)
        }
    }
}

// Mark: - MovieDelegate
extension MoviePagerCollectionViewCell: MovieDelegate {
    func showMovieDetail(movie: Movie) {}
    
    func setFavoriteMovie(movie: Movie) {
        self.movieViewModel!.setFavoriteMovie(id: movie.id!, isFavorite: !movie.isFavorite)
        self.movieTableView.reloadData()
    }
}
