
import SwiftUI



enum LenseType {
    
    case convergent, divergent
}


@Observable
class Lense {
    
    var type: LenseType
    var diameter: CGFloat
    var focalLength: CGFloat
    var position: CGPoint
    var rotation: Angle
    
    init(type: LenseType, diameter: CGFloat, focalLength: CGFloat, position: CGPoint, rotation: Angle) {
        self.type = type
        self.diameter = diameter
        self.focalLength = focalLength
        self.position = position
        self.rotation = rotation
    }
    
    var transformFromLocal: CGAffineTransform {
        
        CGAffineTransform.identity
            .concatenating(.init(rotationAngle: rotation.radians))
            .concatenating(.init(
                translationX: position.x, y: position.y
            ))
    }
    
    var mainSegment: Segment {
        
        Segment(
            p1: CGPoint(
                x: 0,
                y: diameter/2
            ),
            p2: CGPoint(
                x: 0,
                y: -diameter/2
            )
        )
        .applying(transformFromLocal)
    }
    
    var bounds: Bounds {
        
        let points = [
                
            CGPoint(
                x: 0,
                y: diameter/2
            ).applying(transformFromLocal),
            
            CGPoint(
                x: 0,
                y: -diameter/2
            ).applying(transformFromLocal),
            
            CGPoint(
                x: -focalLength,
                y: 0
            ).applying(transformFromLocal),
            
            CGPoint(
                x: focalLength,
                y: 0
            ).applying(transformFromLocal)
        ]
        
        let bounds = points.reduce(Bounds()) { bounds, p in
            bounds.including(p)
        }
        
        return bounds
    }
}



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
    
    func including(_ p: CGPoint) -> Bounds {
        
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



@Observable
class OpticsScene {
    
    
    var lenses: [Lense] = []
    var hoveringLense: Lense? = nil
    
    
    func add(_ lense: Lense) {
        
        lenses.append(lense)
    }
    
    
    func updateMouse(
        newTransformedPosition mouse: CGPoint,
        viewportTransform: ViewportTransform
    ) {
        hoveringLense = nil
        
        for lense in lenses {
            
            if let distance = distance(between: mouse, and: lense.mainSegment),
               distance < 5/viewportTransform.scale {
                
                hoveringLense = lense
                break
            }
        }
    }
    
    
    var bounds: Bounds {
        
        return lenses.first!.bounds
    }
}
