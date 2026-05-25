
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
    
    init(horizontalFrom p1: CGPoint) {
        
        self.anchor = p1
        self.dx = 1
        self.dy = 0
    }
    
    
    func point(atX x: CGFloat) -> CGPoint {
        
        let y = anchor.y + dy * (x-anchor.x) / dx
        return CGPoint(x: x, y: y)
    }
}
