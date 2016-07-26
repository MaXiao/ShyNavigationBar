//
//  ShyNavbar.swift
//  ShyNavbar
//
//  Created by Xiao Ma on 2016-07-22.
//  Copyright © 2016 Xiao Ma. All rights reserved.
//

import UIKit

class ShyNavbar: UINavigationBar, UIScrollViewDelegate {
    var previousScrollViewY: CGFloat = 0
    var scrollDownThreshold: CGFloat = 100
    var scrollUpThreshold: CGFloat = 45
    var startingPointY: CGFloat = 0
    let parallaxFactor: CGFloat = 0.8
    let statusBarHeight: CGFloat = 20
    
    let subbar = UIView()
    
    weak var scrollView: UIScrollView? {
        didSet {
            oldValue?.delegate = originalDelegate
            originalDelegate = scrollView?.delegate
            scrollView?.delegate = self
        }
    }
    private weak var originalDelegate: UIScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        subbar.backgroundColor = UIColor.blueColor()
        
        
        clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if frame.minY > 0 && subbar.frame.width == 0 {
            subbar.frame = CGRect(x: 0, y: frame.maxY, width: frame.width, height: 40)
            superview?.insertSubview(subbar, belowSubview: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidScroll?(scrollView)
        
        var frame = self.frame
        let bottomMargin = frame.height - statusBarHeight
        let scrollOffset = scrollView.contentOffset.y;
        let scrollDiff = scrollOffset - previousScrollViewY
        let scrollHeight = scrollView.frame.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        // subbar
        var subFrame = subbar.frame
        
        // set a navbar expanding threshold for scrolling back
        if scrollOffset - startingPointY < 0 && scrollOffset - startingPointY > -scrollDownThreshold && (startingPointY > -statusBarHeight) {
            previousScrollViewY = scrollOffset
            return
        }
        
        if scrollOffset < -scrollView.contentInset.top && scrollDiff > 0 {
            previousScrollViewY = scrollOffset
            print("here \(scrollDiff)")
            return
        }
        
        // subbar frame updating
        if scrollOffset <= -scrollView.contentInset.top {
            subFrame.origin.y = 64
        } else if scrollOffset + scrollHeight >= scrollContentSizeHeight {
            subFrame.origin.y = frame.maxY - 5 - frame.height
        } else {
            subFrame.origin.y = min(64, max(frame.maxY - 5 - subFrame.height, subFrame.origin.y - scrollDiff))
        }
        subbar.frame = subFrame
        
        // navbar frame updating
        if scrollOffset - startingPointY > 0 && scrollOffset - startingPointY < scrollUpThreshold {
            previousScrollViewY = scrollOffset
            return
        }
        if scrollOffset <= -scrollView.contentInset.top {
            frame.origin.y = statusBarHeight
        } else if scrollOffset + scrollHeight >= scrollContentSizeHeight {
            frame.origin.y = -bottomMargin
        } else {
            frame.origin.y = min(statusBarHeight, max(-bottomMargin, frame.origin.y - scrollDiff))
        }
        self.frame = frame
        
        // adjust navbar items
        let percentHidden = (statusBarHeight - frame.minY) / (frame.height)
        // times 2, so that items will be hidden half way towards top.
        updateBarButtonItems(1 - percentHidden * 2)
        
        // adjust scroll indicator inset to match navbar position
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: frame.maxY + scrollUpThreshold - 5, left: 0, bottom: 0, right: 0)
    
        previousScrollViewY = scrollView.contentOffset.y
            
        print("offset: \(scrollView.contentOffset.y), inset: \(scrollView.contentInset.top)")
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        startingPointY = max(-scrollView.contentInset.top, scrollView.contentOffset.y) 
        print(startingPointY)
        
        originalDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.stoppedScrolling()
        
        originalDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.stoppedScrolling()
        }
        
        originalDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    func updateBarButtonItems(percent: CGFloat) {
        for (index, view) in subviews.enumerate() {
            if index > 0 && index < subviews.count - 1{
                view.alpha = percent
                
                var frame = view.frame
                let originalY = floor((self.frame.height - frame.height) / 2)
                let offset = self.frame.height * (1 - parallaxFactor) * (1 - percent)
                let y = CGFloat(originalY + offset)
                frame.origin.y = y
                view.frame = frame
            }
        }
    }
    
    func stoppedScrolling() {
        if subbar.frame.origin.y < 64 && subbar.frame.origin.y > 64 - subbar.frame.height {
            self.animateSubbarTo(64)
        }
        
        if frame.origin.y < statusBarHeight {
            self.animateNavbarTo(-(frame.height - statusBarHeight))
            self.animateSubbarTo(-(subbar.frame.height - statusBarHeight))
        }
    }
    
    func animateSubbarTo(y: CGFloat) {
        UIView.animateWithDuration(0.2) {
            var frame = self.subbar.frame
            
            self.scrollView?.contentOffset.y += frame.origin.y - y
            
            frame.origin.y = y
            self.subbar.frame = frame
        }
    }
    
    func animateNavbarTo(y: CGFloat) {
        UIView.animateWithDuration(0.2) {
            var frame = self.frame
            let alpha: CGFloat = frame.origin.y >= y ? 0 : 1
            if alpha == 0 {
                self.scrollView?.contentOffset.y += (frame.origin.y - y)
            }
            frame.origin.y = y
            self.frame = frame
            self.updateBarButtonItems(alpha)
        }
    }
}