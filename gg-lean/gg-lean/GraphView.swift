//
//  GraphView.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

/// Create a line Graph based on a series of points
@IBDesignable class GraphView: UIView {
    
    //Designable Variables
    @IBInspectable var startColor : UIColor = .white
    @IBInspectable var endColor   : UIColor = .blue
    
    fileprivate var taskNameArray: [String]  = ["Red", "Study", "Play", "Orange", "Mario", "Flower", "WubaLub", "Dragon", "Zagreb", "Nunavut", "Heikjavik"]
    fileprivate var taskValueArray: [Float] = [    10,       20,         45,       72,          133,         8,              14,               27,             32,            90,             58]
    
    //Tell that you need to reload the view
    func reloadData(){
        self.setNeedsDisplay()
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        self.backgroundColor = .clear
        
        // graphic context
        let ctx:CGContext! = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10.0)
        path.addClip()
        
        let usableSize:CGSize = CGSize(width: self.bounds.size.width * 4/5, height: self.bounds.size.height * 4/5);
        let deviceColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let margin = usableSize.width * 1/10 as CGFloat
        
        // Setting antialasing
        ctx.setShouldAntialias(true)
        
        //Saving initial context
        ctx.saveGState()
        
        // Scale the context to the desired size
        ctx.scaleBy(x: usableSize.width, y: usableSize.height)
        
        
        // Create background gradient
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: deviceColorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y: 1)
        ctx?.drawLinearGradient(gradient!,
                                start: startPoint,
                                end: endPoint,
                                options: .drawsAfterEndLocation)
        
        ctx.restoreGState()
        ctx.saveGState()
        
        ctx.translateBy(x: margin, y: margin)
        ctx.scaleBy(x: usableSize.width, y: usableSize.height)
        
        let pencilColor:UIColor = .red
        pencilColor.set()
        
        let graphPath = UIBezierPath()
        
        let max:Float = taskValueArray.max() ?? 1.0
        let min:Float =  taskValueArray.min()  ?? 0.0
        
        var counter: CGFloat = 0
        
        let numberOfPoints: CGFloat = CGFloat(taskValueArray.count)
        var circles = [UIBezierPath]()
        for value in taskValueArray{
        
            let x: CGFloat = counter/numberOfPoints
            let y: CGFloat = 1 - CGFloat( (value - min) / (max - min))
            
            let point = CGPoint(x: x + 0.15, y: y)
            
            if (x == 0) {
                //Move to first point location
                graphPath.move(to: point)
            } else
            {
                // Draw a line to the next ones
                graphPath.addLine(to: point)
            }
            
            //create a circle on the point
            circles.append(UIBezierPath(arcCenter: point, radius: 0.011, startAngle: 0, endAngle: 2*( .pi), clockwise: true))
            
            counter  = counter + 1
        }

        UIColor.white.setStroke()
        graphPath.lineWidth = 0.008
        graphPath.stroke()
        
   }
    

    
}
