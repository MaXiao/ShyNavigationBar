//
//  ViewController.swift
//  ShyNavbar
//
//  Created by Xiao Ma on 2016-07-21.
//  Copyright © 2016 Xiao Ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.grayColor()
        title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Test", style: .Plain, target: self, action: #selector(test))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(test))
        navigationItem.titleView = {
            let label = UILabel()
            label.text = "Home"
            label.sizeToFit()
            return label
        }()
        let scrollView = UIScrollView(frame: view.bounds)
        self.scrollView = scrollView
        scrollView.backgroundColor = UIColor.cyanColor()
        view.addSubview(scrollView)
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: 5000)
        scrollView.delegate = self
        
        let subbar = UIView()
        subbar.frame = CGRect(x: 0, y: 64, width: view.frame.width, height: 40)
        subbar.backgroundColor = UIColor.blueColor()
        
        var insets = scrollView.contentInset
        insets.top += 40
        scrollView.contentInset = insets
        
        scrollView.contentOffset.y -= 40
        
        if let navbar = navigationController?.navigationBar as? ShyNavbar {
            navbar.scrollView = scrollView
            navbar.subbar = subbar
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: 20))
        label.text = "Top"
        label.textAlignment = .Center
        scrollView.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func scrollViewDidScroll(scrollView: UIScrollView) {
//        print("original scrollViewDidScroll")
    }
    
    func test() {
        
    }
}

