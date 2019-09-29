//
//  NavBarController.swift
//  AnimeAddict
//
//  Created by Tony Mark on 4/19/19.
//  Copyright © 2019 Tony Mark. All rights reserved.
//

import UIKit
import NotificationCenter

class NavBarController: UINavigationController {
    var profile: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.topItem?.title = profile
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Verdana-Bold", size: 40)!]
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
