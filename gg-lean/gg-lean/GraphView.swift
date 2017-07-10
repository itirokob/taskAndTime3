//
//  GraphView.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

let circleSizeConstant : CGFloat = 8000

/// Create a line Graph based on a series of points
@IBDesignable class GraphView: UIView {
    
    //Designable Variables
    @IBInspectable var startColor : UIColor = .clear
    @IBInspectable var endColor   : UIColor = .white
    
    fileprivate var taskNameArray: [String]  = ["Red", "Study", "Play", "Orange", "Mario", "Flower", "WubaLub", "Dragon", "Zagreb", "Nunavut", "Heikjavik"]
    fileprivate var taskValueArray: [Float] = [    10,       20,         45,       72,          133,         8,              14,               27,             32,            90,             58]
    
    //Tell that you need to reload the view
    func reloadData(){
        self.setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // contexto gráfico
        let ctx:CGContext! = UIGraphicsGetCurrentContext()
        
        // Queremos cantos arredondados com raio 8.0
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8.0)
        
        // Modifica a área de desenho do contexto atual deixando desenhável
        // apenas a área definida pelo path
        path.addClip()
        
        // espaço de cores RGB
        let deviceColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // o tamanho do gráfico vai ocupar somente uma parte da view pois vamos deixar espaço
        // para escrever um texto. vamos ocupar 4/5
        let desiredGraphSize:CGSize = CGSize(width: self.bounds.size.width * 13/15, height: self.bounds.size.height * 4/5);
        
        // e deixar 1/5 para as duas margens, ou seja cada margens será 1/10
        let margin = desiredGraphSize.width * 1/10 as CGFloat
        
        // Salva o Contexto inicial
        ctx.saveGState()
        
        // Escala o contexto para o tamanho desejado
        ctx.scaleBy(x: desiredGraphSize.width, y: desiredGraphSize.height)
        
        // Desenhar sem serrilhado
        ctx.setShouldAntialias(true)
        
        // Para iniciar o desenho devemos sempre começar pelo fundo e ir
        // desenhando os elementos um por cima do outro
        
        // Cores para desenho do gradiente para o fundo
        let colors = [startColor.cgColor, endColor.cgColor]
        
        // extensão da área de transição das cores
        let colorLocations:[CGFloat] = [0.0, 1.0] // valores padrão
        
        // Cria o gradiente
        let gradient = CGGradient(colorsSpace: deviceColorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        
        // Desenha o gradiente
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y: 1)
        ctx?.drawLinearGradient(gradient!,
                                start: startPoint,
                                end: endPoint,
                                options: .drawsAfterEndLocation)
        
        // Restaura o contexto para o mesmo estado inicial
        ctx.restoreGState()
        
        // Salva novamente
        ctx.saveGState()
        
        // Translada a margem em x e em y
        ctx.translateBy(x: margin, y: margin)
        
        // Mesmo que antes, porém precisa ser refeito porque o contexto foi restaurado
        // para um estado anterior a essa modificação
        ctx.scaleBy(x: desiredGraphSize.width, y: desiredGraphSize.height)
        
        // cor principal para desenho
        let pencilColor:UIColor = tintColor
        
        // define no contexto atual uma cor para ser usada no desenho
        pencilColor.set()
        
        // Define que vamos desenhar uma linha com um Path ou seja ponto a ponto
        let graphPath = UIBezierPath()
        
        var circles = [UIBezierPath]()
        
        // Aqui buscamos o ponto de mínimo e de máximo do gráfico
        // pois vamos normalizar os valores para o gráfico inteiro
        // ser exibido dentro da view
        let maximumSample:Float = taskValueArray.max() ?? 1.0
        let minimumSample:Float = taskValueArray.min() ?? 0.0
        
        var x: CGFloat = 0
        let count: CGFloat = CGFloat(taskValueArray.count)
        
        //Defining circle size - It will make it always round, even with the "scaleBy" factor
        let circleHeight  : CGFloat = desiredGraphSize.width / circleSizeConstant
        let circleWidth : CGFloat = desiredGraphSize.height / circleSizeConstant
        
