//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Junier Damian on 12/2/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDateLabel: UILabel!
    @IBOutlet weak var movieRatingImage: UIImageView!
    @IBOutlet weak var movieOverviewTextView: UITextView!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    
    var movieDetailViewModel: MovieDetailViewModel?
    var movieDelegate: MovieDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.movieTitleLabel.text = self.movieDetailViewModel?.title
        self.movieDateLabel.text = self.movieDetailViewModel?.date
        self.movieOverviewTextView.text = self.movieDetailViewModel?.overview
        self.movieDetailViewModel?.downloadImage(whenLoaded: { image in
            self.moviePosterImage.image = image
        })
        if (self.movieDetailViewModel!.isFavorite) {
            self.favoriteBarButton.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else {
            self.favoriteBarButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
    
    @IBAction func favoriteBarButtonAction(_ sender: UIBarButtonItem) {
        if (self.movieDetailViewModel?.isFavorite)! {
            self.movieDelegate!.setFavoriteMovie(id: self.movieDetailViewModel!.id)
            self.movieDetailViewModel!.isFavorite = false
            sender.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        } else {
            self.movieDelegate!.setFavoriteMovie(id: self.movieDetailViewModel!.id)
            self.movieDetailViewModel!.isFavorite = true
            sender.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
    }
    
}
