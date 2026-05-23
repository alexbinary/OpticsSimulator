
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
    
    func draw(_ screen: Screen) {
        
        let x = rendererPos(from: screen.pos)
        let h = size.height/2
        
        let a: CGFloat = 5
        
        var path = Path()
        
        path.move(to: CGPoint(x: x, y: h))
        path.addLine(to: CGPoint(x: x, y: -h))
        
        let n = 45
        for i in 0...n {
            
            let hi: CGFloat = -h + CGFloat(i)*2*h/CGFloat(n)
            
            path.move(to: CGPoint(x: x, y: hi))
            path.addLine(to: CGPoint(x: x+a, y: hi-a))
        }
        
        context.stroke(path, with: .color(.gray), lineWidth: 2)
    }
    
    func drawRay(
        from p1: CGPoint, to p2: CGPoint,
        minX: CGFloat? = nil, maxX: CGFloat? = nil,
        virtual: Bool = false
    ) {
        let direction = Direction(from: p1, to: p2)
        
        let startPoint = direction.point(
            atX: minX ?? p1.x, startingFrom: p1
        )
        let endPoint = direction.point(
            atX: maxX ?? p2.x, startingFrom: p1
        )
        
        var path = Path()
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        context.stroke(path, with: .color(.yellow), style: StrokeStyle(
            lineWidth: 1,
            dash: virtual ? [4, 4] : []
        ))
    }
    
