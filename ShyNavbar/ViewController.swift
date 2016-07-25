//
//  ViewController.swift
//  ShyNavbar
//
//  Created by Xiao Ma on 2016-07-21.
//  Copyright © 2016 Xiao Ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    var previousScrollViewY: CGFloat = 0
    let scrollBackThreshold: CGFloat = 100
    var startingPointY: CGFloat = 0
    let parallaxFactor: CGFloat = 0.8
    var scrollView: UIScrollView?
    
    let subbar = UIView()

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
        
        var insets = scrollView.contentInset
        insets.top += 40
        scrollView.contentInset = insets
        
        scrollView.contentOffset.y -= 40
        scrollView.scrollIndicatorInsets = insets
        
        if let navbar = navigationController?.navigationBar as? ShyNavbar {
            navbar.scrollView = scrollView
            
            subbar.backgroundColor = UIColor.blueColor()
            subbar.frame = CGRect(x: 0, y: navbar.frame.maxY, width: view.frame.width, height: 40)
//            view.addSubview(subbar)
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: 20))
        label.text = "Top"
        label.textAlignment = .Center
        scrollView.addSubview(label)
        
        
        previousScrollViewY = scrollView.contentOffset.y
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func scrollViewDidScroll(scrollView: UIScrollView) {
//        print("original scrollViewDidScroll")
        let scrollDiff = scrollView.contentOffset.y -  previousScrollViewY
        
//        var frame = subbar.frame
//        
//        let scrollOffset = scrollView.contentOffset.y
//        let scrollHeight = scrollView.frame.height
//        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
//        
//        if let navbarFrame = navigationController?.navigationBar.frame {
//            if scrollOffset <= -scrollView.contentInset.top {
//                frame.origin.y = 64
//            } else if scrollOffset + scrollHeight >= scrollContentSizeHeight {
//                frame.origin.y = navbarFrame.maxY - frame.height
//            } else {
//                frame.origin.y = min(64, max(navbarFrame.maxY - frame.height, frame.origin.y - scrollDiff))
//            }
//        }
//        
//        subbar.frame = frame
        
        
        previousScrollViewY = scrollView.contentOffset.y
    }
    
    func test() {
        
    }
}

