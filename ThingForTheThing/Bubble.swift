//
//  Bubble.swift
//  ThingForTheThing
//
//  Created by Ryan Smith on 12/3/15.
//  Copyright © 2015 indiePixel. All rights reserved.
//

import UIKit

class Bubble: UIView {

    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return UIDynamicItemCollisionBoundsType.Ellipse
    }

}
