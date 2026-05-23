
import SwiftUI



struct Direction {
    
    
    let dx: CGFloat
    let dy: CGFloat
    
    
    init(dx: CGFloat, dy: CGFloat) {
        
        self.dx = dx
        self.dy = dy
    }
    
    init(from p1: CGPoint, to p2: CGPoint) {
        
        self.dx = p2.x - p1.x
        self.dy = p2.y - p1.y
    }
    
    static var horizontal: Direction {
        
        Direction(dx: 1, dy: 0)
    }
    
    
    func point(atX x: CGFloat, startingFrom anchor: CGPoint) -> CGPoint {
        
        let y = anchor.y + dy * (x-anchor.x) / dx
        return CGPoint(x: x, y: y)
    }
}
