
import SwiftUI



func snap(_ n: CGFloat, onMultipleOf ref: CGFloat) -> CGFloat {
    
    return ceil(n/ref)*ref
}


func snap(_ p: CGPoint, onMultipleOf ref: CGFloat) -> CGPoint {
    
    return CGPoint(
        x: snap(p.x, onMultipleOf: ref),
        y: snap(p.y, onMultipleOf: ref)
    )
}


func snap(_ n: CGFloat, onPowerOf ref: CGFloat) -> CGFloat {
    
    return pow(ref, ceil(log(n)/log(ref)))
}


extension CGFloat {
    
    func isIn(_ range: ClosedRange<CGFloat>) -> Bool {
        
        return self >= range.lowerBound && self <= range.upperBound
    }
}
