
import SwiftUI



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
    
    
    static let zero = Vector(dx: 0, dy: 0)
    
    
    func applying(_ transform: CGAffineTransform) -> Vector {
        
        let p = CGPoint(x: dx, y: dy).applying(transform)
        return Vector(dx: p.x, dy: p.y)
    }
}



func +(_ v1: Vector, _ v2: Vector) -> Vector {
 
    return Vector(dx: v1.dx + v2.dx, dy: v1.dy + v2.dy)
}


func +=(_ v1: inout Vector, _ v2: Vector) {
 
    v1 = v1 + v2
}


func *(_ t: CGFloat, _ v: Vector) -> Vector {
    
    return Vector(dx: v.dx*t, dy: v.dy*t)
}


func +(_ p: CGPoint, _ v: Vector) -> CGPoint {
    
    return CGPoint(x: p.x+v.dx, y: p.y+v.dy)
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
