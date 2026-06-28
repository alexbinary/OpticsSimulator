
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
    
    var boundingRect: CGRect {
        
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
        
        var minX: CGFloat = position.x
        var maxX: CGFloat = position.y
        var minY: CGFloat = position.x
        var maxY: CGFloat = position.y
        
        for p in points {
            if p.x < minX {
                minX = p.x
            }
            if p.x > maxX {
                maxX = p.x
            }
            if p.y < minY {
                minY = p.y
            }
            if p.y > maxY {
                maxY = p.y
            }
        }
        
        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
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
    
    
    var boundingRect: CGRect {
        
        return lenses.first!.boundingRect
    }
}
