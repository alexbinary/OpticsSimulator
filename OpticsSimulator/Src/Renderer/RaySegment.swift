
import SwiftUI



struct RaySegment {
    
    let p1: CGPoint
    let p2: CGPoint
    let virtual: Bool
    
    func isVisuallySame(as s: RaySegment) -> Bool {
        
        if self.p1.isVisuallySame(as: s.p1),
           self.p2.isVisuallySame(as: s.p2) {
            return true
        }
        if self.p1.isVisuallySame(as: s.p2),
           self.p2.isVisuallySame(as: s.p1) {
            return true
        }
        return false
    }
    
    func isVisuallyColinear(with s: RaySegment) -> Bool {
        
        let ray = Ray(from: s.p1, to: s.p2)
        
        return (
            ray.point(atX: self.p1.x).isVisuallySame(as: self.p1)
            &&
            ray.point(atX: self.p2.x).isVisuallySame(as: self.p2)
        )
    }
    
    func isOverlapping(with s: RaySegment) -> Bool {
        
        return (
            self.p1.isXBetween(s.p1, and: s.p2)
            ||
            self.p2.isXBetween(s.p1, and: s.p2)
        )
    }
}


extension CGPoint {
    
    func isVisuallySame(as p: CGPoint) -> Bool {
        
        let e = 0.01
        
        return abs(self.x - p.x) < e && abs(self.y - p.y) < e
    }
    
    func isXBetween(_ p1: CGPoint, and p2: CGPoint) -> Bool {
        
        return x > p1.x && x < p2.x
    }
}
