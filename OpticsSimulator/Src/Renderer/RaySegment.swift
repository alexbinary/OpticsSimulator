
import SwiftUI



struct RaySegment {
    
    let p1: PointDescriptor
    let p2: PointDescriptor
    let virtual: Bool
    
    func isVisuallySame(as s: RaySegment) -> Bool {
        
        if self.p1.point.isVisuallySame(as: s.p1.point),
           self.p2.point.isVisuallySame(as: s.p2.point) {
            return true
        }
        if self.p1.point.isVisuallySame(as: s.p2.point),
           self.p2.point.isVisuallySame(as: s.p1.point) {
            return true
        }
        return false
    }
}


extension CGPoint {
    
    func isVisuallySame(as p: CGPoint) -> Bool {
        
        let e = 0.01
        
        return abs(self.x - p.x) < e && abs(self.y - p.y) < e
    }
}
