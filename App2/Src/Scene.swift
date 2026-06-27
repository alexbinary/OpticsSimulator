
import SwiftUI



enum LenseType {
    
    case convergent, divergent
}

struct Lense {
    
    var type: LenseType
    var diameter: CGFloat
    var focalLength: CGFloat
    var position: CGPoint
    var rotation: Angle
}



class OpticsScene {
    
    
    var lenses: [Lense] = []
    
    
    func add(_ lense: Lense) {
        
        lenses.append(lense)
    }
    
    
    var boundingRect: CGRect {
        
        let points = lenses.map { lense in
            
            let transform = CGAffineTransform.identity
                .concatenating(.init(
                    translationX: lense.position.x, y: lense.position.y
                ))
                .concatenating(.init(rotationAngle: lense.rotation.radians))
            
            return [
                
                CGPoint(
                    x: 0,
                    y: lense.diameter/2
                ).applying(transform),
                
                CGPoint(
                    x: 0,
                    y: -lense.diameter/2
                ).applying(transform),
                
                CGPoint(
                    x: -lense.focalLength,
                    y: 0
                ).applying(transform),
                
                CGPoint(
                    x: lense.focalLength,
                    y: 0
                ).applying(transform)
            ]
        }
        .flatMap { $0 }
        
        var minX: CGFloat = 0
        var maxX: CGFloat = 0
        var minY: CGFloat = 0
        var maxY: CGFloat = 0
        
        for p in points {
            if p.x < minX {
                minX = p.x
            }
            if p.x > maxX {
                maxX = p.x
            }
            if p.y < minY {
                minY = p.y
            }
            if p.y > maxY {
                maxY = p.y
            }
        }
        
        print(minX)
        print(maxX)
        print(minY)
        print(maxY)
        
        let rect = CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
        
        print(rect.maxX - rect.minX)
        print()
        print(rect.minY)
        print(rect.maxY)
        
        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
}
