
import SwiftUI



@Observable
class OpticsScene {
    
    
    var lenses: [Lense] = []
    
    var hoveringObject: Lense? = nil
    var hoveringObjectOffsetFromMouse: Vector? = nil
    
    
    let screenHoverDistanceLimit: CGFloat = 5.0
    
    func worldHoverDistanceLimit(given viewportTransform: ViewportTransform) -> CGFloat {
        screenHoverDistanceLimit/viewportTransform.scale
    }
    
    
    func add(_ lense: Lense) {
        
        lenses.append(lense)
    }
    
    
    func moveMouse(toNewWorldPosition worldMouse: CGPoint, viewportTransform: ViewportTransform) {
        
        hoveringObject = nil
        hoveringObjectOffsetFromMouse = nil
        
        let d = worldHoverDistanceLimit(given: viewportTransform)
        
        for lense in lenses {
            
            if lense.distance(to: worldMouse) < d {
                
                hoveringObject = lense
                hoveringObjectOffsetFromMouse = Vector(from: worldMouse, to: lense.position)
                break
            }
        }
    }
    
    
    var bounds: Bounds? {
        
        let points = lenses.flatMap { $0.worldPointsForBounds }
        
        let bounds = points.reduce(nil as Bounds?, { bounds, p in .expand(bounds, toInclude: p) })
        
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
