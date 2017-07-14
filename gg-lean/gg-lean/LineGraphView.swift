//
//  GraphView.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

let circleSizeConstant : CGFloat = 8000
let highlightedColor : CGColor = UIColor.orange.cgColor

/// Implement this protocol to generate the graph Value points to a specifc data
protocol LineGraphProtocol : NSObjectProtocol{
    func getGraphValueArray() -> [Float]
    func getSelectedRow() -> Int
}

/// Create a line Graph based on a series of points
@IBDesignable class LineGraphView: UIView {
    
    //Designable Variables
    @IBInspectable var startColor : UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
    @IBInspectable var endColor   : UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.45)
    
    fileprivate var taskValueArray: [Float] = [10, 20, 30, 12, 15, 33, 50, 3, 10, 22, 23, 38]
    fileprivate var selectedPoint : Int = -1
    
    var lineGraphDataSource : LineGraphProtocol?
    
    //Subtitles
    var lowValueSubtitle = UILabel()
    var mediumValueSubtitle = UILabel()
    var highValue = UILabel()
    
    //Tell that you need to reload the view
    func reloadData(){
        
        if let source = lineGraphDataSource{
            taskValueArray = source.getGraphValueArray()
            selectedPoint  = source.getSelectedRow()
        }
        
        self.setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //Reload the Data
        reloadData()
        
        // Graph Context
        let ctx:CGContext! = UIGraphicsGetCurrentContext()
        
        // Round the borders
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8.0)
        path.addClip()
        
        let deviceColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let desiredGraphSize:CGSize = CGSize(width: self.bounds.size.width * 13/15, height: self.bounds.size.height * 4/5);
        let margin = desiredGraphSize.width * 1/10 as CGFloat
        
        // Saving Context
        ctx.saveGState()
        ctx.scaleBy(x: desiredGraphSize.width, y: desiredGraphSize.height)
        ctx.setShouldAntialias(true)
        
        let colors = [startColor.cgColor, endColor.cgColor]
        
        // extensão da área de transição das cores
        let colorLocations:[CGFloat] = [0.0, 1.0] // standard values
        
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
        ctx.scaleBy(x: desiredGraphSize.width, y: desiredGraphSize.height)
        
        // setting main draw color
        let pencilColor:UIColor = tintColor
        pencilColor.set()
        
        let graphPath = UIBezierPath()
        var circles = [UIBezierPath]()
        
        //Get maximun and minimum values to scale the graph
        var maximumSample:Float = taskValueArray.max() ?? 1.0
        var minimumSample:Float = taskValueArray.min() ?? 0.0
        if maximumSample == minimumSample {
            maximumSample = maximumSample * 1.5
            minimumSample = minimumSample / 1.5
        }
        
        var x: CGFloat = 0
        let count: CGFloat = CGFloat(taskValueArray.count)
        
        //Defining circle size - It will make it always round, even with the "scaleBy" factor
        let circleHeight  : CGFloat = desiredGraphSize.width / circleSizeConstant
        let circleWidth : CGFloat = desiredGraphSize.height / circleSizeConstant
        
        //Creating Graph Line
        for dataPoint in taskValueArray
        {
            // normalize the values
            let normalizedX:CGFloat = x / count
            let normalizedY:CGFloat = 1 - CGFloat( (dataPoint - minimumSample) / (maximumSample - minimumSample))
            
            let point = CGPoint(x: normalizedX + 0.05 , y: normalizedY)
            
            if (x == 0) {
                graphPath.move(to: point)
            }
            
            else
            {
                graphPath.addLine(to: point)
            }
            
            let circle = UIBezierPath(ovalIn: CGRect(x: normalizedX - (circleWidth/2) + 0.05, y: normalizedY - (circleHeight/2), width: circleWidth, height: circleHeight))
            circles.append(circle)
            
            x += 1
        }
        graphPath.lineWidth = 0.01
        
        // Clip the Graph polygon
        let clippingPath = graphPath.copy() as! UIBezierPath
        clippingPath.addLine(to: CGPoint(x: graphPath.currentPoint.x,
                                         y: graphPath.currentPoint.y + margin))
        clippingPath.close()
        ctx.saveGState()
        clippingPath.addClip()
        
        // Draw Gradient
        ctx.drawLinearGradient(gradient!,
                               start: startPoint,
                               end: endPoint,
                               options: .drawsAfterEndLocation)
        
        graphPath.stroke()

        //Draw the circles - that are actualy ellipses
        ctx.restoreGState()
        var counter = 0
        for circle in circles{
            
            if counter == selectedPoint{
                ctx.setFillColor(highlightedColor)
                let highlightedCircle = UIBezierPath(ovalIn: CGRect(x: circle.cgPath.boundingBox.minX - circle.cgPath.boundingBox.width/2,
                                                                                                      y: circle.cgPath.boundingBox.minY - circle.cgPath.boundingBox.height/2,
                                                                                                      width: circle.cgPath.boundingBox.width * 2,
                                                                                                      height: circle.cgPath.boundingBox.height * 2))
                highlightedCircle.fill()
                ctx.setFillColor(tintColor.cgColor)
            } else{
                circle.fill()
            }
            counter += 1
        }

        ctx.restoreGState()
        // Draw Horizontal Lines
        let linePath = UIBezierPath()
        let linesRect = CGRect(origin: CGPoint(x:self.bounds.size.width * 1/20 ,y:margin), size: CGSize(width: self.bounds.size.width * 14/15 , height: desiredGraphSize.height))
        
        // upline
        var y = linesRect.origin.y
        
        linePath.move(to: linesRect.origin)
        linePath.addLine(to: CGPoint(x: linesRect.size.width, y: y))
        
        // bottom line
        y = linesRect.size.height + linesRect.origin.y
        
        linePath.move(to:    CGPoint(x: linesRect.origin.x, y: y))
        linePath.addLine(to: CGPoint(x: linesRect.size.width, y: y))
        
        // center line
        y = (self.bounds.height + margin) / 2
        
        linePath.move(to:    CGPoint(x: linesRect.origin.x, y: y))
        linePath.addLine(to: CGPoint(x: linesRect.size.width, y: y))
        
        let color = pencilColor.withAlphaComponent(0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        //Drawing subtitles
        let middleLabel : String = "\(maximumSample/2)"
        let upLabel : String = "\(maximumSample)"
        let lowLabel : String = "\(minimumSample)"
        
        // Alinhamento do texto
        let textStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = .left
        textStyle.lineBreakMode = .byClipping
        
        // Atritutos da fonte
        let textFontAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12),
            NSForegroundColorAttributeName: pencilColor,
            NSBackgroundColorAttributeName: UIColor.clear,
            NSBaselineOffsetAttributeName: 0,
            NSParagraphStyleAttributeName: textStyle
            ] as [String : Any]
        
        // Calcula o tamanho mínimo para o texto ser exibido
        let textSize:CGSize = middleLabel.size(attributes: textFontAttributes)
        
        // Desenha o texto

        middleLabel.draw(in:  CGRect(x: 5, y: (self.bounds.height / 2.0), width: self.bounds.width, height: self.bounds.height),withAttributes: textFontAttributes)
        upLabel.draw(in: CGRect(x: 5, y: textSize.height, width: self.bounds.width, height: self.bounds.height),withAttributes: textFontAttributes)
        lowLabel.draw(in: CGRect(x: 5, y: (self.bounds.height - textSize.height - 6.0), width: self.bounds.width, height: self.bounds.height),withAttributes: textFontAttributes)
    }
    
}