        for dataPoint in taskValueArray
        {
            // normaliza os valores entre 0 e 1
            let normalizedX:CGFloat = x / count
            let normalizedY:CGFloat = 1 - CGFloat( (dataPoint - minimumSample) / (maximumSample - minimumSample))
            
            let point = CGPoint(x: normalizedX, y: normalizedY)
            if (x == 0) {
                // para o primeiro ponto de todos apenas vamos definir a posição inicial
                graphPath.move(to: point)
            } else
            {
                // Para os demais pontos será desenhado uma linha
                graphPath.addLine(to: point)
            }
            
            // cria um circulo para ser colocado no ponto
            let circle = UIBezierPath(ovalIn: CGRect(x: normalizedX - (circleWidth/2), y: normalizedY - (circleHeight/2), width: circleWidth, height: circleHeight))
            
            // guarda em um array pois queremos que eles sejam uma das ultimas coisas
            // a serem colocadas
            circles.append(circle)
            
            x += 1
        }
        
        // espessura da linha
        graphPath.lineWidth = 0.01
        
        // vamos criar um gradiente abaixo da linha do gráfico
        let clippingPath = graphPath.copy() as! UIBezierPath
        
        // adicionamos uma linha para baixo
        clippingPath.addLine(to: CGPoint(x: graphPath.currentPoint.x,
                                         y: graphPath.currentPoint.y + margin))
        
        // fechamos o poligono
        clippingPath.close()
        
        // salva o contexto antes de fazer o clipping
        ctx.saveGState()
        
        // faz o clip
        clippingPath.addClip()
        
        // desenha o gradiente apenas na região que o clip definiu
        ctx.drawLinearGradient(gradient!,
                               start: startPoint,
                               end: endPoint,
                               options: .drawsAfterEndLocation)
        
        // desenha o a linha em todos os pontos
        graphPath.stroke()
        
        // restaura o contexto pois não queremos que a região de clip
        // afete o desenho dos circulos
        ctx.restoreGState()
        
        // desenha os circulos
        for circle in circles{
            circle.fill()
        }
        
        // restaura o contexto inicial
        ctx.restoreGState()
        
//        if self.title != nil
//        {
//            // Alinhamento do texto
//            let textStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//            textStyle.alignment = .right
//            textStyle.lineBreakMode = .byClipping
//            
//            // Atritutos da fonte
//            let textFontAttributes = [
//                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
//                NSForegroundColorAttributeName: pencilColor,
//                NSBackgroundColorAttributeName: UIColor.clear,
//                NSBaselineOffsetAttributeName: 0,
//                NSParagraphStyleAttributeName: textStyle
//                ] as [String : Any]
//            
//            // Calcula o tamanho mínimo para o texto ser exibido
//            let textSize:CGSize = title.size(attributes: textFontAttributes)
//            
//            // Desenha o texto
//            title.draw(in: self.bounds.insetBy(dx: 10, dy: (self.bounds.height - textSize.height) / 2),withAttributes: textFontAttributes)
//        }
        
        
        // Desenha linhas horizontais
        let linePath = UIBezierPath()
        
        let linesRect = CGRect(origin: CGPoint(x:margin,y:margin), size: desiredGraphSize)
        
        // linha do topo
        var y = linesRect.origin.y
        
        linePath.move(to: linesRect.origin)
        linePath.addLine(to: CGPoint(x: linesRect.size.width, y: y))
        
        // linha da base
        y = linesRect.size.height + linesRect.origin.y
        
        linePath.move(to:    CGPoint(x: linesRect.origin.x, y: y))
        linePath.addLine(to: CGPoint(x: linesRect.size.width, y: y))
        
        // linha do centro
        y = (self.bounds.height + margin) / 2
        
        linePath.move(to:    CGPoint(x: linesRect.origin.x, y: y))
        linePath.addLine(to: CGPoint(x: linesRect.size.width, y: y))
        
        // cor de desenho das linhas cor pencil com 30% de transparência
        let color = pencilColor.withAlphaComponent(0.3)
        
        // seta a cor no contexto corrente
        color.setStroke()
        
        // seta a espessura da linha
        linePath.lineWidth = 1.0
        
        // desenha o path das linhas
        linePath.stroke()
        
    }
    

    
}
