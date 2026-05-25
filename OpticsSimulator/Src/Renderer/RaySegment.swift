
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
}


extension CGPoint {
    
    func isVisuallySame(as p: CGPoint) -> Bool {
        
        let e = 0.01
        
        return abs(self.x - p.x) < e && abs(self.y - p.y) < e
    }
}
