
import SwiftUI



func distance(between p1: CGPoint, and p2: CGPoint) -> CGFloat {
    
    return length(Vector(from: p1, to: p2))
}


func project(_ p: CGPoint, onto segment: Segment) -> CGPoint? {
    
    let p1p2 = Vector(from: segment.p1, to: segment.p2)
    let p1p = Vector(from: segment.p1, to: p)
    
    let t = dot(p1p, p1p2)/dot(p1p2, p1p2)
    
    if t.isIn(0...1) {
        return segment.p1 + t*p1p2
    } else {
        return nil
    }
}


func distance(between p: CGPoint, and segment: Segment) -> CGFloat? {
    
    if let projected = project(p, onto: segment) {
        return distance(between: p, and: projected)
    } else {
        return nil
    }
}
