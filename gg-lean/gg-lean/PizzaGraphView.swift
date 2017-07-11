//
//  PizzaGraphView.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

@IBDesignable class PizzaGraphView: UIView {

    
    fileprivate var taskValueArray: [Float] = [3, 10, 25, 40, 22]
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // defining graphic context
        let ctx:CGContext! = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0.0)
        path.addClip()
        //ctx.setFillColor(UIColor.green.cgColor)
        //path.fill()
        //let deviceColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // o tamanho do gráfico vai ocupar somente uma parte da view pois vamos deixar espaço
        // para escrever um texto. vamos ocupar 4/5
        //let desiredGraphSize:CGSize = CGSize(width: self.bounds.size.width * 13/15, height: self.bounds.size.height * 4/5);
        
        let totalWidth = self.bounds.size.width
        let totalHeight = self.bounds.size.height
        ctx.saveGState()

        var graphPath = UIBezierPath()
        var totalAmount : Float = 0
        
        
        let centerPoint = CGPoint(x: totalWidth / CGFloat(2.0) , y: totalHeight / CGFloat(2.0))
        let radius = totalWidth * 0.4
        
        // Get total sum
        for value in taskValueArray{
            totalAmount += value
        }
        
        var startAngle : CGFloat =  -1*(.pi/2)
        var endAngle  : CGFloat =  -1*(.pi/2)
        
        //Create graph parts
        for value in taskValueArray{
            
            graphPath = UIBezierPath()
            endAngle += CGFloat(value/totalAmount) * (2 * .pi)
            graphPath.addArc(withCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            startAngle = endAngle
            graphPath.addLine(to: centerPoint)
            graphPath.close()
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.setStrokeColor(UIColor(red: 34/255, green: 128/255, blue: 171/255, alpha: 1).cgColor)
            graphPath.fill()
            graphPath.lineWidth = 2.0
            graphPath.stroke()
            
        }
        
        
//        path = UIBezierPath()
//        path.addArc(withCenter: CGPoint(x: 0.6, y:0.6), radius: clockSize, startAngle: .pi/2, endAngle: .pi, clockwise: true)
//        var point = CGPoint(x: 0.6, y:0.6)
//        path.addLine(to: point)
//        path.close()
//        ctx.setFillColor(UIColor.yellow.cgColor)
//        path.fill()

        
    }
    

}
