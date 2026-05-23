
import SwiftUI



@Observable
class Object: Identifiable {
    
    var id = UUID()
    var name: String
    var pos: CGFloat
    var size: CGFloat
    
    init(name: String, pos: CGFloat, size: CGFloat) {
        self.name = name
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
class Lense: Identifiable {
    
    var id = UUID()
    var name: String
    var pos: CGFloat
    var type: LenseType
    var focalLength: CGFloat
    
    init(name: String, pos: CGFloat, type: LenseType, focalLength: CGFloat) {
        self.name = name
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
class SphericalMirror: Identifiable {
    
    var id = UUID()
    var name: String
    var pos: CGFloat
    var type: MirrorType
    var focalLength: CGFloat
    
    init(name: String, pos: CGFloat, type: MirrorType, focalLength: CGFloat) {
        self.name = name
        self.pos = pos
        self.type = type
        self.focalLength = focalLength
    }
}


@Observable
class Screen: Identifiable {
    
    var id = UUID()
    var name: String
    var pos: CGFloat
    
    init(name: String, pos: CGFloat) {
        self.name = name
        self.pos = pos
    }
}
