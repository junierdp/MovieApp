//
//  ViewController.swift
//  MovieApp
//
//  Created by Junier Damian on 12/1/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import UIKit
import Moya

class MovieViewController: UIViewController {
    
    private var movieViewModel: MovieViewModel = MovieViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpRequestCallBack()
        
        self.movieViewModel.getMovies(page: 1)
    }
    
    private func setUpRequestCallBack() {
        // While loading
        self.movieViewModel.whileLoading = {
            // Display loading
        }
        
        // When loaded
        self.movieViewModel.whenLoaded = {
            // Set up movie collection view data
        }
        
        // On error
        self.movieViewModel.onError = { message in
            // Display error message
        }
    }
}

