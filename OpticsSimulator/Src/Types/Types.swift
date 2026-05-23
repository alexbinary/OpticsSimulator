
import SwiftUI



@Observable
class ObjectOrImage {
    
    var pos: CGFloat
    var size: CGFloat
    
    init(pos: CGFloat, size: CGFloat) {
        self.pos = pos
        self.size = size
    }
}
    
@Observable
class Object: ObjectOrImage, Identifiable {
    
    var id = UUID()
    var name: String
    
    init(name: String, pos: CGFloat, size: CGFloat) {
        self.name = name
        super.init(pos: pos, size: size)
    }
}

class Image: ObjectOrImage {}


@Observable
class OpticsDevice {
    
    var id = UUID()
    var pos: CGFloat
    var enabled: Bool = true
    
    init(pos: CGFloat) {
        self.pos = pos
    }
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
class Lense: OpticsDevice, Identifiable {
    
    var name: String
    var type: LenseType
    var focalLength: CGFloat
    
    init(name: String, pos: CGFloat, type: LenseType, focalLength: CGFloat) {
        self.name = name
        self.type = type
        self.focalLength = focalLength
        super.init(pos: pos)
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
class SphericalMirror: OpticsDevice, Identifiable {
    
    var name: String
    var type: MirrorType
    var focalLength: CGFloat
    
    init(name: String, pos: CGFloat, type: MirrorType, focalLength: CGFloat) {
        self.name = name
        self.type = type
        self.focalLength = focalLength
        super.init(pos: pos)
    }
}


@Observable
class Screen: OpticsDevice, Identifiable {
    
    var name: String
    
    init(name: String, pos: CGFloat) {
        self.name = name
        super.init(pos: pos)
    }
}


enum RayType {
    
    case parallel
    case focal
    case center
}

struct RayPoint {
    
    let p: CGPoint
    let type: RayType
}