//    func drawRay(
//        from p1: CGPoint, to p2: CGPoint, extendToX targetXs: [CGFloat] = [],
//        virtual: Bool = false
//    ) {
//        let allX = [p1.x, p2.x]+targetXs
//        let minX = allX.min()!
//        let maxX = allX.max()!
//        
//        drawRay(joining: p1, with: p2, fromX: minX, toX: maxX, virtual: virtual)
//    }
    
    func drawRays(
        for object: Object,
        _ lense: Lense, _ image: Image,
        _ screen: Screen
    ) {
        let objectPos = rendererPos(from: object.pos)
        let objectSize = rendererObjectSize(from: object.size)
        let objectTop = CGPoint(x: objectPos, y: objectSize)
        
        let imagePos = rendererPos(from: image.pos)
        let imageSize = rendererObjectSize(from: image.size)
        let imageTop = CGPoint(x: imagePos, y: imageSize)
        
        let lensePos = rendererPos(from: lense.pos)
        let lenseCenter = CGPoint(x: lensePos, y: 0)
        let f = rendererFocalLength(from: lense.focalLength)
        let F1 = CGPoint(x: lensePos-f, y: 0)
        
        let screenPos = rendererPos(from: screen.pos)
        
        // parallel ray : object > lense
        
        let projectedPointOnLense = Direction.horizontal.point(
            atX: lensePos, startingFrom: objectTop
        )
        drawRay(from: objectTop, to: projectedPointOnLense)
        
        // parallel ray : lense > F > image
        
        drawRay(
            from: projectedPointOnLense, to: imageTop,
            minX: lensePos, maxX: screenPos
        )
        if lense.type == .divergent {
            drawRay(
                from: projectedPointOnLense, to: imageTop,
                minX: F1.x, maxX: lensePos,
                virtual: true
            )
        }
        
        if imagePos > screenPos {
            
            drawRay(
                from: projectedPointOnLense, to: imageTop,
                minX: screenPos, maxX: imagePos,
                virtual: true
            )
        }
        
        // center ray : object > O > image
        
        drawRay(
            from: objectTop, to: lenseCenter,
            minX: objectPos, maxX: screenPos
        )
        
        if imagePos > screenPos {
            
            drawRay(
                from: objectTop, to: lenseCenter,
                minX: screenPos, maxX: imagePos,
                virtual: true
            )
        }
    }
    
    func drawRays(
        for object: Object,
        _ mirror: SphericalMirror, _ image: Image,
        _ screen: Screen
    ) {
        let objectPos = rendererPos(from: object.pos)
        let objectSize = rendererObjectSize(from: object.size)
        let objectTop = CGPoint(x: objectPos, y: objectSize)
        
        let imagePos = rendererPos(from: image.pos)
        let imageSize = rendererObjectSize(from: image.size)
        let imageTop = CGPoint(x: imagePos, y: imageSize)
        
        let mirrorPos = rendererPos(from: mirror.pos)
        let f = rendererFocalLength(from: mirror.focalLength)
        let mirrorVertex = CGPoint(x: mirrorPos, y: 0)
        let mirrorCenter = CGPoint(x: mirrorPos+(mirror.type == .concave ? -1 : +1)*2*f, y: 0)
        let F = CGPoint(x: mirrorPos+(mirror.type == .concave ? -1 : +1)*f, y: 0)
        
        let screenPos = rendererPos(from: screen.pos)
        
        // parallel ray : object > mirror
        
        let projectedPointOnMirror = Direction.horizontal.point(
            atX: mirrorPos, startingFrom: objectTop
        )
        drawRay(from: objectTop, to: projectedPointOnMirror)
        
        // parallel ray : mirror > F > image
        
        drawRay(
            from: projectedPointOnMirror, to: F,
            minX: screenPos, maxX: mirrorPos
        )
        
        if imagePos < screenPos {
        
            drawRay(
                from: projectedPointOnMirror, to: F,
                minX: imagePos, maxX: screenPos,
                virtual: true
            )
        }
        
        if imagePos > mirrorPos {
        
            drawRay(
                from: projectedPointOnMirror, to: F,
                minX: mirrorPos, maxX: [imagePos, F.x].max()!,
                virtual: true
            )
        }
        
        // vertex ray : object > S
        
        drawRay(from: objectTop, to: mirrorVertex)
        
        // vertex ray : S > image

        drawRay(
            from: mirrorVertex, to: imageTop,
            minX: screenPos, maxX: mirrorPos
        )
        
        if imagePos < screenPos {
            
            drawRay(
                from: mirrorVertex, to: imageTop,
                minX: imagePos, maxX: screenPos,
                virtual: true
            )
        }
        
        if imagePos > mirrorPos {
        
            drawRay(
                from: mirrorVertex, to: imageTop,
                minX: mirrorPos, maxX: imagePos,
                virtual: true
            )
        }
        
        // center ray : object > image

        drawRay(
            from: objectTop, to: mirrorCenter,
            minX: screenPos, maxX: mirrorPos
        )
        
        if imagePos < screenPos {
        
            drawRay(
                from: objectTop, to: mirrorCenter,
                minX: imagePos, maxX: screenPos,
                virtual: true
            )
        }
        
        if imagePos > mirrorPos {
        
            drawRay(
                from: objectTop, to: mirrorCenter,
                minX: mirrorPos, maxX: [imagePos, mirrorCenter.x].max()!,
                virtual: true
            )
        }
    }
    
    func rendererPos(from resIndependantPos: CGFloat) -> CGFloat {
        
        resIndependantPos * size.width
    }
    
    func rendererFocalLength(from resIndependantF: CGFloat) -> CGFloat {
        
        resIndependantF * size.width
    }
    
    func rendererObjectSize(from resIndependantSize: CGFloat) -> CGFloat {
        
        resIndependantSize * size.height/2*0.7
    }
    
    func render(_ scene: OpticsScene) {
        
        drawAxis()
        
        for object in scene.objects {
            
            draw(object)
        }
        
        for lense in scene.lenses {
            
            draw(lense)
        }
        
        for mirror in scene.mirrors {
            
            draw(mirror)
        }
        
        for image in scene.images {
            
            draw(image)
        }
        
        for screen in scene.screens {
            
            draw(screen)
        }
        
        let object = scene.objects.first
        let lense = scene.lenses.first
        let mirror = scene.mirrors.first
        let image = scene.images.first
        let screen = scene.screens.first
         
        if let object = object,
           let lense = lense,
           let image = image,
           let screen = screen {
            
            drawRays(for: object, lense, image, screen)
        }
        
        if let object = object,
           let mirror = mirror,
           let image = image,
           let screen = screen {
            
            drawRays(for: object, mirror, image, screen)
        }
    }
}



enum ArrowDirection {
    
    case towardAxis, awayFromAxis
}
