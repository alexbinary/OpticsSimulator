
import SwiftUI



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
            bounds.expanded(to: p)
        }
        
        return bounds
    }
}



enum LenseType {
    
    case convergent, divergent
}
