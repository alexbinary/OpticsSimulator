
import SwiftUI



@Observable
class OpticsScene {
    
    
    var lenses: [Lense] = []
    var hoveringLense: Lense? = nil
    
    
    func add(_ lense: Lense) {
        
        lenses.append(lense)
    }
    
    
    func updateMouse(
        newTransformedPosition mouse: CGPoint,
        viewportTransform: ViewportTransform
    ) {
        hoveringLense = nil
        
        for lense in lenses {
            
            if let distance = distance(between: mouse, and: lense.mainSegment),
               distance < 5/viewportTransform.scale {
                
                hoveringLense = lense
                break
            }
        }
    }
    
    
    var bounds: Bounds {
        
        return lenses.first!.bounds
    }
}
