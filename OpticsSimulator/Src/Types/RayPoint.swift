
import SwiftUI



enum RayType {
    
    case parallel
    case focal
    case center
}

struct RayPoint {
    
    let p: CGPoint
    let type: RayType
    let firstDevice: OpticsDevice?
    let source: ObjectOrImage?
    
    init(
        p: CGPoint, type: RayType,
        firstDevice: OpticsDevice? = nil, source: ObjectOrImage? = nil
    ) {
        self.p = p
        self.type = type
        self.firstDevice = firstDevice
        self.source = source
    }
}
