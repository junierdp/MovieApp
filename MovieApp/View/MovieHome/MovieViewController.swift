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
    
    @IBOutlet weak var pagerCollectionView: UICollectionView!
    @IBOutlet weak var tabSegmentedControl: UISegmentedControl!
    
    private var movieViewModel: MovieViewModel = MovieViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pagerCollectionView.delegate = self
        self.pagerCollectionView.dataSource = self
        
        self.setUpRequestCallBack()
        
        self.movieViewModel.getMovies()
    }
    
    private func setUpRequestCallBack() {
        // While loading
        self.movieViewModel.whileLoading = {
            // Display loading
        }
        
        // When loaded
        self.movieViewModel.whenLoaded = {
            // Set up movie collection view data
            self.pagerCollectionView.reloadData()
        }
        
        // On error
        self.movieViewModel.onError = { message in
            // Display error message
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        
        self.pagerCollectionView.scrollToItem(at: IndexPath(row: 0, section: sender.selectedSegmentIndex), at: .centeredHorizontally, animated: true)
        
    }
    
    @IBAction func showFilterActionButton(_ sender: Any) {
        let filterViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filterViewController") as! MovieFilterViewController
        
        filterViewController.filterDelegate = self
        Utility.util.addNavigationChildController(childController: filterViewController, navigationController: self.navigationController!)
        Utility.util.setUpModalView(parent: self.navigationController!, child: filterViewController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMovieDetailVC" {
            let movieDetailVC = segue.destination as! MovieDetailViewController
            
            movieDetailVC.movieDetailViewModel = MovieDetailViewModel(movie: sender as! Movie)
            
//            movieDetailVC.movieDetailViewModel = sender as MovieViewModel
        }
    }
}

// MARK: - CollectionViewDelegate, ColectionViewDataSource, CollectionViewDelegateFlowLayout

extension MovieViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pagerCell", for: indexPath) as! MoviePagerCollectionViewCell
        
        cell.movieTableView.reloadData()
        cell.movieViewModel = self.movieViewModel
        cell.movieDelegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tabSegmentedControl.selectedSegmentIndex = indexPath.section
        }
    }
}

// Mark: - MovieDelegate
extension MovieViewController: MovieDelegate {
    func setFavoriteMovie(movie: Movie) {}
    
    func showMovieDetail(movie: Movie) {
        self.performSegue(withIdentifier: "goToMovieDetailVC", sender: movie)
    }
}

// Mark: - MovieFilterDelefate
extension MovieViewController: FilterDelegate {
    func setFilterSelected(filter: MovieViewModel.MovieFilter) {
        // TODO:
    }
}
