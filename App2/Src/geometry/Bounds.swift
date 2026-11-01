
import SwiftUI



struct Bounds {
    
    let minX: CGFloat
    let maxX: CGFloat
    let minY: CGFloat
    let maxY: CGFloat
    
    
    init(
        minX: CGFloat,
        maxX: CGFloat,
        minY: CGFloat,
        maxY: CGFloat
    ) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
    
    var width: CGFloat { maxX - minX }
    var height: CGFloat { maxY - minY }
    var center: CGPoint { .init(x: (minX + maxX)/2, y: (minY + maxY)/2) }
    
    
    func expanded(toInclude p: CGPoint) -> Bounds {
        
        var minX = minX
        var maxX = maxX
        var minY = minY
        var maxY = maxY
        
        if p.x < minX { minX = p.x }
        if p.x > maxX { maxX = p.x }
        if p.y < minY { minY = p.y }
        if p.y > maxY { maxY = p.y }
        
        return Bounds(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY
        )
    }
    
    
    static func expand(_ bounds: Bounds?, toInclude p: CGPoint) -> Bounds {
        
        if let bounds = bounds {
            return bounds.expanded(toInclude: p)
        } else {
            return Bounds(minX: p.x, maxX: p.x, minY: p.y, maxY: p.y)
        }
    }
}
