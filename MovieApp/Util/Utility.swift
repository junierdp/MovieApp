//
//  Utility.swift
//  MovieApp
//
//  Created by Junier Damian on 12/2/18.
//  Copyright © 2018 JunierOniel. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    static let util = Utility()
    
    var overlayView = UIView()
    let screenSize: CGRect = UIScreen.main.bounds
    
    func displayActivityIndicator(view: UIView) {
        let activityIndicator = UIActivityIndicatorView.init(style: .white)
        overlayView = UIView(frame: self.screenSize)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        activityIndicator.frame = CGRect.init(origin: view.center, size: CGSize.init(width: 50, height: 50))
        activityIndicator.startAnimating()
        
        self.overlayView.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
        view.addSubview(self.overlayView)
        self.overlayView.alpha = 0
        self.overlayView.fadeIn()
    }
    
    func removeActivityIndicator(view: UIView) {
        self.overlayView.alpha = 1.0
        self.overlayView.fadeOut()
        self.overlayView.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }
    
    func alert(_ title: String, message: String, titleAlert: String, style: UIAlertAction.Style, view: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: titleAlert, style: style, handler: handler))
        alertController.view.tintColor = #colorLiteral(red: 0.05735682696, green: 0.3269351721, blue: 0.5926874876, alpha: 1)
        
        view.present(alertController, animated:true, completion: nil)
    }
    
    func addNavigationChildController(childController: UIViewController, navigationController: UINavigationController) {
        navigationController.addChild(childController)
        navigationController.view.addSubview(childController.view)
        childController.didMove(toParent: navigationController.navigationController)
    }
    
    func setUpModalView(parent: UIViewController, child: UIViewController) {
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
        child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
        child.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor).isActive = true
        child.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor).isActive = true
    }
}

extension UIView {
    func fadeIn(withDuration duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    func fadeOut(withDuration duration: TimeInterval = 0.25) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}
