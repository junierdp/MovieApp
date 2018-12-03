//
//  MovieFilterViewController.swift
//  MovieApp
//
//  Created by Junier Damian on 12/2/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func setFilterSelected(filter: MovieViewModel.MovieFilter)
}

class MovieFilterViewController: UIViewController {
    
    var filterDelegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
    }
    
    
    @IBAction func filterButtonAction(_ sender: UIButton) {
        if sender.tag == 1 {
            self.filterDelegate?.setFilterSelected(filter: .rating)
        } else if sender.tag == 2 {
            self.filterDelegate?.setFilterSelected(filter: .name)
        } else if sender.tag == 3 {
            self.filterDelegate?.setFilterSelected(filter: .year)
        }
        self.removeFromSuperView()
    }
    
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.removeFromSuperView()
    }
    
    private func removeFromSuperView() {
        self.willMove(toParent: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
}
