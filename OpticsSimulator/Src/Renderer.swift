
import SwiftUI



struct Renderer {
    
    let context: GraphicsContext
    let renderSize: CGSize

    func drawAxis() {
        
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: renderSize.width, y: 0))
        
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
    
    let opacityWhenHidden: CGFloat = 0.2
    
    func draw(_ object: Object) {
        
        drawObjectOrImage(
            at: resolvedPos(from: object.pos),
            size: resolvedObjectSize(from: object.size),
            color: .blue,
            opacity: object.visible ? 1 : opacityWhenHidden
        )
    }
    
    func draw(_ image: Image, virtual: Bool = false) {
        
        drawObjectOrImage(
            at: resolvedPos(from: image.pos),
            size: resolvedObjectSize(from: image.size),
            color: .green, virtual: virtual
        )
    }
        
    func drawObjectOrImage(
        at position: CGFloat, size: CGFloat,
        color: Color, virtual: Bool = false, opacity: CGFloat = 1
    ) {
        let x = position
        let h = size
        
        let lineWidth: CGFloat = 2
        
        var path = Path()
        
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: h))
        
        path.addPath(pathForArrow(at: h, pointing: .towardAxis),
                     transform: .init(translationX: position, y: 0))
        
        context.stroke(path, with: .color(color.opacity(opacity)), style: StrokeStyle(
            lineWidth: lineWidth,
            dash: virtual ? [4, 4] : []
        ))
    }
    
    func draw(_ lense: Lense) {
        
        let x = resolvedPos(from: lense.pos)
        let h = renderSize.height/2*0.9
        
        let f = resolvedFocalLength(from: lense.focalLength)
        let m: CGFloat = 5
        
        let arrowDir: ArrowDirection = lense.type == .convergent ? .towardAxis : .awayFromAxis
        
        var path = Path()
        let color: Color = .red.opacity(lense.visible ? 1 : opacityWhenHidden)
        
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
        
        context.stroke(path, with: .color(color), lineWidth: 2)
        
        // connect focal points
        
        path.move(to: CGPoint(x: x, y: h))
        path.addLine(to: CGPoint(x: x-f, y: 0))
        path.addLine(to: CGPoint(x: x, y: -h))
        path.addLine(to: CGPoint(x: x+f, y: 0))
        path.addLine(to: CGPoint(x: x, y: h))
        
        context.stroke(path, with: .color(color.opacity(0.5)), style: StrokeStyle(
            lineWidth: 1,
            dash: [4, 4]
        ))
    }
    
    func draw(_ mirror: SphericalMirror) {
        
        let x = resolvedPos(from: mirror.pos)
        let h = renderSize.height/2*0.8
        
        let f = resolvedFocalLength(from: mirror.focalLength)
        let m: CGFloat = 5
        
        let a: CGFloat = 5
        
        var path = Path()
        let color: Color = .red.opacity(mirror.visible ? 1 : opacityWhenHidden)
        
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
        
        context.stroke(path, with: .color(color), lineWidth: 2)
    }
    
    func draw(_ screen: Screen) {
        
        let x = resolvedPos(from: screen.pos)
        let h = renderSize.height/2
        
        let a: CGFloat = 5
        
        var path = Path()
        let color: Color = .gray.opacity(screen.visible ? 1 : opacityWhenHidden)
        
        path.move(to: CGPoint(x: x, y: h))
        path.addLine(to: CGPoint(x: x, y: -h))
        
        let n = 45
        for i in 0...n {
            
            let hi: CGFloat = -h + CGFloat(i)*2*h/CGFloat(n)
            
            path.move(to: CGPoint(x: x, y: hi))
            path.addLine(to: CGPoint(x: x+a, y: hi-a))
        }
        
        context.stroke(path, with: .color(color), lineWidth: 2)
    }
    
    func drawRay(
        from p1: CGPoint, to p2: CGPoint,
        minX: CGFloat? = nil, maxX: CGFloat? = nil,
        virtual: Bool = false
    ) {
        draw(
            Ray(from: p1, to: p2),
                    minX: minX ?? p1.x, maxX: maxX ?? p2.x,
            virtual: virtual
        )
    }
    
    func draw(
        _ ray: Ray,
        minX: CGFloat, maxX: CGFloat,
        virtual: Bool = false
    ) {
        let startPoint = ray.point(
            atX: minX
        )
        let endPoint = ray.point(
            atX: maxX
        )
        
        var path = Path()
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        context.stroke(path, with: .color(.yellow), style: StrokeStyle(
            lineWidth: 1,
            dash: virtual ? [4, 4] : []
        ))
    }
    
    func resolvedPos(from rawPos: CGFloat) -> CGFloat {
        
        rawPos * renderSize.width
    }
    
    func resolvedFocalLength(from rawFocalLength: CGFloat) -> CGFloat {
        
        rawFocalLength * renderSize.width
    }
    
    func resolvedObjectSize(from rawSize: CGFloat) -> CGFloat {
        
        rawSize * renderSize.height/2*0.7
    }
    
    func image(of object: ObjectOrImage, through device: OpticsDevice) -> Image {
        
        var imagePos: CGFloat
        var imageSize: CGFloat
        var gamma: CGFloat
        
        if let lense = device as? Lense {
            
            // compute image through lense
            let f = lense.focalLength * (lense.type == .convergent ? +1 : -1)
            let distO = lense.pos - object.pos
            gamma = f / (distO - f)
            let distI = distO * gamma
            imagePos = lense.pos + distI
            imageSize = -object.size * gamma
            
            return Image(pos: imagePos, size: imageSize)
        }
        
        if let mirror = device as? SphericalMirror {
            
            // compute image through mirror
            let posf = mirror.pos + (mirror.type == .convex ? +1 : -1) * mirror.focalLength
            let fa = object.pos - posf
            let fa_im = mirror.focalLength*mirror.focalLength / fa
            imagePos = fa_im + posf
            let sa = object.pos - mirror.pos
            let sa_im = imagePos - mirror.pos
            gamma = sa_im / sa
            imageSize = -object.size * gamma
            
            return Image(pos: imagePos, size: imageSize)
        }
        
        fatalError()
    }
    
    func render(_ scene: OpticsScene) {
        
        drawAxis()
        
        for object in scene.objects.filter({ $0.enabled }) {
            draw(object)
        }
        for lense in scene.lenses.filter({ $0.enabled }) {
            draw(lense)
        }
        for mirror in scene.mirrors.filter({ $0.enabled }) {
            draw(mirror)
        }
        for screen in scene.screens.filter({ $0.enabled }) {
            draw(screen)
        }
        
        
        // compute images
        
        let devicesByPosition = scene.devices
            .sorted { $0.pos < $1.pos }
            .filter { $0.enabled }
        
        var images: [Image] = []
        
        if let object = scene.objects.filter({ $0.enabled }).first {
            
            let devices = devicesByPosition
                .filter { $0.pos > object.pos }
            
            // compute images
            
            for i in 0..<devices.count {
                
                let currentDevice = devices[i]
                let nextDevice = i+1 < devices.count ? devices[i+1] : nil
                
                if currentDevice is Screen {
                    break
                }
                
                let currentSource = images.last ?? object
                let image = image(of: currentSource, through: currentDevice)
                
                images.append(image)
                
                var imageIsVirtual = false
                
                if image.pos < currentDevice.pos {
                    
                    imageIsVirtual = true
                }
                
                if let nextDevice = nextDevice,
                   image.pos > nextDevice.pos {
                    
                    imageIsVirtual = true
                }
                
                draw(image, virtual: imageIsVirtual)
            }
            
            // draw rays
            
            let objectOrImages = [object] + images
            
            for i1 in 0..<objectOrImages.count {
            
//                if ![1].contains(i1) { continue }
                
                // generate rays from source
                
                let currentSource = objectOrImages[i1]
                
                let previousDevice = (i1-1) >= 0 ? devices[i1-1] : nil
                let currentDevice = i1 < devices.count ? devices[i1] : nil
                
                guard let currentDevice = currentDevice else {
                    
                    break
                }
                
                if currentDevice is Screen,
                   currentSource is Image {
                    
                    break
                }
                
                let currentSourcePos = resolvedPos(
                    from: currentSource.pos
                )
                let currentSourceSize = resolvedObjectSize(
                    from: currentSource.size
                )
                let currentSourceTop = CGPoint(
                    x: currentSourcePos, y: currentSourceSize
                )
                
                let currentDevicePos = resolvedPos(
                    from: currentDevice.pos
                )
                let currentDeviceCenter = CGPoint(
                    x: currentDevicePos, y: 0
                )
                let currentDeviceFocalLength = currentDevice is Lense
                    ? resolvedFocalLength(
                        from: (currentDevice as! Lense).focalLength
                    ) : nil
                let currentDeviceFocalPoint = currentDevice is Lense
                    ? CGPoint(
                        x: currentDevicePos - currentDeviceFocalLength!, y: 0
                    ) : nil
                
                let previousDevicePos = previousDevice != nil ? resolvedPos(
                    from: previousDevice!.pos
                ) : nil
                
                var rayPointsOnPreviousDevice: [RayPoint] = []
                var rayPointsOnCurrentDevice: [RayPoint] = []
                
                // parallel ray
                
                var generateParallelRay = false
                
                if let lense = currentDevice as? Lense, lense.generatesParallelRay {
                    
                    generateParallelRay = true
                }
                if currentDevice is Screen {
                    
                    generateParallelRay = true
                }
                if generateParallelRay {
                    
                    let parallelRay = Ray(
                        horizontalFrom: currentSourceTop
                    )
                    
                    let pointFromParallelRayOnCurrentDevice =
                        parallelRay.point(
                            atX: currentDevicePos
                        )
                    
                    if let previousDevicePos = previousDevicePos,
                       currentSourcePos < previousDevicePos {
                        
                        draw(
                            parallelRay,
                            minX: previousDevicePos,
                            maxX: currentDevicePos
                        )
                        
                        draw(
                            parallelRay,
                            minX: currentSourcePos,
                            maxX: previousDevicePos,
                            virtual: true
                        )
                        
                    } else {
                        
                        draw(
                            parallelRay,
                            minX: currentSourcePos,
                            maxX: currentDevicePos
                        )
                    }
                    
                    rayPointsOnCurrentDevice.append(RayPoint(
                        p: pointFromParallelRayOnCurrentDevice,
                        type: .parallel,
                        sourceDevice: currentDevice,
                        source: currentSource,
                        horizontalIncidence: true
                    ))
                    
                    if let lense = currentDevice as? Lense,
                       lense.retroPropagatesRays,
                       let previousDevicePos = previousDevicePos {
                        
                        if currentSourcePos > previousDevicePos {
                            
                            draw(
                                parallelRay,
                                minX: previousDevicePos,
                                maxX: currentSourcePos
                            )
                        }
                        
                        let pointFromParallelRayOnPreviousDevice =
                            parallelRay.point(
                                atX: previousDevicePos
                            )
                        
                        rayPointsOnPreviousDevice.append(RayPoint(
                            p: pointFromParallelRayOnPreviousDevice,
                            type: .parallel,
                            sourceDevice: currentDevice,
                            source: currentSource,
                            horizontalIncidence: true
                        ))
                    }
                }
                
                // continue rays forward through all devices
                
                for rayPoint in rayPointsOnCurrentDevice {
                    
                    var rayPointOnPreviousDevice = rayPoint
                    
                    for i2 in (i1+1)..<objectOrImages.count {
                        
                        let currentSource = objectOrImages[i2]
                        let currentSourcePos = resolvedPos(from: currentSource.pos)
                        let currentSourceSize = resolvedObjectSize(from: currentSource.size)
                        let currentSourceTop = CGPoint(x: currentSourcePos, y: currentSourceSize)
                        
                        let previousDevice = (i2-1) >= 0 ? devices[i2-1] : nil
                        let previousDevicePos = previousDevice != nil
                        ? resolvedPos(
                            from: previousDevice!.pos
                        ) : nil
                        
                        let previousDeviceFocalLength = previousDevice is Lense
                        ? resolvedFocalLength(
                            from: (previousDevice as! Lense).focalLength
                        ) : nil
                        let previousDeviceFocalPointBefore = previousDevice is Lense
                        ? CGPoint(
                            x: previousDevicePos! - previousDeviceFocalLength!, y: 0
                        ) : nil
                        let previousDeviceFocalPointAfter = previousDevice is Lense
                        ? CGPoint(
                            x: previousDevicePos! + previousDeviceFocalLength!, y: 0
                        ) : nil
                        let previousDeviceIsRaySourceDevice =
                        previousDevice != nil &&
                        previousDevice!.id == rayPointOnPreviousDevice.sourceDevice.id
                        
                        let currentDevice = i2 < devices.count ? devices[i2] : nil
                        let currentDevicePos = currentDevice != nil
                        ? resolvedPos(
                            from: currentDevice!.pos
                        ) : nil
                        
                        let ray = Ray(
                            from: rayPointOnPreviousDevice.p, to: currentSourceTop
                        )
                        
                        let endX = currentDevicePos ?? renderSize.width
                        
                        let endPoint = ray.point(
                            atX: endX
                        )
                        
                        draw(
                            ray,
                            minX: rayPointOnPreviousDevice.p.x,
                            maxX: endX
                        )
                        
                        if let lense = previousDevice as? Lense,
                           lense.type == .divergent,
                           rayPointOnPreviousDevice.hasParallelIncidence {
                            
                            draw(
                                ray,
                                minX: previousDeviceFocalPointBefore!.x,
                                maxX: rayPointOnPreviousDevice.p.x,
                                virtual: true
                            )
                        }
                        
                        if let lense = previousDevice as? Lense,
                           lense.type == .convergent,
                           rayPointOnPreviousDevice.hasParallelIncidence,
                           let currentDevicePos = currentDevicePos,
                           previousDeviceFocalPointAfter!.x > currentDevicePos
                        {
                            draw(
                                ray,
                                minX: currentDevicePos,
                                maxX: previousDeviceFocalPointAfter!.x,
                                virtual: true
                            )
                        }
                        
                        if currentSourcePos < previousDevicePos! {
                            
                            if previousDeviceIsRaySourceDevice,
                               let lense = previousDevice as? Lense,
                               lense.type == .divergent,
                               rayPointOnPreviousDevice.hasParallelIncidence
                            {
                            } else {
                                
                                draw(
                                    ray,
                                    minX: currentSourcePos,
                                    maxX: rayPointOnPreviousDevice.p.x,
                                    virtual: true
                                )
                            }
                        }
                        
                        if let currentDevicePos = currentDevicePos,
                           currentSourcePos > currentDevicePos {
                            
                            draw(
                                ray,
                                minX: currentDevicePos,
                                maxX: currentSourcePos,
                                virtual: true
                            )
                        }
                        
                        rayPointOnPreviousDevice = RayPoint(
                            p: endPoint,
                            type: rayPointOnPreviousDevice.type,
                            sourceDevice: rayPointOnPreviousDevice.sourceDevice
                        )
                    }
                }
                
                // continue rays backwards through all devices
                
                for rayPoint in rayPointsOnPreviousDevice {
                    
                    var rayPointOnCurrentDevice = rayPoint

                    for i2 in 0..<i1 {

                        let i3 = i1-1-i2
                        
                        let currentSource = objectOrImages[i3]
                        let currentSourcePos = resolvedPos(
                            from: currentSource.pos
                        )
                        let currentSourceSize = resolvedObjectSize(
                            from: currentSource.size
                        )
                        let currentSourceTop = CGPoint(
                            x: currentSourcePos, y: currentSourceSize
                        )
                        
                        let currentDevice = i3 < devices.count ? devices[i3] : nil
                        let currentDevicePos = currentDevice != nil
                            ? resolvedPos(
                                from: currentDevice!.pos
                            ) : nil
                        let currentDeviceFocalLength = currentDevice is Lense
                            ? resolvedFocalLength(
                                from: (currentDevice as! Lense).focalLength
                            ) : nil
                        let currentDeviceFocalPointBefore = currentDevice is Lense
                            ? CGPoint(
                                x: currentDevicePos! - currentDeviceFocalLength!, y: 0
                            ) : nil

                        let previousDevice = (i3-1) >= 0 ? devices[i3-1] : nil
                        let previousDevicePos = previousDevice != nil
                            ? resolvedPos(
                                from: previousDevice!.pos
                            ) : nil
                        
                        let ray = Ray(
                            from: currentSourceTop, to: rayPointOnCurrentDevice.p
                        )
                        
                        let startX = previousDevicePos ?? currentSourcePos
                        
                        let startPoint = ray.point(
                            atX: startX
                        )

                        draw(
                            ray,
                            minX: startX,
                            maxX: rayPointOnCurrentDevice.p.x
                        )
                        
                        if rayPointOnCurrentDevice.hasParallelIncidence,
                           let lense = currentDevice as? Lense,
                           lense.type == .convergent,
                           currentDeviceFocalPointBefore!.x < startX {
                            
                            draw(
                                ray,
                                minX: currentDeviceFocalPointBefore!.x,
                                maxX: startX,
                                virtual: true
                            )
                        }
                        
                        rayPointOnCurrentDevice = RayPoint(
                            p: startPoint,
                            type: rayPointOnCurrentDevice.type,
                            sourceDevice: rayPointOnCurrentDevice.sourceDevice
                        )
                    }
                }
                
//                // center ray
//                
//                let centerRay = Ray(
//                    from: sourceTop, to: deviceAfterCenter,
//                )
//                
//                let pointFromCenterOnDeviceBefore = centerRay.point(
//                    atX: deviceBeforePos ?? currentSource.pos
//                )
//                
//                let pointFromCenterOnDeviceAfter = centerRay.point(
//                    atX: deviceAfterPos
//                )
//                
//                if let lense = deviceAfter as? Lense,
//                   lense.generatesCenterRay {
//                    
//                    draw(
//                        centerRay,
//                        betweenX: deviceBeforePos ?? currentSource.pos, andX: deviceAfterPos
//                    )
//                    
//                    if sourcePos < deviceBeforePos ?? currentSource.pos {
//                        
//                        draw(
//                            centerRay,
//                            betweenX: sourcePos, andX: deviceBeforePos ?? currentSource.pos,
//                            virtual: true
//                        )
//                    }
//                }
//                
//                pointsOnDeviceBefore.append(RayPoint(
//                    p: pointFromCenterOnDeviceAfter, type: .center
//                ))
//                pointsOnDeviceAfter.append(RayPoint(
//                    p: pointFromCenterOnDeviceBefore, type: .center
//                ))
//                
//                // focal ray
//                
//                if let deviceAfterFocalPoint = deviceAfterFocalPoint {
//                    
//                    let focalRay = Ray(
//                        from: sourceTop, to: deviceAfterFocalPoint,
//                    )
//                    
//                    let pointFromFocalPointOnDeviceBefore = focalRay.point(
//                        atX: deviceBeforePos ?? currentSource.pos
//                    )
//                    
//                    let pointFromFocalPointOnDeviceAfter = focalRay.point(
//                        atX: deviceAfterPos
//                    )
//                    
//                    if let lense = deviceAfter as? Lense,
//                       lense.generatesFocalRay {
//                        
//                        draw(
//                            focalRay,
//                            betweenX: deviceBeforePos ?? currentSource.pos, andX: deviceAfterPos
//                        )
//                        
//                        if sourcePos < deviceBeforePos ?? currentSource.pos {
//                            
//                            draw(
//                                focalRay,
//                                betweenX: sourcePos, andX: deviceBeforePos ?? currentSource.pos,
//                                virtual: true
//                            )
//                        }
//                        
//                        if sourcePos > deviceAfterFocalPoint.x {
//                            
//                            draw(
//                                focalRay,
//                                betweenX: deviceAfterFocalPoint.x, andX: sourcePos,
//                                virtual: true
//                            )
//                        }
//                        
////                        if let lense = deviceAfter as? Lense,
////                           lense.type == .divergent {
////                            
////                            drawRay(
////                                from: deviceAfterFocalPoint,
////                                to: pointFromHorizontalOnDeviceAfter,
////                                minX: deviceAfterFocalPoint.x, maxX: deviceAfterPos,
////                                virtual: true
////                            )
////                        }
//                        
//                        pointsOnDeviceBefore.append(RayPoint(
//                            p: pointFromFocalPointOnDeviceAfter, type: .focal
//                        ))
//                        pointsOnDeviceAfter.append(RayPoint(
//                            p: pointFromFocalPointOnDeviceBefore, type: .focal
//                        ))
//                    }
//                }

                // continue rays forward through all devices
                
//                for i2 in (i1+1)..<objectOrImages.count {
//
//                    if ![].contains(i2) { continue }
//                    
//                    let currentImage = objectOrImages[i2]
//                    let previousImage = (i2-1) >= 0 ? objectOrImages[i2-1] : nil
//                    
//                    let deviceBefore = (i2-1) >= 0 ? devices[i2-1] : nil
//                    let deviceAfter = i2 < devices.count ? devices[i2] : nil
//                    
//                    let imagePos = resolvedPos(from: currentImage.pos)
//                    let imageSize = resolvedObjectSize(from: currentImage.size)
//                    let imageTop = CGPoint(x: imagePos, y: imageSize)
//                    
//                    let previousImagePos = resolvedPos(from: previousImage?.pos ?? 0)
//                    
//                    let deviceBeforePos = resolvedPos(
//                        from: deviceBefore?.pos ?? currentImage.pos
//                    )
//                    let deviceAfterPos = resolvedPos(
//                        from: deviceAfter?.pos ?? currentImage.pos
//                    )
//                    
//                    var pointsOnDeviceAfter: [RayPoint] = []
//
//                    for pointOnDeviceBefore in rayPointsOnPreviousDevice {
//
//                        let pointOnDeviceAfter = Ray(
//                            from: pointOnDeviceBefore.p, to: imageTop
//                        ).point(
//                            atX: deviceAfterPos
//                        )
//
//                        drawRay(
//                            from: pointOnDeviceBefore.p,
//                            to: pointOnDeviceAfter
//                        )
//                        
//                        if imagePos < deviceBeforePos {
//                            
//                            if pointOnDeviceBefore.type == .center,
//                               previousImage != nil,
//                               let lense = deviceBefore as? Lense, lense.type == .convergent {
//                                
//                                drawRay(
//                                    from: pointOnDeviceBefore.p,
//                                    to: pointOnDeviceAfter,
//                                    minX: imagePos, maxX: previousImagePos,
//                                    virtual: true
//                                )
//                                
//                            } else if pointOnDeviceBefore.type != .center,
//                                      pointOnDeviceBefore.type != .parallel {
//                             
//                                drawRay(
//                                    from: pointOnDeviceBefore.p,
//                                    to: pointOnDeviceAfter,
//                                    minX: imagePos, maxX: deviceBeforePos,
//                                    virtual: true
//                                )
//                            }
//                        }
//                        
//                        if imagePos > deviceAfterPos {
//                            
//                            drawRay(
//                                from: pointOnDeviceBefore.p,
//                                to: pointOnDeviceAfter,
//                                minX: deviceAfterPos, maxX: imagePos,
//                                virtual: true
//                            )
//                        }
//
//                        pointsOnDeviceAfter.append(RayPoint(
//                            p: pointOnDeviceAfter,
//                            type: pointOnDeviceBefore.type,
//                            sourceDevice: pointOnDeviceBefore.sourceDevice
//                        ))
//                    }
//
//                    rayPointsOnPreviousDevice = pointsOnDeviceAfter
//                }
//                
//                // continue rays backwards through all devices
//                
//                if let lense = currentDevice as? Lense,
//                   lense.retroPropagatesRays {
//                    
//                    for i2 in 0..<i1 {
//                        
//                        let i3 = i1-1-i2
//                        
//                        if ![].contains(i3) { continue }
//                        
//                        let currentImage = objectOrImages[i3]
//                        
//                        let deviceBefore = (i3-1) >= 0 ? devices[i3-1] : nil
//                        
//                        let imagePos = resolvedPos(from: currentImage.pos)
//                        let imageSize = resolvedObjectSize(from: currentImage.size)
//                        let imageTop = CGPoint(x: imagePos, y: imageSize)
//                        
//                        let deviceBeforePos = resolvedPos(
//                            from: deviceBefore?.pos ?? currentImage.pos
//                        )
//                        
//                        var pointsOnDeviceBefore: [RayPoint] = []
//                        
//                        for pointOnDeviceAfter in rayPointsOnCurrentDevice {
//                            
//                            let pointOnDeviceBefore = Ray(
//                                from: pointOnDeviceAfter.p, to: imageTop
//                            ).point(
//                                atX: deviceBeforePos
//                            )
//                            
//                            drawRay(
//                                from: pointOnDeviceBefore,
//                                to: pointOnDeviceAfter.p
//                            )
//                            
//                            pointsOnDeviceBefore.append(RayPoint(
//                                p: pointOnDeviceBefore,
//                                type: pointOnDeviceAfter.type,
//                                sourceDevice: pointOnDeviceAfter.sourceDevice
//                            ))
//                        }
//                        
//                        rayPointsOnCurrentDevice = pointsOnDeviceBefore
//                    }
//                }
            }
        }
        
        
        //                    // parallel ray : object > lense
        //
        //                    let pointOnLenseFromHorizontal = Ray(
        //                        horizontalFrom: objectTop
        //                    ).point(
        //                        atX: lensePos
        //                    )
        //
        //                    drawRay(
        //                        from: objectTop,
        //                        to: pointOnLenseFromHorizontal
        //                    )
        //
        //                    // parallel ray : lense > F > image
        //
        //                    let pointOnScreenFromHorizontal = Ray(
        //                        from: pointOnLenseFromHorizontal, to: imageTop,
        //                    ).point(
        //                        atX: nextDevicePos
        //                    )
        //
        //                    drawRay(
        //                        from: pointOnLenseFromHorizontal,
        //                        to: pointOnScreenFromHorizontal
        //                    )
        //                    if lense.type == .divergent {
        //                        drawRay(
        //                            from: pointOnLenseFromHorizontal, to: imageTop,
        //                            minX: F1.x, maxX: lensePos,
        //                            virtual: true
        //                        )
        //                    }
        //
        //                    if imagePos > nextDeviceX {
        //                        drawRay(
        //                            from: pointOnLenseFromHorizontal, to: imageTop,
        //                            minX: nextDevicePos, maxX: imagePos,
        //                            virtual: true
        //                        )
        //                    }
        //
        //                    // center ray : object > O > image
        //
        //                    let pointOnScreenFromCenter = Ray(
        //                        from: objectTop, to: lenseCenter,
        //                    ).point(
        //                        atX: nextDevicePos
        //                    )
        //
        //                    drawRay(
        //                        from: objectTop,
        //                        to: pointOnScreenFromCenter
        //                    )
        //
        //                    if imagePos > nextDevicePos {
        //
        //                        drawRay(
        //                            from: objectTop, to: lenseCenter,
        //                            minX: nextDevicePos, maxX: imagePos,
        //                            virtual: true
        //                        )
        //                    }

        //                    startingPoints = [
        //                        pointOnScreenFromHorizontal,
        //                        pointOnScreenFromCenter
        //                    ]
        
        
        
        
        if let object = scene.objects.first,
           let mirror = scene.mirrors.first {
            
            images.append(image(of: object, through: mirror))
        }
        
        
        // draw rays
        
        let object = scene.objects.first
        let mirror = scene.mirrors.first
        let image = images.first
        let screen = scene.screens.first
         
        
        if let object = object,
           let mirror = mirror,
           let image = image,
           let screen = screen {
            
            let objectPos = resolvedPos(from: object.pos)
            let objectSize = resolvedObjectSize(from: object.size)
            let objectTop = CGPoint(x: objectPos, y: objectSize)
            
            let imagePos = resolvedPos(from: image.pos)
            let imageSize = resolvedObjectSize(from: image.size)
            let imageTop = CGPoint(x: imagePos, y: imageSize)
            
            let mirrorPos = resolvedPos(from: mirror.pos)
            let f = resolvedFocalLength(from: mirror.focalLength)
            let mirrorVertex = CGPoint(x: mirrorPos, y: 0)
            let mirrorCenter = CGPoint(x: mirrorPos+(mirror.type == .concave ? -1 : +1)*2*f, y: 0)
            let F = CGPoint(x: mirrorPos+(mirror.type == .concave ? -1 : +1)*f, y: 0)
            
            let screenPos = resolvedPos(from: screen.pos)
            
            // parallel ray : object > mirror
            
            let projectedPointOnMirror = Ray(horizontalFrom: objectTop)
                .point(atX: mirrorPos)
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
    }
}



enum ArrowDirection {
    
    case towardAxis, awayFromAxis
}
