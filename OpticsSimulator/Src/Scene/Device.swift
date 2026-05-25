
import SwiftUI



@Observable
class OpticsDevice {
    
    var id = UUID()
    var pos: CGFloat
    var enabled: Bool
    var visible: Bool
    
    init(pos: CGFloat, enabled: Bool = true, visible: Bool = true) {
        self.pos = pos
        self.enabled = enabled
        self.visible = visible
    }
}

enum LenseType: CaseIterable, Identifiable, Codable {
    
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
    
    var generatesParallelRay: Bool = false
    var generatesCenterRay: Bool = true
    var generatesFocalRay: Bool = true
    
    var retroPropagatesRays: Bool = false
    
    init(
        name: String, pos: CGFloat, type: LenseType, focalLength: CGFloat,
        generatesParallelRay: Bool = false,
        generatesCenterRay: Bool = true,
        generatesFocalRay: Bool = true,
        retroPropagatesRays: Bool = false,
        enabled: Bool = true, visible: Bool = true
    ) {
        self.name = name
        self.type = type
        self.focalLength = focalLength
        
        self.generatesParallelRay = generatesParallelRay
        self.generatesCenterRay = generatesCenterRay
        self.generatesFocalRay = generatesFocalRay
        self.retroPropagatesRays = retroPropagatesRays
        
        super.init(pos: pos, enabled: enabled, visible: visible)
    }
}

enum MirrorType: CaseIterable, Identifiable, Codable {
    
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
    
    init(
        name: String, pos: CGFloat, type: MirrorType, focalLength: CGFloat,
        enabled: Bool = true, visible: Bool = true
    ) {
        self.name = name
        self.type = type
        self.focalLength = focalLength
        super.init(pos: pos, enabled: enabled, visible: visible)
    }
}


@Observable
class Screen: OpticsDevice, Identifiable {
    
    var name: String
    
    init(
        name: String, pos: CGFloat,
        enabled: Bool = true, visible: Bool = true
    ) {
        self.name = name
        super.init(pos: pos, enabled: enabled, visible: visible)
    }
}
