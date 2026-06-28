
import SwiftUI



struct Segment {
    
    let p1: CGPoint
    let p2: CGPoint
    
    func applying(_ transform: CGAffineTransform) -> Segment {
        return Segment(
            p1: p1.applying(transform),
            p2: p2.applying(transform)
        )
    }
}


struct Vector {
    
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
}


func dot(_ v1: Vector, _ v2: Vector) -> CGFloat {
    
    return v1.dx*v2.dx + v1.dy*v2.dy
}


func lengthSq(_ v: Vector) -> CGFloat {
    
    return dot(v,v)
}


func length(_ v: Vector) -> CGFloat {
    
    return sqrt(lengthSq(v))
}


func distance(between p1: CGPoint, and p2: CGPoint) -> CGFloat {
    
    return length(Vector(from: p1, to: p2))
}


func *(_ t: CGFloat, _ v: Vector) -> Vector {
    
    return Vector(dx: v.dx*t, dy: v.dy*t)
}


func +(_ p: CGPoint, _ v: Vector) -> CGPoint {
    
    return CGPoint(x: p.x+v.dx, y: p.y+v.dy)
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
