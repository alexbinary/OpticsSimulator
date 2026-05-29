
import SwiftUI



@Observable
class ObjectOrImage {
    
    var id = UUID()
    var pos: CGFloat
    var size: CGFloat
    
    init(pos: CGFloat, size: CGFloat) {
        self.pos = pos
        self.size = size
    }
}
    
@Observable
class Object: ObjectOrImage, Identifiable {
    
    var name: String
    var generatesRight: Bool
    var generatesLeft: Bool
    
    var atInfinity: Bool
    var infinityAngle: CGFloat
    var infinityFacesRight: Bool
    
    var enabled: Bool
    var visible: Bool
    
    init(
        name: String, pos: CGFloat, size: CGFloat,
        generatesRight: Bool = true,
        generatesLeft: Bool = false,
        atInfinity: Bool = false,
        infinityAngle: CGFloat = 0,
        infinityFacesRight: Bool = true,
        enabled: Bool = true, visible: Bool = true
    ) {
        self.name = name
        self.generatesLeft = generatesLeft
        self.generatesRight = generatesRight
        self.atInfinity = atInfinity
        self.infinityAngle = infinityAngle
        self.infinityFacesRight = infinityFacesRight
        self.enabled = enabled
        self.visible = visible
        super.init(pos: pos, size: size)
    }
}

class Image: ObjectOrImage {
    
    var virtual: Bool
    
    init(pos: CGFloat, size: CGFloat, virtual: Bool = false) {
        self.virtual = virtual
        super.init(pos: pos, size: size)
    }
}
