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
    var scrollUpThreshold: CGFloat = 0
    let parallaxFactor: CGFloat = 0.8
    
    private var startingPointY: CGFloat = 0
    private let statusBarHeight: CGFloat = 20
    // a little margin to make sure subbar will be hidden fully behind navbar
    private let subbarMargin: CGFloat = 1
    
    weak var scrollView: UIScrollView? {
        didSet {
            oldValue?.delegate = originalDelegate
            originalDelegate = scrollView?.delegate
            scrollView?.delegate = self
        }
    }
    
    // Add subbar after scrollView assignment
    // So we can adjust scrollview's inset and offset
    var subbar: UIView? {
        willSet {
            if let bar = newValue {
                scrollUpThreshold = bar.frame.height + subbarMargin
                superview?.insertSubview(bar, belowSubview: self)
                bar.frame = CGRect(origin: CGPoint(x: 0, y: frame.maxY), size: bar.frame.size)
                
                scrollView?.contentInset.top += bar.frame.height
                scrollView?.contentOffset.y -= bar.frame.height
            }
        }
    }
    
    // keep a ref to the original scrollview delegate
    // so we can forward callback to it
    private weak var originalDelegate: UIScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
    }
    
    //MARK: - Scroll view delegate methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidScroll?(scrollView)
        
        var frame = self.frame
        var subFrame = CGRectZero
        if let subbar = subbar {
            subFrame = subbar.frame
        }
        
        let bottomMargin = frame.height - statusBarHeight
        let scrollOffset = scrollView.contentOffset.y;
        let scrollDiff = scrollOffset - previousScrollViewY
        let scrollHeight = scrollView.frame.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        // There is a arbitrary scroll-down-threshold before navbar reappear
        // Checking conditions as follow:
        // 1. is scrolling down
        // 2. diff is larger than certain threshold or scrollview reach top
        // 3. Is not a continuous, zigzag gesture changed from scrolling up
        if (scrollDiff < 0) && (startingPointY - scrollOffset < scrollDownThreshold) && (scrollOffset > -statusBarHeight) && startingPointY <= scrollOffset {
            previousScrollViewY = scrollOffset
            print("scroll down threshhold checkout")
            return
        }
        
        // Prevent glitchy behaviour when scrollview is pulled down in a rubber-band zone
        if scrollOffset < -scrollView.contentInset.top && scrollDiff > 0 {
            previousScrollViewY = scrollOffset
            print("rubber band zone checkout")
            return
        }
        
        // Scroll-up-threshold that equals to subber height
        // So that subbar will move up before navbar
        if scrollDiff > 0 && subFrame.maxY >= frame.maxY {
            print("scroll up threshold checkout")
            previousScrollViewY = scrollOffset
        } else {
            // navbar updating
            if scrollOffset <= -scrollView.contentInset.top {
                frame.origin.y = statusBarHeight
            } else if scrollOffset + scrollHeight >= scrollContentSizeHeight {
                frame.origin.y = -bottomMargin
            } else {
                frame.origin.y = min(statusBarHeight, max(-bottomMargin, frame.origin.y - scrollDiff))
            }
            self.frame = frame
        }
        
        // subbar frame updating
        if let subbar = subbar {
            if scrollOffset <= -scrollView.contentInset.top {
                subFrame.origin.y = statusBarHeight + frame.height
            } else if scrollOffset + scrollHeight >= scrollContentSizeHeight {
                subFrame.origin.y = frame.maxY - frame.height - subbarMargin
            } else {
                subFrame.origin.y = min(statusBarHeight + frame.height, max(frame.maxY - subFrame.height - subbarMargin, subFrame.origin.y - scrollDiff))
            }
            subbar.frame = subFrame
        }
        
        // adjust navbar items
        let percentHidden = (statusBarHeight - frame.minY) / (frame.height)
        // times 2, so that items will be hidden half way towards top.
        updateBarButtonItems(1 - percentHidden * 2)
        
        // adjust scroll indicator inset to match navbar position
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: frame.maxY + scrollUpThreshold - subbarMargin, left: 0, bottom: 0, right: 0)
    
        previousScrollViewY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        startingPointY = max(-scrollView.contentInset.top, scrollView.contentOffset.y)
        
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
    
    
    // MARK: - other utils
    private func updateBarButtonItems(percent: CGFloat) {
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
    
    private func stoppedScrolling() {
        let topMargin = statusBarHeight + frame.height
        
        
        if let subbar = subbar where subbar.frame.origin.y < topMargin && subbar.frame.origin.y > topMargin - subbar.frame.height {
            animateSubbarTo(topMargin, shouldAdjustScrollView: true)
            
        }
        
        if frame.origin.y < statusBarHeight {
            animateNavbarTo(-(frame.height - statusBarHeight))
        }
        
        if let subbar = subbar where subbar.frame.origin.y <= topMargin - subbar.frame.height {
            animateSubbarTo(-(subbar.frame.height - statusBarHeight), shouldAdjustScrollView: false)
        }
    }
    
    private func animateSubbarTo(y: CGFloat, shouldAdjustScrollView shouldAdjust: Bool ) {
        UIView.animateWithDuration(0.2) {
            if let subbar = self.subbar {
                var frame = subbar.frame
                if shouldAdjust {
                    self.scrollView?.contentOffset.y += frame.origin.y - self.statusBarHeight + self.frame.height
                }
                frame.origin.y = y
                subbar.frame = frame
            }
        }
    }
    
    private func animateNavbarTo(y: CGFloat) {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}