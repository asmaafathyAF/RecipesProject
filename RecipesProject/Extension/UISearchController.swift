//
//  UISearchController.swift
//  LoginTask
//
//  Created by Tech Labs on 10/3/19.
//  Copyright © 2019 Jets39. All rights reserved.
//

import UIKit

extension UISearchController {
    func createSearchController(_ viewController: UIViewController) {
             obscuresBackgroundDuringPresentation = false
             searchBar.placeholder = "search"
             if #available(iOS 11.0, *) {
                viewController.navigationItem.searchController = self
                viewController.navigationItem.hidesSearchBarWhenScrolling = false
             } else {
                 // Fallback on earlier versions
             }
             definesPresentationContext = true
       }
}
