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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        let usableSize:CGSize = CGSize(width: self.bounds.size.width, height: self.bounds.size.height);
        let deviceColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let margin = usableSize.width * 1/10 as CGFloat
        
        // Scale the context to the desired size
        ctx.scaleBy(x: usableSize.width, y: usableSize.height)
        
        // Setting antialasing
        ctx.setShouldAntialias(true)
        
        //Saving initial context
        ctx.saveGState()
        
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
        ctx.translateBy(x: margin, y: margin)
        
        let pencilColor:UIColor = .red
        pencilColor.set()
        
        let graphPath = UIBezierPath()
        
        let maximumSample:Float = taskValueArray.max() ?? 1.0
        let minimumSample:Float = taskValueArray.min() ?? 0.0
        
        var counter: CGFloat = 0
        
        let numberOfPoints: CGFloat = CGFloat(taskValueArray.count)
        var circles = [UIBezierPath]()
        for value in taskValueArray{
        
            let x: CGFloat = counter/numberOfPoints
            let y: CGFloat = 1 - CGFloat( (value - minimumSample) / (maximumSample - minimumSample))
            
            let point = CGPoint(x: x, y: y)
            
            if (x == 0) {
                //Move to first point location
                graphPath.move(to: point)
            } else
            {
                // Draw a line to the next ones
                graphPath.addLine(to: point)
            }
            
            //create a circle on the point
            circles.append(UIBezierPath(arcCenter: point, radius: 0.01, startAngle: 0, endAngle: 2*( .pi), clockwise: true))
            
            counter  = counter + 1
        }
        
        graphPath.lineWidth = 0.1
        graphPath.stroke()
        
        //Drawing circles
//        ctx.restoreGState()
//        
//        for circle in circles{
//            circle.fill()
//        }
//        ctx.restoreGState()
   }
    

    
}
