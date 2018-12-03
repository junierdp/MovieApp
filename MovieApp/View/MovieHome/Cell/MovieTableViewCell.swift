//
//  MovieTableViewCell.swift
//  MovieApp
//
//  Created by Junier Damian on 12/1/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieBackgroundImage: UIImageView!
    @IBOutlet weak var movieRatingImage: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieFavoriteButton: UIButton!
    
    var movieDelegate: MovieDelegate?
    var movie: Movie?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
        if (self.movie?.isFavorite)! {
            self.movieFavoriteButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        } else {
            self.movieFavoriteButton.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
        self.movieDelegate?.setFavoriteMovie(id: (self.movie?.id)!)
    }
}
