
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
            
            let distance = lense.distance(toLocalPoint: mouse.applying(lense.transformToLocal))
            if distance < 5/viewportTransform.scale {
                
                hoverObject = lense
                hoverObjectOffset = Vector(from: lense.position, to: mouse)
                break
            }
        }
    }
    
    
    var bounds: Bounds {
        
        let points = lenses.flatMap { lense in
            lense.pointsForBounds.map { $0.applying(lense.transformFromLocal) }
        }
        
        let bounds = points.reduce(Bounds()) { bounds, p in
            bounds.expanded(to: p)
        }
        
        return bounds
    }
}
