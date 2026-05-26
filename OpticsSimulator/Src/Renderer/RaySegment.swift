
import SwiftUI



struct RaySegment {
    
    let id = UUID()
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
    
    func isVisuallyOverlapping(with s: RaySegment) -> Bool {
        
        if self.isVisuallyColinear(with: s) {
            
            return (
                self.p1.isXStrictlyBetween(s.p1, and: s.p2)
                ||
                self.p2.isXStrictlyBetween(s.p1, and: s.p2)
                ||
                s.p1.isXStrictlyBetween(self.p1, and: self.p2)
                ||
                s.p2.isXStrictlyBetween(self.p1, and: self.p2)
            )
        }
        
        return false
    }
    
    func overlappingSubSegments(with s: RaySegment) -> [SubSegment] {
        
        let s1 = self
        let s2 = s
        
        var segments: [SubSegment] = []
        
        if s1.p1.x < s2.p1.x {
            
            segments.append(SubSegment(
                p1: s1.p1, p2: s2.p1,
                originalSegments: [s1]
            ))
            
            if s1.p2.x < s2.p2.x {
            
                segments.append(SubSegment(
                    p1: s2.p1, p2: s1.p2,
                    originalSegments: [s1, s2]
                ))
                
                segments.append(SubSegment(
                    p1: s1.p2, p2: s2.p2,
                    originalSegments: [s2]
                ))
                
            } else {
                
                segments.append(SubSegment(
                    p1: s2.p1, p2: s2.p2,
                    originalSegments: [s1, s2]
                ))
                
                segments.append(SubSegment(
                    p1: s2.p2, p2: s1.p2,
                    originalSegments: [s1]
                ))
            }
            
        } else {
            
            segments.append(SubSegment(
                p1: s2.p1, p2: s1.p1,
                originalSegments: [s2]
            ))
            
            if s1.p2.x < s2.p2.x {
            
                segments.append(SubSegment(
                    p1: s1.p1, p2: s1.p2,
                    originalSegments: [s1, s2]
                ))
                
                segments.append(SubSegment(
                    p1: s1.p2, p2: s2.p2,
                    originalSegments: [s2]
                ))
                
            } else {
                
                segments.append(SubSegment(
                    p1: s1.p1, p2: s2.p2,
                    originalSegments: [s1, s2]
                ))
                
                segments.append(SubSegment(
                    p1: s2.p2, p2: s1.p2,
                    originalSegments: [s1]
                ))
            }
        }
        
        return segments
    }
}


struct SubSegment {
    
    let p1: CGPoint
    let p2: CGPoint
    
    let originalSegments: [RaySegment]
}


extension CGPoint {
    
    func isVisuallySame(as p: CGPoint) -> Bool {
        
        let e = 0.01
        
        return abs(self.x - p.x) < e && abs(self.y - p.y) < e
    }
    
    func isVisuallyDistinct(from p: CGPoint) -> Bool {
        
        return !self.isVisuallySame(as: p)
    }
    
    func isXStrictlyBetween(_ p1: CGPoint, and p2: CGPoint) -> Bool {
        
        return x > p1.x && x < p2.x
    }
}
