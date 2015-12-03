//
//  Bubble.swift
//  ThingForTheThing
//
//  Created by Ryan Smith on 12/3/15.
//  Copyright © 2015 indiePixel. All rights reserved.
//

import UIKit

protocol BubbleDelegate {
    func removeBubble(bubble: Bubble)
}

class Bubble: UIView {

    var delegate: BubbleDelegate?
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return UIDynamicItemCollisionBoundsType.Ellipse
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "timerExpired", userInfo: nil, repeats: false)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func timerExpired() {
        delegate?.removeBubble(self)
    }
}
