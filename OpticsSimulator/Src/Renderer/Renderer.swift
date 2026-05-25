
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
    
    func computeImages(
        
        of object: Object, through devices: [OpticsDevice]
        
    ) -> [Image] {
        
        var images: [Image] = []
        
        for i in 0..<devices.count {
            
            let currentDevice = devices[i]
            let nextDevice = i+1 < devices.count ? devices[i+1] : nil
            
            if currentDevice is Screen {
                break
            }
            
            let currentSource = images.last ?? object
            let image = image(of: currentSource, through: currentDevice)
            
            if image.pos < currentDevice.pos {
                
                image.virtual = true
            }
            
            if let nextDevice = nextDevice,
               image.pos > nextDevice.pos {
                
                image.virtual = true
            }
            
            images.append(image)
        }
        
        return images
    }
    
    func render(_ scene: OpticsScene) {
        
        // compute images and rays
        
        let enabledObjects = scene.objects
            .filter({ $0.enabled })
        
        let enabledDevicesByPosition = scene.devices
            .filter { $0.enabled }
            .sorted { $0.pos < $1.pos }
        
        var allImagesOfAllObjects: [Image] = []
        var allRayDescriptors: [RayDescriptor] = []
        
        for currentObject in enabledObjects {
            
            let relevantDevicesForCurrentObject = enabledDevicesByPosition
                .filter { device in device.pos > currentObject.pos }
            
            // compute images
            
            let allImagesOfCurrentObject = computeImages(
                of: currentObject, through: relevantDevicesForCurrentObject
            )
            allImagesOfAllObjects.append(
                contentsOf: allImagesOfCurrentObject
            )
            
            // compute rays
            
            let sources = [currentObject] + allImagesOfCurrentObject
            let devices = relevantDevicesForCurrentObject
            
            for sourceIndex in 0..<sources.count {
                
                // generate rays from source
                
                let iterator = getLoopIterator(
                    for: sources, devices, at: sourceIndex
                )
                
                if !iterator.hasCurrentDevice {
                    break
                }
                
                let info = iterator.currentDeviceInfo!
                let currentDevice = info.device!
                let currentDevicePos = info.pos!
                let currentDeviceCenter = info.center!
                
                let currentSource = iterator.currentSource
                let currentSourcePos = iterator.currentSourcePos
                let currentSourceTop = iterator.currentSourceTop
                
                if currentDevice is Screen,
                   currentSource is Image {
                    
                    break
                }
                
                let previousDevice = iterator.previousDeviceInfo?.device
                let previousDevicePos = iterator.previousDeviceInfo?.pos
                
                var rayPointsOnPreviousDevice: [RayPoint] = []
                var rayPointsOnCurrentDevice: [RayPoint] = []
                
                // parallel ray
                
                let generateParallelRay: Bool = {
                    
                    if let lense = currentDevice as? Lense,
                       lense.generatesParallelRay {
                        
                        return true
                    }
                    if currentDevice is Screen {
                        
                        return true
                    }
                    return false
                }()
                if generateParallelRay {
                    
                    let ray = Ray(
                        horizontalFrom: currentSourceTop
                    )
                    
                    var pointsForRay: [PointDescriptor] = [
                        
                        PointDescriptor(
                            device: nil,
                            source: currentSource,
                            type: .top,
                            point: ray.point(atX: currentSourcePos)
                        ),
                        PointDescriptor(
                            device: currentDevice,
                            source: nil,
                            type: .undefined,
                            point: ray.point(atX: currentDevicePos)
                        ),
                    ]
                    
                    let pointFromRayOnCurrentDevice =
                    ray.point(
                        atX: currentDevicePos
                    )
                    
                    rayPointsOnCurrentDevice.append(RayPoint(
                        p: pointFromRayOnCurrentDevice,
                        type: .parallel,
                        sourceDevice: currentDevice,
                        source: currentSource,
                        horizontalIncidence: true
                    ))
                    
                    let retroPropagateRays: Bool = {
                        if let lense = currentDevice as? Lense,
                           lense.retroPropagatesRays {
                            return true
                        }
                        return false
                    }()
                    
                    if retroPropagateRays,
                       let previousDevicePos = previousDevicePos {
                        
                        pointsForRay.append(PointDescriptor(
                            device: previousDevice,
                            source: nil,
                            type: .undefined,
                            point: ray.point(atX: previousDevicePos)
                        ))
                        
                        let pointFromRayOnPreviousDevice =
                        ray.point(
                            atX: previousDevicePos
                        )
                        
                        rayPointsOnPreviousDevice.append(RayPoint(
                            p: pointFromRayOnPreviousDevice,
                            type: .parallel,
                            sourceDevice: currentDevice,
                            source: currentSource,
                            horizontalIncidence: true
                        ))
                    }
                    
                    allRayDescriptors.append(RayDescriptor(
                        deviceBefore: previousDevice,
                        deviceAfter: currentDevice,
                        points: pointsForRay
                    ))
                }
                
                // center ray
                
                let generateCenterRay: Bool = {
                    
                    if let lense = currentDevice as? Lense,
                       lense.generatesCenterRay {
                        
                        return true
                    }
                    if currentDevice is Screen {
                        
                        return true
                    }
                    return false
                }()
                if generateCenterRay {
                    
                    let ray = Ray(
                        from: currentSourceTop,
                        to: currentDeviceCenter,
                    )
                    
                    var pointsForRay: [PointDescriptor] = [
                        
                        PointDescriptor(
                            device: nil,
                            source: currentSource,
                            type: .top,
                            point: ray.point(atX: currentSourcePos)
                        ),
                        PointDescriptor(
                            device: currentDevice,
                            source: nil,
                            type: .center,
                            point: ray.point(atX: currentDevicePos)
                        )
                    ]
                    
                    let pointFromRayOnCurrentDevice =
                    ray.point(
                        atX: currentDevicePos
                    )
                    
                    rayPointsOnCurrentDevice.append(RayPoint(
                        p: pointFromRayOnCurrentDevice,
                        type: .center,
                        sourceDevice: currentDevice,
                        source: currentSource
                    ))
                    
                    let retroPropagateRays: Bool = {
                        if let lense = currentDevice as? Lense,
                           lense.retroPropagatesRays {
                            return true
                        }
                        return false
                    }()
                    
                    if retroPropagateRays,
                       let previousDevicePos = previousDevicePos {
                        
                        pointsForRay.append(PointDescriptor(
                            device: previousDevice,
                            source: nil,
                            type: .undefined,
                            point: ray.point(atX: previousDevicePos)
                        ))
                        
                        let pointFromRayOnPreviousDevice =
                        ray.point(
                            atX: previousDevicePos
                        )
                        
                        rayPointsOnPreviousDevice.append(RayPoint(
                            p: pointFromRayOnPreviousDevice,
                            type: .center,
                            sourceDevice: currentDevice,
                            source: currentSource
                        ))
                    }
                    
                    allRayDescriptors.append(RayDescriptor(
                        deviceBefore: previousDevice,
                        deviceAfter: currentDevice,
                        points: pointsForRay
                    ))
                }
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
                
                for __rayPoint in rayPointsOnCurrentDevice {
                    
                    var rayPointOnPreviousDevice = __rayPoint
                    
                    for sourceIndexForward in (sourceIndex+1)..<sources.count {
                        
                        let iterator = getLoopIterator(
                            for: sources, devices, at: sourceIndexForward
                        )
                        let currentSourcePos = iterator.currentSourcePos
                        let currentSourceTop = iterator.currentSourceTop
                        
                        let currentDeviceInfo = iterator.currentDeviceInfo
                        let currentDevice = currentDeviceInfo?.device
                        let currentDevicePos = currentDeviceInfo?.pos
                        
                        let previousDeviceInfo = iterator.previousDeviceInfo!
                        let previousDevice = previousDeviceInfo.device!
                        let previousDeviceFocalPointBefore = previousDeviceInfo.focalPointBefore
                        let previousDeviceFocalPointAfter = previousDeviceInfo.focalPointAfter
                        
                        let previousDeviceIsRaySource =
                        previousDevice.id == rayPointOnPreviousDevice.sourceDevice.id
                        
                        let ray = Ray(
                            from: rayPointOnPreviousDevice.p,
                            to: currentSourceTop
                        )
                        let endX = currentDevicePos ?? renderSize.width
                        
                        var pointsForRay: [PointDescriptor] = [
                            
                            PointDescriptor(
                                device: previousDevice,
                                source: nil,
                                type: rayPointOnPreviousDevice.type == .center ? .center : .undefined,
                                point: ray.point(atX: rayPointOnPreviousDevice.p.x)
                            ),
                            PointDescriptor(
                                device: currentDevice,
                                source: nil,
                                type: .undefined,
                                point: ray.point(atX: endX)
                            ),
                            PointDescriptor(
                                device: nil,
                                source: currentSource,
                                type: .top,
                                point: ray.point(atX: currentSourcePos)
                            )
                        ]
                        
                        if previousDeviceIsRaySource,
                           let lense = previousDevice as? Lense,
                           lense.type == .convergent,
                           rayPointOnPreviousDevice.type == .center
                        {
                            pointsForRay.append(PointDescriptor(
                                device: nil,
                                source: iterator.previousSource!,
                                type: .top,
                                point: ray.point(atX: iterator.previousSourcePos!)
                            ))
                        }
                        
                        if let lense = previousDevice as? Lense,
                           lense.type == .divergent,
                           rayPointOnPreviousDevice.hasParallelIncidence
                        {
                            pointsForRay.append(PointDescriptor(
                                device: previousDevice,
                                source: nil,
                                type: .focalPointBefore,
                                point: ray.point(atX: previousDeviceFocalPointBefore!.x)
                            ))
                        }
                        
                        if let lense = previousDevice as? Lense,
                           lense.type == .convergent,
                           rayPointOnPreviousDevice.hasParallelIncidence
                        {
                            pointsForRay.append(PointDescriptor(
                                device: previousDevice,
                                source: nil,
                                type: .focalPointAfter,
                                point: ray.point(atX: previousDeviceFocalPointAfter!.x)
                            ))
                        }
                        
                        allRayDescriptors.append(RayDescriptor(
                            deviceBefore: previousDevice,
                            deviceAfter: currentDevice,
                            points: pointsForRay
                        ))
                        
                        rayPointOnPreviousDevice = RayPoint(
                            p: ray.point(atX: endX),
                            type: .undefined,
                            sourceDevice: rayPointOnPreviousDevice.sourceDevice
                        )
                    }
                }
                
                // continue rays backwards through all devices
                
                for __rayPoint in rayPointsOnPreviousDevice {
                    
                    var rayPointOnCurrentDevice = __rayPoint
                    
                    for i in 0..<sourceIndex {
                        let sourceIndexBackwards = sourceIndex-1-i
                        
                        let iterator = getLoopIterator(
                            for: sources, devices, at: sourceIndexBackwards
                        )
                        
                        let currentSourcePos = iterator.currentSourcePos
                        let currentSourceTop = iterator.currentSourceTop
                        
                        let currentDeviceInfo = iterator.currentDeviceInfo!
                        let currentDevice = currentDeviceInfo.device!
                        
                        let previousDeviceInfo = iterator.previousDeviceInfo
                        let previousDevice = previousDeviceInfo?.device
                        let previousDevicePos = previousDeviceInfo?.pos
                        
                        let ray = Ray(
                            from: currentSourceTop,
                            to: rayPointOnCurrentDevice.p
                        )
                        
                        let startX = previousDevicePos ?? currentSourcePos
                        
                        let pointsForRay: [PointDescriptor] = [
                            
                            PointDescriptor(
                                device: nil,
                                source: nil,
                                type: .undefined,
                                point: ray.point(atX: startX)
                            ),
                            PointDescriptor(
                                device: currentDevice,
                                source: nil,
                                type: .undefined,
                                point: ray.point(atX: rayPointOnCurrentDevice.p.x)
                            ),
                        ]
                        
                        allRayDescriptors.append(RayDescriptor(
                            deviceBefore: previousDevice,
                            deviceAfter: currentDevice,
                            points: pointsForRay
                        ))
                        
                        rayPointOnCurrentDevice = RayPoint(
                            p: ray.point(atX: startX),
                            type: .undefined,
                            sourceDevice: rayPointOnCurrentDevice.sourceDevice
                        )
                    }
                }
            }
        }
        
        // draw
        
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
        for image in allImagesOfAllObjects {
            draw(image, virtual: image.virtual)
        }
        drawRays(from: allRayDescriptors)
        
        
        
        
        //        if let object = scene.objects.first,
        //           let mirror = scene.mirrors.first {
        //
        //            images.append(image(of: object, through: mirror))
        //        }
        
        
        // draw rays
        
        let object = scene.objects.first
        let mirror = scene.mirrors.first
        let image = allImagesOfAllObjects.first
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
    
    
    func getLoopIterator(
        
        for sources: [ObjectOrImage], _ devices: [OpticsDevice],
        at sourceIndex: Int
        
    ) -> LoopIterator {
        
        // current source
        
        let currentSource = sources[sourceIndex]
        
        let currentSourcePos = resolvedPos(
            from: currentSource.pos
        )
        let currentSourceSize = resolvedObjectSize(
            from: currentSource.size
        )
        let currentSourceTop = CGPoint(
            x: currentSourcePos, y: currentSourceSize
        )
        
        // previous source
        
        let previousSource = sourceIndex-1 >= 0 ? sources[sourceIndex-1] : nil
        
        let previousSourcePos = previousSource != nil
        ? resolvedPos(
            from: previousSource!.pos
        ) : nil
        
        let previousSourceSize = previousSource != nil
        ? resolvedObjectSize(
            from: previousSource!.size
        ) : nil
        
        let previousSourceTop = previousSource != nil
        ? CGPoint(
            x: previousSourcePos!, y: previousSourceSize!
        ) : nil
        
        // current device
        
        let currentDevice = sourceIndex < devices.count ? devices[sourceIndex] : nil
        
        let currentDeviceInfo = getDeviceInfo(currentDevice)
        
        // previous device
        
        let previousDevice = (sourceIndex-1) >= 0 ? devices[sourceIndex-1] : nil
        
        let previousDeviceInfo = getDeviceInfo(previousDevice)
        
        //
        
        let loop = LoopIterator(
            
            currentSource: currentSource,
            currentSourcePos: currentSourcePos,
            currentSourceSize: currentSourceSize,
            currentSourceTop: currentSourceTop,
            
            previousSource: previousSource,
            previousSourcePos: previousSourcePos,
            previousSourceSize: previousSourceSize,
            previousSourceTop: previousSourceTop,
            
            hasCurrentDevice: currentDevice != nil,
            currentDeviceInfo: currentDeviceInfo,
            
            hasPreviousDevice: previousDevice != nil,
            previousDeviceInfo: previousDeviceInfo,
        )
        
        return loop
    }
    
    
    func getDeviceInfo(_ device: OpticsDevice?) -> DeviceInfo {
        
        let devicePos = device != nil
        ? resolvedPos(
            from: device!.pos
        ) : nil
        
        let deviceCenter = device != nil
        ? CGPoint(
            x: devicePos!, y: 0
        ) : nil
        
        let deviceFocalLength = device is Lense
        ? resolvedFocalLength(
            from: (device as! Lense).focalLength
        ) : nil
        
        let deviceFocalPointBefore = device is Lense
        ? CGPoint(
            x: devicePos! - deviceFocalLength!, y: 0
        ) : nil
        
        let deviceFocalPointAfter = device is Lense
        ? CGPoint(
            x: devicePos! + deviceFocalLength!, y: 0
        ) : nil
        
        let info = DeviceInfo(
            device: device,
            pos: devicePos,
            center: deviceCenter,
            focalLength: deviceFocalLength,
            focalPointBefore: deviceFocalPointBefore,
            focalPointAfter: deviceFocalPointAfter
        )
        
        return info
    }
    
    
    func drawRays(
        
        from rayDescriptors: [RayDescriptor]
        
    ) {
        
        var raySegments = getRaySegments(
            from: rayDescriptors
        )
        
        raySegments = deduplicate(
            raySegments
        )
        
        drawRays(from: raySegments)
    }
    
    
    func drawRays(
    
        from raySegments: [RaySegment]
        
    ) {
        
        for segment in raySegments {
            
            let p1 = segment.p1
            let p2 = segment.p2
            let virtual = segment.virtual
            
            draw(
                Ray(
                    from: p1.point,
                    to: p2.point
                ),
                minX: p1.point.x,
                maxX: p2.point.x,
                virtual: virtual
            )
        }
    }
    
    
    func deduplicate(
        
        _ rawRaySegments: [RaySegment]
        
    ) -> [RaySegment] {
        
        var cleanRaySegments: [RaySegment] = []
        
        for candidateSegment in rawRaySegments {
            
            if !candidateSegment.virtual {
                
                cleanRaySegments.removeAll(where: {
                    
                    $0.isVisuallySame(as: candidateSegment)
                })
                cleanRaySegments.append(candidateSegment)
                
            } else {
                
                let existing = cleanRaySegments.first {
                    
                    $0.isVisuallySame(as: candidateSegment)
                }
                
                if existing == nil {
                    
                    cleanRaySegments.append(candidateSegment)
                }
            }
        }
        
        return cleanRaySegments
    }
    
    
    func getRaySegments(
        
        from rayDescriptors: [RayDescriptor]
        
    ) -> [RaySegment] {
        
        var raySegments: [RaySegment] = []
        
        for rayDescriptor in rayDescriptors {
            
            let pointsBeforeDevice = rayDescriptor.points
                .filter { pointDescriptor in
                    if let deviceBefore = rayDescriptor.deviceBefore {
                        return pointDescriptor.point.x <= resolvedPos(from: deviceBefore.pos)
                    }
                    return false
                }
                .sorted { $0.point.x < $1.point.x }
            
            let pointsBetweenDevices = rayDescriptor.points
                .filter { pointDescriptor in
                    
                    if let deviceBefore = rayDescriptor.deviceBefore,
                       let deviceAfter = rayDescriptor.deviceAfter {
                        
                        return (
                            pointDescriptor.point.x >= resolvedPos(from: deviceBefore.pos)
                            &&
                            pointDescriptor.point.x <= resolvedPos(from: deviceAfter.pos)
                        )
                        
                    } else if let deviceBefore = rayDescriptor.deviceBefore {
                        
                        return pointDescriptor.point.x >= resolvedPos(from: deviceBefore.pos)
                        
                    } else if let deviceAfter = rayDescriptor.deviceAfter {
                        
                        return pointDescriptor.point.x <= resolvedPos(from: deviceAfter.pos)
                    }
                    return true
                }
                .sorted { $0.point.x < $1.point.x }
            
            let pointsAfterDevice = rayDescriptor.points
                .filter { pointDescriptor in
                    if let deviceAfter = rayDescriptor.deviceAfter {
                        return pointDescriptor.point.x >= resolvedPos(from: deviceAfter.pos)
                    }
                    return false
                }
                .sorted { $0.point.x < $1.point.x }
            
            raySegments.append(
                contentsOf: getRaySegments(
                    from: pointsBeforeDevice, virtual: true
                )
            )
            raySegments.append(
                contentsOf: getRaySegments(
                    from: pointsBetweenDevices, virtual: false
                )
            )
            raySegments.append(
                contentsOf: getRaySegments(
                    from: pointsAfterDevice, virtual: true
                )
            )
        }
        
        return raySegments
    }
    
    
    func getRaySegments(
        
        from pointDescriptors: [PointDescriptor], virtual: Bool
        
    ) -> [RaySegment] {
        
        var raySegments: [RaySegment] = []
        
        if pointDescriptors.count > 1 {
            
            for i in 0..<(pointDescriptors.count-1) {
                
                let p1 = pointDescriptors[i]
                let p2 = pointDescriptors[i+1]
                
                raySegments.append(RaySegment(
                    p1: p1, p2: p2, virtual: virtual
                ))
            }
        }
        
        return raySegments
    }
}



enum ArrowDirection {
    
    case towardAxis, awayFromAxis
}


struct LoopIterator {
    
    let currentSource: ObjectOrImage
    let currentSourcePos: CGFloat
    let currentSourceSize: CGFloat
    let currentSourceTop: CGPoint
    
    let previousSource: ObjectOrImage?
    let previousSourcePos: CGFloat?
    let previousSourceSize: CGFloat?
    let previousSourceTop: CGPoint?
    
    let hasCurrentDevice: Bool
    let currentDeviceInfo: DeviceInfo?
    
    let hasPreviousDevice: Bool
    let previousDeviceInfo: DeviceInfo?
}

struct DeviceInfo {
    
    let device: OpticsDevice?
    let pos: CGFloat?
    let center: CGPoint?
    let focalLength: CGFloat?
    let focalPointBefore: CGPoint?
    let focalPointAfter: CGPoint?
}
