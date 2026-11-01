
import SwiftUI



func distance(between p1: CGPoint, and p2: CGPoint) -> CGFloat {
    
    return Vector(from: p1, to: p2).length
}


func shortestDistance(between point: CGPoint, and segment: Segment) -> CGFloat {
    
    let p1p2 = Vector(from: segment.p1, to: segment.p2)
    let p1p = Vector(from: segment.p1, to: point)
    
    let t = dot(p1p, p1p2)/dot(p1p2, p1p2)
    
    if t < 0 {
        return distance(between: point, and: segment.p1)
    } else if t < 1 {
        return distance(between: point, and: segment.p1 + t*p1p2)
    } else {
        return distance(between: point, and: segment.p2)
    }
}
