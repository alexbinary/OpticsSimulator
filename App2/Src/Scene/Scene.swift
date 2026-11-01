
import SwiftUI



@Observable
class OpticsScene {
    
    
    var lenses: [Lense] = []
    
    var hoveringObject: Lense? = nil
    var hoverObjectOffset: Vector? = nil
    
    
    func add(_ lense: Lense) {
        
        lenses.append(lense)
    }
    
    
    func moveMouse(
        toNewWorldPosition mouse: CGPoint,
        viewportTransform: ViewportTransform
    ) {
        hoveringObject = nil
        hoverObjectOffset = nil
        
        for lense in lenses {
            
            let distance = lense.distance(toLocalPoint: mouse.applying(lense.transformToLocal))
            if distance < 5/viewportTransform.scale {
                
                hoveringObject = lense
                hoverObjectOffset = Vector(from: mouse, to: lense.position)
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



extension OpticsScene {
 
    static var testScene: OpticsScene {
        
        let scene = OpticsScene()
        scene.add(Lense(
            type: .convergent,
            diameter: 100,
            focalLength: 10,
            position: CGPoint(x: 300, y: 300),
            rotation: .degrees(45)
        ))
        return scene
    }
}
