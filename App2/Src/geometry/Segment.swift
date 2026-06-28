
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
