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
        
        if let navbar = navigationController?.navigationBar as? ShyNavbar {
            navbar.scrollView = scrollView
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
        print("original scrollViewDidScroll")
    }
//
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        startingPointY = scrollView.contentOffset.y
//    }
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        self.stoppedScrolling()
//    }
//    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            self.stoppedScrolling()
//        }
//    }
    
    func updateBarButtonItems(percent: CGFloat) {
        guard let subviews = navigationController?.navigationBar.subviews else {
            return
        }
        
        print((subviews[1].subviews[0] as! UILabel).frame)
        for (index, view) in subviews.enumerate() {
            if index > 0 && index < subviews.count - 1{
                view.alpha = percent
                
                var frame = view.frame
                let originalY = floor((44 - frame.height) / 2)
                let offset = 44 * (1 - parallaxFactor) * (1 - percent)
                let y = CGFloat(originalY + offset)
                frame.origin.y = y
                view.frame = frame
            }
        }
    }
    
    func stoppedScrolling() {
        if let frame = self.navigationController?.navigationBar.frame {
            if frame.origin.y < 20 {
                self.animateNavbarTo(-(frame.height - 20))
            }
        }
    }
    
    func animateNavbarTo(y: CGFloat) {
        UIView.animateWithDuration(0.2) { 
            if var frame = self.navigationController?.navigationBar.frame {
                let alpha: CGFloat = frame.origin.y >= y ? 0 : 1
                if alpha == 0 {
                    self.scrollView?.contentOffset.y += (frame.origin.y - y)
                }
                frame.origin.y = y
                self.navigationController?.navigationBar.frame = frame
                self.updateBarButtonItems(alpha)
            }
        }
    }
    
    func test() {
        
    }
}

