
import SwiftUI



struct Bounds {
    
    let minX: CGFloat?
    let maxX: CGFloat?
    let minY: CGFloat?
    let maxY: CGFloat?
    
    
    init(
        minX: CGFloat? = nil,
        maxX: CGFloat? = nil,
        minY: CGFloat? = nil,
        maxY: CGFloat? = nil
    ) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
    
    func expanded(to p: CGPoint) -> Bounds {
        
        var minX: CGFloat? = minX
        var maxX: CGFloat? = maxX
        var minY: CGFloat? = minY
        var maxY: CGFloat? = maxY
        
        if minX == nil || p.x < minX! {
            minX = p.x
        }
        if maxX == nil || p.x > maxX! {
            maxX = p.x
        }
        if minY == nil || p.y < minY! {
            minY = p.y
        }
        if maxY == nil || p.y > maxY! {
            maxY = p.y
        }
        
        return Bounds(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY
        )
    }
}
