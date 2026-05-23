
import SwiftUI



struct Renderer {
    
    let context: GraphicsContext
    let size: CGSize

    func drawAxis() {
        
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        
        context.stroke(path, with: .color(.gray), lineWidth: 1)
    }
    
    func pathForArrow(at h: CGFloat, pointing direction: ArrowDirection) -> Path {
        
        let a: CGFloat = 5
        let d: CGFloat = direction == .towardAxis ? +1 : -1
        
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: a, y: a))
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: -a, y: a))
        
        return path.applying(
            .init(scaleX: 1, y: h > 0 ? -d : +d)
            .concatenating(.init(translationX: 0, y: h))
        )
    }
    
    func draw(_ object: Object) {
        
        drawObjectOrImage(
            at: rendererPos(from: object.pos),
            size: rendererObjectSize(from: object.size),
            color: .blue
        )
    }
    
    func draw(_ image: Image) {
        
        drawObjectOrImage(
            at: rendererPos(from: image.pos),
            size: rendererObjectSize(from: image.size),
            color: .green
        )
    }
        
    func drawObjectOrImage(at position: CGFloat, size: CGFloat, color: Color) {
        
        let x = position
        let h = size
        
        let lineWidth: CGFloat = 2
        
        var path = Path()
        
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: h))
        
        path.addPath(pathForArrow(at: h, pointing: .towardAxis),
                     transform: .init(translationX: position, y: 0))
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth)
    }
    
    func draw(_ lense: Lense) {
        
        let x = rendererPos(from: lense.pos)
        let h = size.height/2*0.9
        
        let f = rendererFocalLength(from: lense.focalLength)
        let m: CGFloat = 5
        
        let arrowDir: ArrowDirection = lense.type == .convergent ? .towardAxis : .awayFromAxis
        
        var path = Path()
        
        // lense body
        path.move(to: CGPoint(x: x, y: h))
        path.addLine(to: CGPoint(x: x, y: -h))
        
        // arrows
        path.addPath(pathForArrow(at: h, pointing: arrowDir),
                     transform: .init(translationX: x, y: 0))
        path.addPath(pathForArrow(at: -h, pointing: arrowDir),
                     transform: .init(translationX: x, y: 0))
        
        // focal indicator before
        path.move(to: CGPoint(x: x-f, y: -m))
        path.addLine(to: CGPoint(x: x-f, y: +m))
        
        // focal indicator after
        path.move(to: CGPoint(x: x+f, y: -m))
        path.addLine(to: CGPoint(x: x+f, y: +m))
        
        context.stroke(path, with: .color(.red), lineWidth: 2)
    }
    
    func draw(_ mirror: SphericalMirror) {
        
        let x = rendererPos(from: mirror.pos)
        let h = size.height/2*0.8
        
        let f = rendererFocalLength(from: mirror.focalLength)
        let m: CGFloat = 5
        
        let a: CGFloat = 5
        
        var path = Path()
        
        // mirror body
        path.move(to: CGPoint(x: x, y: h))
        path.addLine(to: CGPoint(x: x, y: -h))
        
        if mirror.type == .concave {
            
            path.move(to: CGPoint(x: x-2*a, y: h+2*a))
            path.addLine(to: CGPoint(x: x, y: h))
            
            path.move(to: CGPoint(x: x, y: -h))
            path.addLine(to: CGPoint(x: x-2*a, y: -h-2*a))
            
        } else {
            
            path.move(to: CGPoint(x: x, y: h))
            path.addLine(to: CGPoint(x: x+2*a, y: h+2*a))
            
            path.move(to: CGPoint(x: x, y: -h))
            path.addLine(to: CGPoint(x: x+2*a, y: -h-2*a))
        }
        
        let n = 15
        for i in 0...n {
            
            let hi: CGFloat = -h + CGFloat(i)*2*h/CGFloat(n)
            
            path.move(to: CGPoint(x: x, y: hi))
            path.addLine(to: CGPoint(x: x+a, y: hi-a))
        }
        
        if mirror.type == .concave {
            
            // focal indicator
            path.move(to: CGPoint(x: x-f, y: -m))
            path.addLine(to: CGPoint(x: x-f, y: +m))
            
            // center indicator
            path.move(to: CGPoint(x: x-2*f, y: -m))
            path.addLine(to: CGPoint(x: x-2*f, y: +m))
            
        } else {
            
            // focal indicator
            path.move(to: CGPoint(x: x+f, y: -m))
            path.addLine(to: CGPoint(x: x+f, y: +m))
            
            // center indicator
            path.move(to: CGPoint(x: x+2*f, y: -m))
            path.addLine(to: CGPoint(x: x+2*f, y: +m))
        }
        
        context.stroke(path, with: .color(.red), lineWidth: 2)
    }
    
    func drawRays(for object: Object, _ lense: Lense, _ image: Image) {
        
        let objectPos = rendererPos(from: object.pos)
        let objectSize = rendererObjectSize(from: object.size)
        
        let imagePos = rendererPos(from: image.pos)
        let imageSize = rendererObjectSize(from: image.size)
        
        let lensePos = rendererPos(from: lense.pos)
        let lenseF = rendererFocalLength(from: lense.focalLength)
        
        var path = Path()
        
        // parallel ray object > lense
        path.move(to: CGPoint(x: objectPos, y: objectSize))
        path.addLine(to: CGPoint(x: lensePos, y: objectSize))
        
        // parallel ray lense > F
        if lense.type == .convergent {
            path.move(to: CGPoint(x: lensePos, y: objectSize))
            path.addLine(to: CGPoint(x: lensePos+lenseF, y: 0))
        } else {
            path.move(to: CGPoint(x: lensePos, y: objectSize))
            path.addLine(to: CGPoint(x: lensePos-lenseF, y: 0))
        }
        
        // parallel ray F > image
        if lense.type == .convergent {
            path.move(to: CGPoint(x: lensePos+lenseF, y: 0))
            path.addLine(to: CGPoint(x: imagePos, y: imageSize))
        }
        
        // center ray object > O
        path.move(to: CGPoint(x: objectPos, y: objectSize))
        path.addLine(to: CGPoint(x: lensePos, y: 0))
        
        // center ray O > image
        if lense.type == .convergent {
            path.move(to: CGPoint(x: lensePos, y: 0))
            path.addLine(to: CGPoint(x: imagePos, y: imageSize))
        }
        
        context.stroke(path, with: .color(.yellow), lineWidth: 1)
    }
    
    func drawRays(for object: Object, _ mirror: SphericalMirror, _ image: Image) {
        
        let objectPos = rendererPos(from: object.pos)
        let objectSize = rendererObjectSize(from: object.size)
        
        let imagePos = rendererPos(from: image.pos)
        let imageSize = rendererObjectSize(from: image.size)
        
        let mirrorPos = rendererPos(from: mirror.pos)
        let mirrorF = rendererFocalLength(from: mirror.focalLength)
        
        var path = Path()
        
        // parallel ray object > mirror
        path.move(to: CGPoint(x: objectPos, y: objectSize))
        path.addLine(to: CGPoint(x: mirrorPos, y: objectSize))
        
        // parallel ray mirror > F
        if mirror.type == .concave {
            path.move(to: CGPoint(x: mirrorPos, y: objectSize))
            path.addLine(to: CGPoint(x: mirrorPos-mirrorF, y: 0))
        } else {
            path.move(to: CGPoint(x: mirrorPos, y: objectSize))
            path.addLine(to: CGPoint(x: mirrorPos+mirrorF, y: 0))
        }
        
        // parallel ray F > image
        if mirror.type == .concave {
            path.move(to: CGPoint(x: mirrorPos-mirrorF, y: 0))
            path.addLine(to: CGPoint(x: imagePos, y: imageSize))
        }
        
        // center ray object > S
        path.move(to: CGPoint(x: objectPos, y: objectSize))
        path.addLine(to: CGPoint(x: mirrorPos, y: 0))
        
        // center ray S > image
        path.move(to: CGPoint(x: mirrorPos, y: 0))
        path.addLine(to: CGPoint(x: imagePos, y: imageSize))
        
        context.stroke(path, with: .color(.yellow), lineWidth: 1)
    }
    
    func rendererPos(from resIndependantPos: CGFloat) -> CGFloat {
        
        resIndependantPos * size.width
    }
    
    func rendererFocalLength(from resIndependantF: CGFloat) -> CGFloat {
        
        resIndependantF * size.width/2
    }
    
    func rendererObjectSize(from resIndependantSize: CGFloat) -> CGFloat {
        
        resIndependantSize * size.height/2*0.9
    }
    
    func render(_ scene: OpticsScene) {
        
        let object = scene.objects.first!
        let lense = scene.lenses.first!
        let mirror = scene.mirrors.first!
        let image = scene.image
        
        drawAxis()
        draw(object)
        draw(lense)
        draw(mirror)
        draw(image)
        
        drawRays(for: object, lense, image)
        drawRays(for: object, mirror, image)
    }
}



enum ArrowDirection {
    
    case towardAxis, awayFromAxis
}
