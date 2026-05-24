
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
    
}

enum PointType {
    
    case top
    case center
    case focalPointBefore
    case focalPointAfter
    case undefined
}
