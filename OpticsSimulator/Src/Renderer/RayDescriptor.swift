
import SwiftUI



struct RayDescriptor {
    
    let deviceBefore: OpticsDevice?
    let deviceAfter: OpticsDevice?
    let source: ObjectOrImage
    let rayId: UUID
    
    let points: [CGPoint]
}
