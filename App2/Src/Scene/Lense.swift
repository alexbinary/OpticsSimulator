
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
   
    
    init(
        type: LenseType,
        diameter: CGFloat,
        focalLength: CGFloat,
        position: CGPoint,
        rotation: Angle
    ) {
        self.type = type
        self.diameter = diameter
        self.focalLength = focalLength
        self.position = position
        self.rotation = rotation
    }
    
    
    var localMainSegment: Segment { .init(
        p1: CGPoint(x: 0, y: diameter/2),
        p2: CGPoint(x: 0, y: -diameter/2)
    )}
    
    var localPointsForBounds: [CGPoint] {[
        CGPoint(x: 0, y: diameter/2),
        CGPoint(x: 0, y: -diameter/2),
        CGPoint(x: -focalLength, y: 0),
        CGPoint(x: focalLength, y: 0),
    ]}
    
    var worldPointsForBounds: [CGPoint] {
        localPointsForBounds.map { toWorld($0) }
    }
    
    
    var transformFromLocal: CGAffineTransform {
        .identity
        .concatenating(.init(rotationAngle: rotation.radians))
        .concatenating(.init(translationX: position.x, y: position.y))
    }
    
    func toWorld(_ localPoint: CGPoint) -> CGPoint {
        
        return localPoint.applying(transformFromLocal)
    }
    
    func toWorld(_ localSegment: Segment) -> Segment {
        
        return Segment(
            p1: toWorld(localSegment.p1),
            p2: toWorld(localSegment.p2)
        )
    }
    
    func distance(to worldPoint: CGPoint) -> CGFloat {
        
        return shortestDistance(between: worldPoint, and: toWorld(localMainSegment))
    }
}
