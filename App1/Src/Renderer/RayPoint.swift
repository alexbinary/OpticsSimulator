
import SwiftUI



enum RayType {
    
    case parallel
    case focal
    case center
    case undefined
}

struct RayPoint {
    
    let point: CGPoint
    let rayId: UUID
    let hasParallelIncidence: Bool
    
    init(
        point: CGPoint,
        rayId: UUID,
        horizontalIncidence: Bool = false
    ) {
        self.point = point
        self.rayId = rayId
        self.hasParallelIncidence = horizontalIncidence
    }
}
