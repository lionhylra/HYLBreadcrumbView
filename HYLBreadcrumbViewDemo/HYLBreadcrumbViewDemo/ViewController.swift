//
//  ViewController.swift
//  HYLBreadcrumbViewDemo
//
//  Created by HeYilei on 16/02/2016.
//  Copyright © 2016 lionhylra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var breadcrumbView:HYLBreadcrumbView!
    var data = ["1 Level","2 Level"]
    var currentLevel = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        self.breadcrumbView.delegate = self
        self.breadcrumbView.dataSource = self
        self.breadcrumbView.fontSize = 20;
        self.breadcrumbView.separatorString = "=>"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(){
        self.data.append("\(++self.currentLevel) Level")
        self.breadcrumbView.reloadData()
    }

}

extension ViewController:HYLBreadcrumbViewDataSource, HYLBreadcrumbViewDelegate{
    func numberOfItemsInBreadcrumbView(breadcrumbView: HYLBreadcrumbView) -> Int {
        return self.data.count
    }
    func breadcrumbView(breadcrumbView: HYLBreadcrumbView, titleForItemAtIndex index: Int) -> String {
        return self.data[index]
    }
    func breadcrumbView(breadcrumbView: HYLBreadcrumbView, didSelectItemAtIndex index: Int) {
        print(self.data[index])
    }
}

