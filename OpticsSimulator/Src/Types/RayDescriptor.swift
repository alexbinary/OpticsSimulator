
import SwiftUI



struct RayDescriptor {
    
    let deviceBefore: OpticsDevice?
    let deviceAfter: OpticsDevice?
    
    let points: [PointDescriptor]
}


struct PointDescriptor {
    
    let device: OpticsDevice?
    let source: ObjectOrImage?
    let type: PointType
    let point: CGPoint
    
    static func isSame(_ p1: PointDescriptor, _ p2: PointDescriptor) -> Bool {
        
        return p1.device?.id == p2.device?.id
            && p1.source?.id == p2.source?.id
            && p1.type == p2.type
            && p1.point == p2.point
    }
}

enum PointType {
    
    case top
    case center
    case focalPointBefore
    case focalPointAfter
    case undefined
}
