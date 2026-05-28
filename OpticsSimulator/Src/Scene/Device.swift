
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
    
    var generatesParallelRay: Bool
    var generatesCenterRay: Bool
    var generatesFocalRay: Bool
    
    var retroPropagatesRays: Bool
    
    init(
        name: String, pos: CGFloat, type: LenseType, focalLength: CGFloat,
        generatesParallelRay: Bool = true,
        generatesCenterRay: Bool = true,
        generatesFocalRay: Bool = true,
        retroPropagatesRays: Bool = true,
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
    
    case plane, convex, concave
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .plane: return "Plan"
        case .convex: return "Convex"
        case .concave: return "Concave"
        }
    }
}

@Observable
class Mirror: OpticsDevice, Identifiable {
    
    var name: String
    var type: MirrorType
    var focalLength: CGFloat
    var facesLeft: Bool
    
    var generatesParallelRay: Bool
    var generatesCenterRay: Bool
    var generatesFocalRay: Bool
    var generatesCurveCenterRay: Bool
    
    init(
        name: String, pos: CGFloat, type: MirrorType, focalLength: CGFloat,
        facesLeft: Bool,
        generatesParallelRay: Bool = true,
        generatesCenterRay: Bool = true,
        generatesFocalRay: Bool = true,
        generatesCurveCenterRay: Bool = true,
        enabled: Bool = true, visible: Bool = true
    ) {
        self.name = name
        self.type = type
        self.focalLength = focalLength
        self.facesLeft = facesLeft
        
        self.generatesParallelRay = generatesParallelRay
        self.generatesCenterRay = generatesCenterRay
        self.generatesFocalRay = generatesFocalRay
        self.generatesCurveCenterRay = generatesCurveCenterRay
        
        super.init(pos: pos, enabled: enabled, visible: visible)
    }
}


@Observable
class Screen: OpticsDevice, Identifiable {
    
    var name: String
    var facesLeft: Bool
    
    init(
        name: String, pos: CGFloat, facesLeft: Bool,
        enabled: Bool = true, visible: Bool = true
    ) {
        self.name = name
        self.facesLeft = facesLeft
        super.init(pos: pos, enabled: enabled, visible: visible)
    }
}
