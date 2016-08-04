//
//  ACPCustomStaticImages.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/21/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import ACPDownload

class ACPCustomStaticImages: ACPStaticImages {
    
    override func drawStatusComplete() {
        
        let canvasWidth = self.bounds.size.width;
        let canvasHeight = self.bounds.size.height;
        
        var bezierPath = UIBezierPath()
        
        // green circle
        let centerPoint = CGPoint(x: canvasWidth / 2, y: canvasHeight / 2)
        bezierPath.moveToPoint(centerPoint)
        
        let radius = min(canvasWidth / 3, canvasHeight / 3)
        bezierPath.addArcWithCenter(centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        
        UIColor.init(red: 0, green: 0.7, blue: 0, alpha: 1).setFill()
        bezierPath.closePath()
        bezierPath.fill()
        
        // ok mark
        
        bezierPath = UIBezierPath()

        let a = CGPoint(x: (0.35 - 0.03) * canvasWidth, y: 0.45 * canvasHeight)
        let b = CGPoint(x: (0.5 - 0.03) * canvasWidth, y: 0.6 * canvasHeight)
        let c = CGPoint(x: (0.7 - 0.03) * canvasWidth, y: 0.35 * canvasHeight)
        
        UIColor.whiteColor().set()
        
        bezierPath.moveToPoint(a)
        bezierPath.addLineToPoint(b)
        bezierPath.addLineToPoint(c)
        
        bezierPath.lineWidth = 3
        bezierPath.stroke()
        
//        bezierPath.()
        
        
    }
    
}

