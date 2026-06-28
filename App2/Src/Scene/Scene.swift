
import SwiftUI



@Observable
class OpticsScene {
    
    
    var lenses: [Lense] = []
    
    var hoverObject: Lense? = nil
    var hoverObjectOffset: Vector? = nil
    
    
    func add(_ lense: Lense) {
        
        lenses.append(lense)
    }
    
    
    func updateMouse(
        newTransformedPosition mouse: CGPoint,
        viewportTransform: ViewportTransform
    ) {
        hoverObject = nil
        hoverObjectOffset = nil
        
        for lense in lenses {
            
            if let distance = distance(between: mouse, and: lense.mainSegment),
               distance < 5/viewportTransform.scale {
                
                hoverObject = lense
                hoverObjectOffset = Vector(from: lense.position, to: mouse)
                break
            }
        }
    }
    
    
    var bounds: Bounds {
        
        return lenses.first!.bounds
    }
}
