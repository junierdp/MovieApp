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
    
    var movieDetailViewModel: MovieDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.movieTitleLabel.text = self.movieDetailViewModel?.title
        self.movieDateLabel.text = self.movieDetailViewModel?.date
        self.movieOverviewTextView.text = self.movieDetailViewModel?.overview
        self.movieDetailViewModel?.downloadImage(whenLoaded: { image in
            self.moviePosterImage.image = image
        })
    }
}
