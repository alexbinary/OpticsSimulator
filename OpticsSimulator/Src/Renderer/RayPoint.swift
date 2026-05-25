
import SwiftUI



enum RayType {
    
    case parallel
    case focal
    case center
    case undefined
}

struct RayPoint {
    
    let p: CGPoint
    let sourceDevice: OpticsDevice
    let hasParallelIncidence: Bool
    
    let type: RayType
    let source: ObjectOrImage?
    
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
