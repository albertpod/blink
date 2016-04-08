//
//  DrawView.swift
//  Blink
//
//  Created by Albert Podusenko on 28.03.16.
//  Copyright © 2016 Albert Podusenko. All rights reserved.
//

import Foundation

class DrawView : UIView {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context,
                                         UIColor.blueColor().CGColor)
        let rectangle = CGRectMake(60,170,200,80)
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)
    }
}