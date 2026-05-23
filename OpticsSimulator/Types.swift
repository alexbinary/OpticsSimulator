
import SwiftUI



struct Object {
    
    let pos: CGFloat
    let size: CGFloat
}

struct Image {
    
    let pos: CGFloat
    let size: CGFloat
}

enum LenseType: CaseIterable, Identifiable {
    
    case convergent, divergent
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .convergent: return "Convergent"
        case .divergent: return "Divergent"
        }
    }
}

struct Lense {
    
    let pos: CGFloat
    let type: LenseType
    let focalLength: CGFloat
}

enum MirrorType: CaseIterable, Identifiable {
    
    case convex, concave
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .convex: return "Convex"
        case .concave: return "Concave"
        }
    }
}

struct SphericalMirror {
    
    let pos: CGFloat
    let type: MirrorType
    let focalLength: CGFloat
}
