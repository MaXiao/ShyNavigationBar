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
    let scrollBackThreshold: CGFloat = 100
    var startingPointY: CGFloat = 0
    let parallaxFactor: CGFloat = 0.8
    
    weak var scrollView: UIScrollView? {
        didSet {
            oldValue?.delegate = originalDelegate
            originalDelegate = scrollView?.delegate
            scrollView?.delegate = self
        }
    }
    private weak var originalDelegate: UIScrollViewDelegate?
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var frame = self.frame
        let bottomMargin = frame.height - 20
        let scrollOffset = scrollView.contentOffset.y;
        
        // set a navbar expanding threshold for scrolling back
        if scrollOffset - startingPointY < 0 && scrollOffset - startingPointY > -scrollBackThreshold && (startingPointY > -20) {
            previousScrollViewY = scrollOffset
            return
        }
        
        let scrollDiff = scrollOffset - previousScrollViewY
        let scrollHeight = scrollView.frame.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        if scrollOffset <= -scrollView.contentInset.top {
            frame.origin.y = 20
        } else if scrollOffset + scrollHeight >= scrollContentSizeHeight {
            frame.origin.y = -bottomMargin
        } else {
            frame.origin.y = min(20, max(-bottomMargin, frame.origin.y - scrollDiff))
        }
        self.frame = frame
        
        // adjust navbar items
        let percentHidden = (20 - frame.minY) / (frame.height)
        // times 2, so that items will be hidden half way towards top.
        updateBarButtonItems(1 - percentHidden * 2)
        
        // adjust scroll indicator inset to match navbar position
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: frame.maxY, left: 0, bottom: 0, right: 0)
    
        previousScrollViewY = scrollView.contentOffset.y
            
        originalDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        startingPointY = scrollView.contentOffset.y
        
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
        if frame.origin.y < 20 {
            self.animateNavbarTo(-(frame.height - 20))
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