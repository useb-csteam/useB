//
//  OcrGuideLayer.swift
//  @MachineEyeSDK
//


import UIKit

class OcrGuideLayer: CALayer {
    private var defaultOverlay: CAShapeLayer = CAShapeLayer()
    private var subOverlay: CAShapeLayer = CAShapeLayer()
    private var guideRect: CGRect = CGRect.zero
    
    func addLayer(layer: CALayer) {
        layer.addSublayer(defaultOverlay)
        layer.addSublayer(subOverlay)
    }
    
    func layerLayout(rect: CGRect) {
        defaultOverlay.frame = rect
    }
    
    func configureGuideLayer(guideRect: CGRect) {
        self.guideRect = guideRect
    }
    
    func changeGuideLayerState(state: Int) {
        
        let guideBox = UIBezierPath(roundedRect: guideRect, cornerRadius: 20.0)
        let boundBox = UIBezierPath(rect: defaultOverlay.bounds)
        boundBox.append(guideBox)
        boundBox.usesEvenOddFillRule = true
        
        var guideRect2: CGRect = guideRect
        guideRect2.size.width = guideRect2.size.width/2;
        guideRect2.size.height = guideRect2.size.height/2;
        
        let guideBox2 = UIBezierPath()
        
        //
        var length: CGFloat = 30.0
        var margin:CGFloat = 0.0
        
        let left    = self.guideRect.origin.x + margin;
        let right   = self.guideRect.origin.x + self.guideRect.size.width - margin;
        let top     = self.guideRect.origin.y + margin;
        let bottom  = self.guideRect.origin.y + self.guideRect.size.height - margin;

        // left top
        guideBox2.move(to: CGPoint(x: left, y: top + length))
        guideBox2.addQuadCurve(to: CGPoint(x: left+length,  y: top), controlPoint: CGPoint(x: left, y: top))
        
        // right top
        guideBox2.move(to: CGPoint(x: right, y: top + length))
        guideBox2.addQuadCurve(to: CGPoint(x: right-length,  y: top), controlPoint: CGPoint(x: right, y: top))
        
        // left bottom
        guideBox2.move(to: CGPoint(x: left, y: bottom - length))
        guideBox2.addQuadCurve(to: CGPoint(x: left+length,  y: bottom), controlPoint: CGPoint(x: left, y: bottom))
        
        // right bottom
        guideBox2.move(to: CGPoint(x: right, y: bottom - length))
        guideBox2.addQuadCurve(to: CGPoint(x: right-length,  y: bottom), controlPoint: CGPoint(x: right, y: bottom))
        
        //let subOverlay: CAShapeLayer = CAShapeLayer()
        subOverlay.path = guideBox2.cgPath
        subOverlay.lineWidth = 10
        subOverlay.fillColor = UIColor(white: 0.0, alpha: 0.0).cgColor
        subOverlay.strokeColor = UIColor(red: 0x8b/0xff, green: 0.0, blue: 0xff/0xff, alpha: 1.0).cgColor
        
        //defaultOverlay.addSublayer(subOverlay)
        
        defaultOverlay.path = boundBox.cgPath
        
        if state == 0 {
            defaultOverlay.fillColor = UIColor(white: 1, alpha: 0.2).cgColor
        } else if state == 1 {
            defaultOverlay.fillColor = UIColor(white: 0.0, alpha: 0.4).cgColor
        }
        
        defaultOverlay.fillRule = CAShapeLayerFillRule.evenOdd
        
        defaultOverlay.strokeColor = UIColor(white: 1.0, alpha: 0.7).cgColor
        defaultOverlay.lineWidth = 4.0
    }
}
