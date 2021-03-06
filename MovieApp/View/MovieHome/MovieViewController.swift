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
            Utility.util.displayActivityIndicator(view: (self.navigationController?.view)!)
        }
        
        // When loaded
        self.movieViewModel.whenLoaded = {
            self.pagerCollectionView.reloadData()
            Utility.util.removeActivityIndicator(view: (self.navigationController?.view)!)
        }
        
        // On error
        self.movieViewModel.onError = { message in
            Utility.util.removeActivityIndicator(view: (self.navigationController?.view)!)
            Utility.util.alert("Oops!", message: message, titleAlert: "OK", style: .default, view: self.navigationController!)
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
            movieDetailVC.movieDelegate = self
            movieDetailVC.movieDetailViewModel = MovieDetailViewModel(movie: sender as! Movie)
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
        
        cell.movieDelegate = self
        cell.section = indexPath.section
        if indexPath.section == 1 {
            cell.movieViewModel.movies = self.movieViewModel.movies.filter({ $0.isFavorite })
        } else {
            cell.movieViewModel.movies = self.movieViewModel.movies
        }
        cell.movieTableView.reloadData()
        
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
    func loadNewMovies(index: Int) {
        if index == self.movieViewModel.movies.count - 1 {
            self.movieViewModel.getMovies()
        }
    }
    
    func setFavoriteMovie(id: Int) {
        self.movieViewModel.setFavoriteMovie(id: id)
        self.pagerCollectionView.reloadData()
    }
    
    func showMovieDetail(movie: Movie) {
        self.performSegue(withIdentifier: "goToMovieDetailVC", sender: movie)
        Utility.util.logMovieFirebaseEvent(movie: movie)
    }
}

// Mark: - MovieFilterDelefate
extension MovieViewController: FilterDelegate {
    func setFilterSelected(filter: MovieViewModel.MovieFilter) {
        self.movieViewModel.sortMovieBy(filter: filter)
        self.pagerCollectionView.reloadData()
    }
}
