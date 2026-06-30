
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
            .concatenating(.init(
                rotationAngle: rotation.radians
            ))
            .concatenating(.init(
                translationX: position.x, y: position.y
            ))
    }
    
    var transformToLocal: CGAffineTransform {
        
        CGAffineTransform.identity
            .concatenating(.init(
                translationX: -position.x, y: -position.y
            ))
            .concatenating(.init(
                rotationAngle: -rotation.radians
            ))
    }
    
    func distance(toLocalPoint localPoint: CGPoint) -> CGFloat {
        
        return App2.distance(between: localPoint, and: mainSegment)
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
    }
    
    var pointsForBounds: [CGPoint] {
        
        return [
                
            CGPoint(
                x: 0,
                y: diameter/2
            ),
            CGPoint(
                x: 0,
                y: -diameter/2
            ),
            CGPoint(
                x: -focalLength,
                y: 0
            ),
            CGPoint(
                x: focalLength,
                y: 0
            ),
        ]
    }
}



enum LenseType {
    
    case convergent, divergent
}
