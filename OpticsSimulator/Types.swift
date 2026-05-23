
import SwiftUI



@Observable
class Object {
    
    var pos: CGFloat
    var size: CGFloat
    
    init(pos: CGFloat, size: CGFloat) {
        self.pos = pos
        self.size = size
    }
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

@Observable
class Lense {
    
    var pos: CGFloat
    var type: LenseType
    var focalLength: CGFloat
    
    init(pos: CGFloat, type: LenseType, focalLength: CGFloat) {
        self.pos = pos
        self.type = type
        self.focalLength = focalLength
    }
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

@Observable
class SphericalMirror {
    
    var pos: CGFloat
    var type: MirrorType
    var focalLength: CGFloat
    
    init(pos: CGFloat, type: MirrorType, focalLength: CGFloat) {
        self.pos = pos
        self.type = type
        self.focalLength = focalLength
    }
}
