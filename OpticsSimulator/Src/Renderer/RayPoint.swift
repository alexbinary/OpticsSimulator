
import SwiftUI



enum RayType {
    
    case parallel
    case focal
    case center
    case undefined
}

struct RayPoint {
    
    let point: CGPoint
    let hasParallelIncidence: Bool
    
    init(
        point: CGPoint,
        horizontalIncidence: Bool = false
    ) {
        self.point = point
        self.hasParallelIncidence = horizontalIncidence
    }
}
