//
//  StatisticsViewController.swift
//  Scorecard
//
//  Created by Halcyon Mobile on 7/15/16.
//  Copyright © 2016 Halcyon Mobile. All rights reserved.
//

import Foundation
import UIKit

class StatisticViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Background
        self.view.backgroundColor = UIColorFromHex(kBackgroundColor, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        // Navigation Bar - TITLE
        self.title = "Statistics"
        self.navigationController?.navigationBar.titleTextAttributes = kNavigationTitleColor       
        self.navigationController?.navigationBar.barTintColor = UIColorFromHex(kBackgroundColor, alpha: 1)
        // End Statistics Title
        // Buttons left & right
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: nil, action: nil)
        
    }
}