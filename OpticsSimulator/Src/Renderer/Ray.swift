
import SwiftUI



struct Ray {
    
    let anchor: CGPoint
    
    let dx: CGFloat
    let dy: CGFloat
    
    
    init(from p1: CGPoint, to p2: CGPoint) {
        
        self.anchor = p1
        self.dx = p2.x - p1.x
        self.dy = p2.y - p1.y
    }
    
    init(horizontalWithAnchorAt anchor: CGPoint) {
        
        self.anchor = anchor
        self.dx = 1
        self.dy = 0
    }
    
    init(angle: CGFloat, anchor: CGPoint) {
        
        self.anchor = anchor
        self.dx = cos(angle)
        self.dy = sin(angle)
    }
    
    
    func point(atX x: CGFloat) -> CGPoint {
        
        let y = anchor.y + dy * (x-anchor.x) / dx
        return CGPoint(x: x, y: y)
    }
}
