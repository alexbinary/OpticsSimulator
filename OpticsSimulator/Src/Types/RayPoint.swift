
import SwiftUI



enum RayType {
    
    case parallel
    case focal
    case center
}

struct RayPoint {
    
    let p: CGPoint
    let type: RayType
    let sourceDevice: OpticsDevice
    let source: ObjectOrImage?
    let hasParallelIncidence: Bool
    
    init(
        p: CGPoint, type: RayType,
        sourceDevice: OpticsDevice, source: ObjectOrImage? = nil,
        horizontalIncidence: Bool = false
    ) {
        self.p = p
        self.type = type
        self.sourceDevice = sourceDevice
        self.source = source
        self.hasParallelIncidence = horizontalIncidence
    }
}
