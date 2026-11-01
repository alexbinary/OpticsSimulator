
import SwiftUI



func snap(_ n: CGFloat, onClosestMultipleOf s: CGFloat) -> CGFloat {
    
    return round(n/s)*s
}


func snap(_ p: CGPoint, onClosestMultipleOf s: CGFloat) -> CGPoint {
    
    return CGPoint(
        x: snap(p.x, onClosestMultipleOf: s),
        y: snap(p.y, onClosestMultipleOf: s)
    )
}


func snap(_ n: CGFloat, onClosestPowerOf s: CGFloat) -> CGFloat {
    
    return pow(s, ceil(log(n)/log(s)))
}


extension CGFloat {
    
    func isIn(_ range: ClosedRange<CGFloat>) -> Bool {
        
        return range.contains(self)
    }
}
