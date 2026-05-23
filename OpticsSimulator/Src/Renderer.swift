
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
    
    func draw(_ object: Object) {
        
        drawObjectOrImage(
            at: rendererPos(from: object.pos),
            size: rendererObjectSize(from: object.size),
            color: .blue
        )
    }
    
    func draw(_ image: Image, virtual: Bool = false) {
        
        drawObjectOrImage(
            at: rendererPos(from: image.pos),
            size: rendererObjectSize(from: image.size),
            color: .green, virtual: virtual
        )
    }
        
    func drawObjectOrImage(
        at position: CGFloat, size: CGFloat,
        color: Color, virtual: Bool = false
    ) {
        let x = position
        let h = size
        
        let lineWidth: CGFloat = 2
        
        var path = Path()
        
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: h))
        
        path.addPath(pathForArrow(at: h, pointing: .towardAxis),
                     transform: .init(translationX: position, y: 0))
        
        context.stroke(path, with: .color(color), style: StrokeStyle(
            lineWidth: lineWidth,
            dash: virtual ? [4, 4] : []
        ))
    }
    
    func draw(_ lense: Lense) {
        
        let x = rendererPos(from: lense.pos)
        let h = renderSize.height/2*0.9
        
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
        let h = renderSize.height/2*0.8
        
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
        let h = renderSize.height/2
        
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
        draw(
            Ray(from: p1, to: p2),
            betweenX: minX ?? p1.x, andX: maxX ?? p2.x,
            virtual: virtual
        )
    }
    
    func draw(
        _ ray: Ray,
        betweenX minX: CGFloat, andX maxX: CGFloat,
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
    
    func rendererPos(from resIndependantPos: CGFloat) -> CGFloat {
        
        resIndependantPos * renderSize.width
    }
    
    func rendererFocalLength(from resIndependantF: CGFloat) -> CGFloat {
        
        resIndependantF * renderSize.width
    }
    
    func rendererObjectSize(from resIndependantSize: CGFloat) -> CGFloat {
        
        resIndependantSize * renderSize.height/2*0.7
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
    
    func render(_ scene: OpticsScene, activeDevice: OpticsDevice?) {
        
        drawAxis()
        
        for object in scene.objects {
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
        
        if let object = scene.objects.first {
            
            let devices = devicesByPosition
                .filter { $0.pos > object.pos }
            
            // compute images
            
            for i in 0..<devices.count {
                
                let currentDevice = devices[i]
                let deviceAfter = i+1 < devices.count ? devices[i+1] : nil
                
                if currentDevice is Screen {
                    break
                }
                
                let image = image(of: images.last ?? object, through: currentDevice)
                
                images.append(image)
                
                var imageIsVirtual = false
                
                if image.pos <  currentDevice.pos {
                    
                    imageIsVirtual = true
                }
                
                if let deviceAfter = deviceAfter,
                   image.pos > deviceAfter.pos {
                    
                    imageIsVirtual = true
                }
                
                draw(image, virtual: imageIsVirtual)
            }
            
            // draw rays
            
            let objectOrImages = [object] + images
            
            for i1 in 0..<objectOrImages.count {
            
//                if ![1].contains(i1) { continue }
                
                let currentSource = objectOrImages[i1]
                
                let deviceBefore = (i1-1) >= 0 ? devices[i1-1] : nil
                let deviceAfter = i1 < devices.count ? devices[i1] : nil
                
                guard let deviceAfter = deviceAfter else {
                    
                    break
                }
                
                if deviceAfter is Screen,
                   currentSource is Image {
                    
                    break
                }
                
                if let activeDevice = activeDevice,
                   deviceAfter.id != activeDevice.id {
                    
                    continue
                }
                 
                let currentSourcePos = rendererPos(from: currentSource.pos)
                let currentSourceSize = rendererObjectSize(from: currentSource.size)
                let currentSourceTop = CGPoint(x: currentSourcePos, y: currentSourceSize)
                
                let deviceBeforePos = deviceBefore != nil ? rendererPos(
                    from: deviceBefore!.pos
                ) : nil
                let deviceAfterPos = rendererPos(from: deviceAfter.pos)
                
                let deviceAfterCenter = CGPoint(x: deviceAfterPos, y: 0)
                
                let deviceAfterFocalLength = deviceAfter is Lense
                    ? rendererFocalLength(from: (deviceAfter as! Lense).focalLength)
                    : nil
                
                let deviceAfterFocalPoint = deviceAfter is Lense
                    ? CGPoint(x: deviceAfterPos - deviceAfterFocalLength!, y: 0)
                    : nil
                
                var pointsOnDeviceBefore: [RayPoint] = []
                var pointsOnDeviceAfter: [RayPoint] = []
                
                // parallel ray
                
                var generateParallelRay = false
                
                if let lense = deviceAfter as? Lense, lense.generatesParallelRay {
                    generateParallelRay = true
                }
                if deviceAfter is Screen {
                    generateParallelRay = true
                }
                if generateParallelRay {
                    
                    let parallelRay = Ray(
                        horizontalFrom: currentSourceTop
                    )
                    
                    let pointFromHorizontalOnDeviceAfter = parallelRay.point(
                        atX: deviceAfterPos
                    )
                    
                    if let deviceBeforePos = deviceBeforePos,
                       currentSourcePos < deviceBeforePos {
                        
                        draw(
                            parallelRay,
                            betweenX: deviceBeforePos, andX: deviceAfterPos
                        )
                        
                        draw(
                            parallelRay,
                            betweenX: currentSourcePos, andX: deviceBeforePos,
                            virtual: true
                        )
                        
                    } else {
                        
                        draw(
                            parallelRay,
                            betweenX: currentSourcePos, andX: deviceAfterPos
                        )
                    }
                    
                    // continue rays forward through all devices
                    
                    var rayPoint = RayPoint(p: pointFromHorizontalOnDeviceAfter, type: .parallel)
                    
                    for i2 in (i1+1)..<objectOrImages.count {
                        
                        let currentSource = objectOrImages[i2]
                        let currentSourcePos = rendererPos(from: currentSource.pos)
                        let currentSourceSize = rendererObjectSize(from: currentSource.size)
                        let currentSourceTop = CGPoint(x: currentSourcePos, y: currentSourceSize)
                        
                        let deviceBefore = (i2-1) >= 0 ? devices[i2-1] : nil
                        let deviceBeforePos = deviceBefore != nil ? rendererPos(
                            from: deviceBefore!.pos
                        ) : nil
                        
                        let deviceBeforeFocalLength = deviceBefore is Lense
                            ? rendererFocalLength(from: (deviceBefore as! Lense).focalLength)
                            : nil
                        
                        let deviceBeforeFocalPointBefore = deviceBefore is Lense
                            ? CGPoint(x: deviceBeforePos! - deviceBeforeFocalLength!, y: 0)
                            : nil
                        let deviceBeforeFocalPointAfter = deviceBefore is Lense
                            ? CGPoint(x: deviceBeforePos! + deviceBeforeFocalLength!, y: 0)
                            : nil
                        
                        let deviceAfter = i2 < devices.count ? devices[i2] : nil
                        let deviceAfterPos = deviceAfter != nil ? rendererPos(
                            from: deviceAfter!.pos
                        ) : nil
                        
                        let ray = Ray(
                            from: rayPoint.p, to: currentSourceTop
                        )
                        
                        let endPoint = ray.point(
                            atX: deviceAfterPos ?? renderSize.width
                        )

                        draw(
                            ray,
                            betweenX: rayPoint.p.x,
                            andX: deviceAfterPos ?? renderSize.width
                        )
                        
                        if let lense = deviceBefore as? Lense,
                           lense.type == .divergent {
                         
                            draw(
                                ray,
                                betweenX: deviceBeforeFocalPointBefore!.x,
                                andX: rayPoint.p.x,
                                virtual: true
                            )
                        }
                        
                        if let lense = deviceBefore as? Lense,
                           lense.type == .convergent,
                           currentSourcePos < deviceBeforePos!
                        {
                            draw(
                                ray,
                                betweenX: currentSourcePos,
                                andX: rayPoint.p.x,
                                virtual: true
                            )
                        }
                        
                        if let lense = deviceBefore as? Lense,
                           lense.type == .convergent,
                           let deviceAfterPos = deviceAfterPos,
                           deviceBeforeFocalPointAfter!.x > deviceAfterPos
                        {
                            draw(
                                ray,
                                betweenX: deviceAfterPos,
                                andX: deviceBeforeFocalPointAfter!.x,
                                virtual: true
                            )
                        }
                        
                        if let deviceAfterPos = deviceAfterPos,
                           currentSourcePos > deviceAfterPos {
                            
                            draw(
                                ray,
                                betweenX: deviceAfterPos,
                                andX: currentSourcePos,
                                virtual: true
                            )
                        }
                        
                        rayPoint = RayPoint(p: endPoint, type: rayPoint.type)
                    }
                    
                    // continue rays backwards through all devices
                
                    if let lense = deviceAfter as? Lense,
                       lense.retroPropagatesRays,
                       let deviceBeforePos = deviceBeforePos {
                        
                        if currentSourcePos > deviceBeforePos {
                            
                            draw(
                                parallelRay,
                                betweenX: deviceBeforePos, andX: currentSourcePos
                            )
                        }
                        
                        let pointFromHorizontalOnDeviceBefore = parallelRay.point(
                            atX: deviceBeforePos
                        )
                        
                        var rayPoint = RayPoint(p: pointFromHorizontalOnDeviceBefore, type: .parallel)

                        for i2 in 0..<i1 {

                            let i3 = i1-1-i2
                            
                            let currentSource = objectOrImages[i3]
                            let currentSourcePos = rendererPos(from: currentSource.pos)
                            let currentSourceSize = rendererObjectSize(from: currentSource.size)
                            let currentSourceTop = CGPoint(x: currentSourcePos, y: currentSourceSize)
                            
                            let deviceBefore = (i3-1) >= 0 ? devices[i3-1] : nil
                            let deviceBeforePos = deviceBefore != nil ? rendererPos(
                                from: deviceBefore!.pos
                            ) : nil
                            
                            let ray = Ray(
                                from: currentSourceTop, to: rayPoint.p
                            )
                            
                            let startPoint = ray.point(
                                atX: deviceBeforePos ?? currentSourcePos
                            )

                            draw(
                                ray,
                                betweenX: deviceBeforePos ?? currentSourcePos,
                                andX: rayPoint.p.x
                            )
                            
                            rayPoint = RayPoint(p: startPoint, type: rayPoint.type)
                        }
                    }
//                    
//                    
//                    
//                    
//                    
//                    pointsOnDeviceBefore.append(RayPoint(
//                        p: pointFromHorizontalOnDeviceAfter, type: .parallel
//                    ))
//                
//                    
//                    
//                    pointsOnDeviceAfter.append(RayPoint(
//                        p: pointFromHorizontalOnDeviceBefore, type: .parallel
//                    ))
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
                
                for i2 in (i1+1)..<objectOrImages.count {

                    if ![].contains(i2) { continue }
                    
                    let currentImage = objectOrImages[i2]
                    let previousImage = (i2-1) >= 0 ? objectOrImages[i2-1] : nil
                    
                    let deviceBefore = (i2-1) >= 0 ? devices[i2-1] : nil
                    let deviceAfter = i2 < devices.count ? devices[i2] : nil
                    
                    let imagePos = rendererPos(from: currentImage.pos)
                    let imageSize = rendererObjectSize(from: currentImage.size)
                    let imageTop = CGPoint(x: imagePos, y: imageSize)
                    
                    let previousImagePos = rendererPos(from: previousImage?.pos ?? 0)
                    
                    let deviceBeforePos = rendererPos(
                        from: deviceBefore?.pos ?? currentImage.pos
                    )
                    let deviceAfterPos = rendererPos(
                        from: deviceAfter?.pos ?? currentImage.pos
                    )
                    
                    var pointsOnDeviceAfter: [RayPoint] = []

                    for pointOnDeviceBefore in pointsOnDeviceBefore {

                        let pointOnDeviceAfter = Ray(
                            from: pointOnDeviceBefore.p, to: imageTop
                        ).point(
                            atX: deviceAfterPos
                        )

                        drawRay(
                            from: pointOnDeviceBefore.p,
                            to: pointOnDeviceAfter
                        )
                        
                        if imagePos < deviceBeforePos {
                            
                            if pointOnDeviceBefore.type == .center,
                               previousImage != nil,
                               let lense = deviceBefore as? Lense, lense.type == .convergent {
                                
                                drawRay(
                                    from: pointOnDeviceBefore.p,
                                    to: pointOnDeviceAfter,
                                    minX: imagePos, maxX: previousImagePos,
                                    virtual: true
                                )
                                
                            } else if pointOnDeviceBefore.type != .center,
                                      pointOnDeviceBefore.type != .parallel {
                             
                                drawRay(
                                    from: pointOnDeviceBefore.p,
                                    to: pointOnDeviceAfter,
                                    minX: imagePos, maxX: deviceBeforePos,
                                    virtual: true
                                )
                            }
                        }
                        
                        if imagePos > deviceAfterPos {
                            
                            drawRay(
                                from: pointOnDeviceBefore.p,
                                to: pointOnDeviceAfter,
                                minX: deviceAfterPos, maxX: imagePos,
                                virtual: true
                            )
                        }

                        pointsOnDeviceAfter.append(RayPoint(
                            p: pointOnDeviceAfter, type: pointOnDeviceBefore.type
                        ))
                    }

                    pointsOnDeviceBefore = pointsOnDeviceAfter
                }
                
                // continue rays backwards through all devices
                
                if let lense = deviceAfter as? Lense,
                   lense.retroPropagatesRays {
                    
                    for i2 in 0..<i1 {
                        
                        let i3 = i1-1-i2
                        
                        if ![].contains(i3) { continue }
                        
                        let currentImage = objectOrImages[i3]
                        
                        let deviceBefore = (i3-1) >= 0 ? devices[i3-1] : nil
                        
                        let imagePos = rendererPos(from: currentImage.pos)
                        let imageSize = rendererObjectSize(from: currentImage.size)
                        let imageTop = CGPoint(x: imagePos, y: imageSize)
                        
                        let deviceBeforePos = rendererPos(
                            from: deviceBefore?.pos ?? currentImage.pos
                        )
                        
                        var pointsOnDeviceBefore: [RayPoint] = []
                        
                        for pointOnDeviceAfter in pointsOnDeviceAfter {
                            
                            let pointOnDeviceBefore = Ray(
                                from: pointOnDeviceAfter.p, to: imageTop
                            ).point(
                                atX: deviceBeforePos
                            )
                            
                            drawRay(
                                from: pointOnDeviceBefore,
                                to: pointOnDeviceAfter.p
                            )
                            
                            pointsOnDeviceBefore.append(RayPoint(
                                p: pointOnDeviceBefore, type: pointOnDeviceAfter.type
                            ))
                        }
                        
                        pointsOnDeviceAfter = pointsOnDeviceBefore
                    }
                }
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
