
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
    
    func draw(_ mirror: Mirror) {
        
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
        
        let n = 15
        for i in 0...n {
            
            let hi: CGFloat = -h + CGFloat(i)*2*h/CGFloat(n)
            
            path.move(to: CGPoint(x: x, y: hi))
            path.addLine(to: CGPoint(x: x+a, y: hi-a))
        }
        
        if mirror.type == .concave {
            
            // arrows
            path.move(to: CGPoint(x: x-2*a, y: h+2*a))
            path.addLine(to: CGPoint(x: x, y: h))
            
            path.move(to: CGPoint(x: x, y: -h))
            path.addLine(to: CGPoint(x: x-2*a, y: -h-2*a))
            
            // focal indicator
            path.move(to: CGPoint(x: x-f, y: -m))
            path.addLine(to: CGPoint(x: x-f, y: +m))
            
            // center indicator
            path.move(to: CGPoint(x: x-2*f, y: -m))
            path.addLine(to: CGPoint(x: x-2*f, y: +m))
        }
        
        if mirror.type == .convex {
            
            // arrows
            path.move(to: CGPoint(x: x, y: h))
            path.addLine(to: CGPoint(x: x+2*a, y: h+2*a))
            
            path.move(to: CGPoint(x: x, y: -h))
            path.addLine(to: CGPoint(x: x+2*a, y: -h-2*a))
            
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
        virtual: Bool = false,
        lineWidth: CGFloat = 1, opacity: CGFloat = 1
        
    ) {
        
        draw(
            Ray(from: p1, to: p2),
            minX: minX ?? p1.x, maxX: maxX ?? p2.x,
            virtual: virtual,
            lineWidth: lineWidth, opacity: opacity
        )
    }
    
    func draw(
        
        _ ray: Ray,
        minX: CGFloat, maxX: CGFloat,
        virtual: Bool = false,
        lineWidth: CGFloat = 1, opacity: CGFloat = 1
        
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
        
        context.stroke(
            path,
            with: .color(.yellow.opacity(opacity)),
            style: StrokeStyle(
                lineWidth: lineWidth,
                dash: virtual ? [4, 4] : []
            )
        )
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
        
        if let mirror = device as? Mirror {
            
            if mirror.type == .plane {
                
                imagePos = mirror.pos + (mirror.pos - object.pos)
                imageSize = object.size
                
                return Image(pos: imagePos, size: imageSize)
            }
            
            if mirror.type == .concave || mirror.type == .convex {
                
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
            
            if currentDevice is Mirror {
                
                image.virtual = true
            }
            
            images.append(image)
        }
        
        return images
    }
    
    
    func devicesSequence(
        
        for object: Object,
        from allPossibleDevices: [OpticsDevice]
    
    ) -> [OpticsDevice] {
        
        let devicesByPosition = allPossibleDevices
            .sorted { $0.pos < $1.pos }
        
        var devicesSequence: [OpticsDevice] = []
        
        if let i0 = devicesByPosition.firstIndex(where: {
            device in device.pos > object.pos
        }) {
            
            var i = i0
            
            var propagatesRight = true
            
            while true {
                
                if i<0 || i>=devicesByPosition.count {
                    break
                }
                
                let device = devicesByPosition[i]
                
                devicesSequence.append(device)
                
                if device is Mirror {
                    
                    propagatesRight.toggle()
                }
                
                if propagatesRight {
                    i += 1
                } else {
                    i -= 1
                }
            }
        }
        
        return devicesSequence
    }
    
    
    func render(
        
        _ scene: OpticsScene,
        
        showImages: Bool,
        showVirtualImages: Bool,
        showConstructionRays: Bool,
        
        mouse: CGPoint
    
    ) {
        // compute images and rays
        
        let enabledObjects = scene.objects
            .filter({ $0.enabled })
        
        let enabledDevicesByPosition = scene.devices
            .filter { $0.enabled }
            .sorted { $0.pos < $1.pos }
        
        var allImagesOfAllObjects: [Image] = []
        var allRayDescriptors: [RayDescriptor] = []
        
        for currentObject in enabledObjects {
            
            let relevantDevicesForCurrentObject = devicesSequence(
                for: currentObject, from: enabledDevicesByPosition
            )
            
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
                
                let loop = getLoopIterator(
                    for: sources, devices, at: sourceIndex
                )
                
                if loop.currentDevice == nil {
                    break
                }
                
                if loop.currentDevice! is Screen,
                   loop.currentSource is Image {
                    
                    break
                }
                
                var rayPointsOnPreviousDevice: [RayPoint] = []
                var rayPointsOnCurrentDevice: [RayPoint] = []
                
                var rays: [(
                    ray: Ray,
                    horizontalIncidence: Bool,
                    points: [CGFloat]
                )] = []
                
                if shouldGenerateParallelRay(to: loop.currentDevice!) {
                    
                    rays.append((
                        ray: Ray(
                            horizontalFrom: loop.currentSourceTop
                        ),
                        horizontalIncidence: true,
                        points: []
                    ))
                }
                
                if shouldGenerateCenterRay(to: loop.currentDevice!) {
                    
                    rays.append((
                        ray: Ray(
                            from: loop.currentSourceTop,
                            to: loop.currentDeviceCenter!,
                        ),
                        horizontalIncidence: false,
                        points: []
                    ))
                }
                
                if shouldGenerateFocalRay(to: loop.currentDevice!) {
                    
                    rays.append((
                        ray: Ray(
                            from: loop.currentSourceTop,
                            to: loop.currentDeviceFocalPointBefore!,
                        ),
                        horizontalIncidence: false,
                        points: [
                            loop.currentDeviceFocalPointBefore!.x
                        ]
                    ))
                }
                
                if shouldGenerateCurveCenterRay(to: loop.currentDevice!) {
                    
                    rays.append((
                        ray: Ray(
                            from: loop.currentSourceTop,
                            to: loop.currentDeviceCurveCenterPointBefore!,
                        ),
                        horizontalIncidence: false,
                        points: [
                            loop.currentDeviceCurveCenterPointBefore!.x
                        ]
                    ))
                }
                
                for (ray, horizontalIncidence, points) in rays {
                    
                    let rayId = UUID()
                    
                    var pointsForRay: [CGPoint] = [
                        ray.point(atX: loop.currentDevicePos!),
                    ]
                    
                    if shouldConnectToSource(loop.currentSource, showImages, showVirtualImages) {
                        pointsForRay.append(ray.point(atX: loop.currentSourcePos))
                    }
                    
                    let pointFromRayOnCurrentDevice =
                    ray.point(
                        atX: loop.currentDevicePos!
                    )
                    
                    rayPointsOnCurrentDevice.append(RayPoint(
                        point: pointFromRayOnCurrentDevice,
                        rayId: rayId,
                        horizontalIncidence: horizontalIncidence,
                        
                    ))
                    
                    for x in points {
                        pointsForRay.append(ray.point(atX: x))
                    }
                    
                    if shouldRetroPropagateRays(from: loop.currentDevice!),
                       let previousDevicePos = loop.previousDevicePos {
                        
                        pointsForRay.append(
                            ray.point(atX: previousDevicePos)
                        )
                        
                        let pointFromRayOnPreviousDevice =
                        ray.point(
                            atX: previousDevicePos
                        )
                        
                        rayPointsOnPreviousDevice.append(RayPoint(
                            point: pointFromRayOnPreviousDevice,
                            rayId: rayId,
                            horizontalIncidence: horizontalIncidence
                        ))
                    }
                    
                    allRayDescriptors.append(RayDescriptor(
                        deviceBefore: loop.previousDevice,
                        deviceAfter: loop.currentDevice!,
                        propagatesRight: true,
                        source: loop.currentSource,
                        rayId: rayId,
                        points: pointsForRay
                    ))
                }
                
                // propagate rays forwards through all devices
                
                for rayPoint in rayPointsOnCurrentDevice {
                    
                    let rays = propagateRayForwards(
                        from: rayPoint,
                        sources: sources,
                        devices: devices,
                        sourceIndex: sourceIndex,
                        showImages: showImages,
                        showVirtualImages: showVirtualImages
                    )
                    
                    allRayDescriptors.append(contentsOf: rays)
                }
                
                // propagate rays backwards through all devices
                
                for rayPoint in rayPointsOnPreviousDevice {
                    
                    let rays = propagateRayBackwards(
                        from: rayPoint,
                        sources: sources,
                        devices: devices,
                        sourceIndex: sourceIndex,
                        showVirtualImages: showVirtualImages
                    )
                    
                    allRayDescriptors.append(contentsOf: rays)
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
        if showImages {
            for image in allImagesOfAllObjects {
                if showVirtualImages || !image.virtual {
                    draw(image, virtual: image.virtual)
                }
            }
        }
        drawRays(
            from: allRayDescriptors,
            showVirtualRays: showConstructionRays,
            mouse: mouse
        )
        
        
        
        
        //        if let object = scene.objects.first,
        //           let mirror = scene.mirrors.first {
        //
        //            images.append(image(of: object, through: mirror))
        //        }
        
        
        // draw rays
        
//        let object = scene.objects.first
//        let mirror = scene.mirrors.first
//        let image = allImagesOfAllObjects.first
//        let screen = scene.screens.first
        
        
//        if let object = object,
//           let mirror = mirror,
//           let image = image,
//           let screen = screen {
//            
//            let objectPos = resolvedPos(from: object.pos)
//            let objectSize = resolvedObjectSize(from: object.size)
//            let objectTop = CGPoint(x: objectPos, y: objectSize)
//            
//            let imagePos = resolvedPos(from: image.pos)
//            let imageSize = resolvedObjectSize(from: image.size)
//            let imageTop = CGPoint(x: imagePos, y: imageSize)
//            
//            let mirrorPos = resolvedPos(from: mirror.pos)
//            let f = resolvedFocalLength(from: mirror.focalLength)
//            let mirrorVertex = CGPoint(x: mirrorPos, y: 0)
//            let mirrorCenter = CGPoint(x: mirrorPos+(mirror.type == .concave ? -1 : +1)*2*f, y: 0)
//            let F = CGPoint(x: mirrorPos+(mirror.type == .concave ? -1 : +1)*f, y: 0)
//            
//            let screenPos = resolvedPos(from: screen.pos)
//            
//            // parallel ray : object > mirror
//            
//            let projectedPointOnMirror = Ray(horizontalFrom: objectTop)
//                .point(atX: mirrorPos)
//            drawRay(from: objectTop, to: projectedPointOnMirror)
//            
//            // parallel ray : mirror > F > image
//            
//            drawRay(
//                from: projectedPointOnMirror, to: F,
//                minX: screenPos, maxX: mirrorPos
//            )
//            
//            if imagePos < screenPos {
//                
//                drawRay(
//                    from: projectedPointOnMirror, to: F,
//                    minX: imagePos, maxX: screenPos,
//                    virtual: true
//                )
//            }
//            
//            if imagePos > mirrorPos {
//                
//                drawRay(
//                    from: projectedPointOnMirror, to: F,
//                    minX: mirrorPos, maxX: [imagePos, F.x].max()!,
//                    virtual: true
//                )
//            }
//            
//            // vertex ray : object > S
//            
//            drawRay(from: objectTop, to: mirrorVertex)
//            
//            // vertex ray : S > image
//            
//            drawRay(
//                from: mirrorVertex, to: imageTop,
//                minX: screenPos, maxX: mirrorPos
//            )
//            
//            if imagePos < screenPos {
//                
//                drawRay(
//                    from: mirrorVertex, to: imageTop,
//                    minX: imagePos, maxX: screenPos,
//                    virtual: true
//                )
//            }
//            
//            if imagePos > mirrorPos {
//                
//                drawRay(
//                    from: mirrorVertex, to: imageTop,
//                    minX: mirrorPos, maxX: imagePos,
//                    virtual: true
//                )
//            }
//            
//            // center ray : object > image
//            
//            drawRay(
//                from: objectTop, to: mirrorCenter,
//                minX: screenPos, maxX: mirrorPos
//            )
//            
//            if imagePos < screenPos {
//                
//                drawRay(
//                    from: objectTop, to: mirrorCenter,
//                    minX: imagePos, maxX: screenPos,
//                    virtual: true
//                )
//            }
//            
//            if imagePos > mirrorPos {
//                
//                drawRay(
//                    from: objectTop, to: mirrorCenter,
//                    minX: mirrorPos, maxX: [imagePos, mirrorCenter.x].max()!,
//                    virtual: true
//                )
//            }
//        }
    }
    
    
    func shouldGenerateParallelRay(
    
        to device: OpticsDevice
        
    ) -> Bool {
        
        if let lense = device as? Lense {
            
            return lense.generatesParallelRay
        }
        
        if let mirror = device as? Mirror {
            
            return mirror.generatesParallelRay
        }
        
        if device is Screen {
            
            return true
        }
        
        return false
    }
    
    
    func shouldGenerateCenterRay(
    
        to device: OpticsDevice
        
    ) -> Bool {
        
        if let lense = device as? Lense {
            
            return lense.generatesCenterRay
        }
        
        if let mirror = device as? Mirror {
            
            return mirror.generatesCenterRay
        }
        
        if device is Screen {
            
            return true
        }
        
        return false
    }
    
    
    func shouldGenerateFocalRay(
    
        to device: OpticsDevice
        
    ) -> Bool {
        
        if let lense = device as? Lense {
            
            return lense.generatesFocalRay
        }
        
        if let mirror = device as? Mirror,
           mirror.type == .concave {
            
            return mirror.generatesFocalRay
        }
        
        return false
    }
    
    
    func shouldGenerateCurveCenterRay(
    
        to device: OpticsDevice
        
    ) -> Bool {
        
        if let mirror = device as? Mirror,
           mirror.type == .concave {
            
            return mirror.generatesCurveCenterRay
        }
        
        return false
    }
    
    
    func shouldRetroPropagateRays(
        
        from device: OpticsDevice
        
    ) -> Bool {
        
        if let lense = device as? Lense {
            
            return lense.retroPropagatesRays
        }
        
        return false
    }
    
    
    func shouldConnectToSource(
        
        _ source: ObjectOrImage,
        _ showImages: Bool,
        _ showVirtualImages: Bool
    
    ) -> Bool {
        
        if let image = source as? Image {
            
            if !showImages {
                return false
            }
            
            if image.virtual {
                return showVirtualImages
            }
        }
        
        return true
    }
    
    
    func propagateRayForwards(
        
        from sourceRayPoint: RayPoint,
        
        sources: [ObjectOrImage],
        devices: [OpticsDevice],
        sourceIndex: Int,
        
        showImages: Bool,
        showVirtualImages: Bool
        
    ) -> [RayDescriptor] {
        
        var allRayDescriptors: [RayDescriptor] = []
        
        var rayPointOnPreviousDevice = sourceRayPoint
        
        for sourceIndexForward in (sourceIndex+1)..<sources.count {
            
            let loop = getLoopIterator(
                for: sources, devices,
                at: sourceIndexForward
            )
            
            let ray = Ray(
                from: rayPointOnPreviousDevice.point,
                to: loop.currentSourceTop
            )
            
            let propagatesRight = false
            
            let defaultEndX = propagatesRight ? renderSize.width : 0
            
            let endX = loop.currentDevicePos ?? defaultEndX
            
            var pointsForRay: [CGPoint] = [
                ray.point(atX: rayPointOnPreviousDevice.point.x),
                ray.point(atX: endX),
            ]
            
            if shouldConnectToSource(loop.currentSource, showImages, showVirtualImages) {
                pointsForRay.append(ray.point(atX: loop.currentSourcePos))
            }
            
            if let lense = loop.previousDevice as? Lense,
               lense.type == .divergent,
               rayPointOnPreviousDevice.hasParallelIncidence
            {
                pointsForRay.append(
                    ray.point(atX: loop.previousDeviceFocalPointBefore!.x)
                )
            }
            
            if let mirror = loop.previousDevice as? Mirror,
               mirror.type == .convex,
               rayPointOnPreviousDevice.hasParallelIncidence
            {
                pointsForRay.append(
                    ray.point(atX: loop.previousDeviceFocalPointAfter!.x)
                )
            }
            
            //                        if let lense = previousDevice as? Lense,
            //                           lense.type == .convergent,
            //                           rayPointOnPreviousDevice.hasParallelIncidence
            //                        {
            //                            pointsForRay.append(
            //                                ray.point(atX: previousDeviceFocalPointAfter!.x)
            //                            )
            //                        }
            
            allRayDescriptors.append(RayDescriptor(
                deviceBefore: loop.previousDevice,
                deviceAfter: loop.currentDevice,
                propagatesRight: propagatesRight,
                source: loop.currentSource,
                rayId: rayPointOnPreviousDevice.rayId,
                points: pointsForRay
            ))
            
            rayPointOnPreviousDevice = RayPoint(
                point: ray.point(atX: endX),
                rayId: rayPointOnPreviousDevice.rayId
            )
        }
        
        return allRayDescriptors
    }
    
    
    func propagateRayBackwards(
    
        from sourceRayPoint: RayPoint,
        
        sources: [ObjectOrImage],
        devices: [OpticsDevice],
        sourceIndex: Int,
        
        showVirtualImages: Bool
        
    ) -> [RayDescriptor] {
        
        var allRayDescriptors: [RayDescriptor] = []
        
        var rayPointOnCurrentDevice = sourceRayPoint
        
        for i in 0..<sourceIndex {
            let sourceIndexBackwards = sourceIndex-1-i
            
            let loop = getLoopIterator(
                for: sources, devices,
                at: sourceIndexBackwards
            )
            
            let ray = Ray(
                from: loop.currentSourceTop,
                to: rayPointOnCurrentDevice.point
            )
            
            let startX = loop.previousDevicePos ?? loop.currentSourcePos
            
            let pointsForRay: [CGPoint] = [
                ray.point(atX: startX),
                ray.point(atX: rayPointOnCurrentDevice.point.x),
            ]
            
            allRayDescriptors.append(RayDescriptor(
                deviceBefore: loop.previousDevice,
                deviceAfter: loop.currentDevice,
                propagatesRight: true,
                source: loop.currentSource,
                rayId: rayPointOnCurrentDevice.rayId,
                points: pointsForRay
            ))
            
            rayPointOnCurrentDevice = RayPoint(
                point: ray.point(atX: startX),
                rayId: rayPointOnCurrentDevice.rayId
            )
        }
        
        return allRayDescriptors
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
            
            currentDevice: currentDevice,
            currentDevicePos: currentDeviceInfo.pos,
            currentDeviceCenter: currentDeviceInfo.center,
            currentDeviceFocalLength: currentDeviceInfo.focalLength,
            currentDeviceFocalPointBefore: currentDeviceInfo.focalPointBefore,
            currentDeviceFocalPointAfter: currentDeviceInfo.focalPointAfter,
            currentDeviceCurveCenterPointBefore: currentDeviceInfo.curveCenterPointBefore,
            currentDeviceCurveCenterPointAfter: currentDeviceInfo.curveCenterPointAfter,
            
            previousDevice: previousDevice,
            previousDevicePos: previousDeviceInfo.pos,
            previousDeviceCenter: previousDeviceInfo.center,
            previousDeviceFocalLength: previousDeviceInfo.focalLength,
            previousDeviceFocalPointBefore: previousDeviceInfo.focalPointBefore,
            previousDeviceFocalPointAfter: previousDeviceInfo.focalPointAfter,
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
        
        let deviceFocalLength: CGFloat? = {
            if let lense = device as? Lense {
                return resolvedFocalLength(
                    from: lense.focalLength
                )
            }
            if let mirror = device as? Mirror {
                return resolvedFocalLength(
                    from: mirror.focalLength
                )
            }
            return nil
        }()
        
        let deviceFocalPointBefore: CGPoint? = {
            if device is Lense || device is Mirror {
                return CGPoint(
                    x: devicePos! - deviceFocalLength!, y: 0
                )
            }
            return nil
        }()
        
        let deviceFocalPointAfter: CGPoint? = {
            if device is Lense || device is Mirror  {
                return CGPoint(
                    x: devicePos! + deviceFocalLength!, y: 0
                )
            }
            return nil
        }()
        
        let deviceCurveCenterPointBefore: CGPoint? = {
            if device is Mirror {
                return CGPoint(
                    x: devicePos! - 2*deviceFocalLength!, y: 0
                )
            }
            return nil
        }()
        
        let deviceCurveCenterPointAfter: CGPoint? = {
            if device is Mirror {
                return CGPoint(
                    x: devicePos! + 2*deviceFocalLength!, y: 0
                )
            }
            return nil
        }()
        
        let info = DeviceInfo(
            pos: devicePos,
            center: deviceCenter,
            focalLength: deviceFocalLength,
            focalPointBefore: deviceFocalPointBefore,
            focalPointAfter: deviceFocalPointAfter,
            curveCenterPointBefore: deviceCurveCenterPointBefore,
            curveCenterPointAfter: deviceCurveCenterPointAfter
        )
        
        return info
    }
    
    
    func drawRays(
        
        from rayDescriptors: [RayDescriptor],
        showVirtualRays: Bool,
        mouse: CGPoint
        
    ) {
        
        var raySegments = getRaySegments(
            from: rayDescriptors
        )
        
        raySegments = removeZeroLengthSegments(
            from: raySegments
        )
        
//        if raySegments.count > 2 {
//            raySegments = [
//                raySegments[0],
//                raySegments[5],
//            ]
//        }
        
        raySegments = deduplicate(raySegments)
        
        let hoverSegment = raySegments.first(where: { segment in
            
            let ray = Ray(from: segment.p1, to: segment.p2)
            
            return (
                mouse.distanceTo(ray.point(atX: mouse.x)) < 10
                && mouse.isXStrictlyBetween(segment.p1, and: segment.p2)
            )
        })
        
        if let hoverSegment {
            
            raySegments = highlight(
                raySegments,
                withRayId: hoverSegment.rayId
            )
        }
        
        drawRays(
            from: raySegments,
            showVirtualRays: showVirtualRays,
            
            lineWidthDefault: 1,
            lineWidthHightlighted: 3,
            
            opacityDefault: hoverSegment != nil ? 0.2 : 1,
            opacityHightlighted: 1
        )
    }
    
    
    func highlight(
        
        _ raySegments: [RaySegment],
        withRayId rayId: UUID
    
    ) -> [RaySegment] {
        
        var segments: [RaySegment] = []
        
        for segment in raySegments {
            
            segments.append(RaySegment(
                p1: segment.p1,
                p2: segment.p2,
                virtual: segment.virtual,
                highlighted: segment.rayId == rayId,
                rayId: segment.rayId
            ))
        }
        
        return segments
    }
    
    
    func drawRays(
    
        from raySegments: [RaySegment],
        showVirtualRays: Bool,
        
        lineWidthDefault: CGFloat,
        lineWidthHightlighted: CGFloat,
        
        opacityDefault: CGFloat,
        opacityHightlighted: CGFloat,
    ) {
        
        for segment in raySegments {
            
            if showVirtualRays || !segment.virtual {
                
                drawRay(
                    from: segment.p1,
                    to: segment.p2,
                    virtual: segment.virtual,
                    lineWidth: segment.highlighted
                        ? lineWidthHightlighted
                        : lineWidthDefault,
                    opacity: segment.highlighted
                        ? opacityHightlighted
                        : opacityDefault
                )
            }
        }
    }
    
    
    func getRaySegments(
        
        from rayDescriptors: [RayDescriptor]
        
    ) -> [RaySegment] {
        
        var raySegments: [RaySegment] = []
        
        for rayDescriptor in rayDescriptors {
            
            let propagatesRight = rayDescriptor.propagatesRight
            
            let startX: CGFloat? = {
                
                var pos: [CGFloat] = []

                if let deviceBefore = rayDescriptor.deviceBefore {
                    pos.append(resolvedPos(from: deviceBefore.pos))
                }
                
                if rayDescriptor.source is Object {
                    pos.append(resolvedPos(from: rayDescriptor.source.pos))
                }
                
                return pos.max()
            }()
            
            let endX: CGFloat? = {
                
                if let deviceAfter = rayDescriptor.deviceAfter {
                    return resolvedPos(from: deviceAfter.pos)
                }
                return nil
            }()
            
            var points = rayDescriptor.points.sorted { $0.x < $1.x }
                
            if propagatesRight {
                
                if let p1 = points.first,
                   let p2 = points.last {
                    
                    let ray = Ray(from: p1, to: p2)
                    
                    if let startX = startX, p1.x < startX {
                        points.append(ray.point(atX: startX))
                    }
                    if let endX = endX, p2.x > endX {
                        points.append(ray.point(atX: endX))
                    }
                }
                
            } else {
                
                points = points.reversed()
                
                if let p1 = points.first,
                   let p2 = points.last {
                    
                    let ray = Ray(from: p1, to: p2)
                    
                    if let startX = startX, p1.x > startX {
                        points.append(ray.point(atX: startX))
                    }
                    if let endX = endX, p2.x < endX {
                        points.append(ray.point(atX: endX))
                    }
                }
            }
            
            let pointsBefore: [CGPoint] = {
                
                if propagatesRight {
                    
                    if let startX = startX {
                        return points.filter { $0.x <= startX }
                    } else {
                        return []
                    }
                    
                } else {
                    
                    if let startX = startX {
                        return points.filter { $0.x >= startX }
                    } else {
                        return []
                    }
                }
            }().sorted { $0.x < $1.x }
            
            let pointsBetween: [CGPoint] = {
                
                if propagatesRight {
                    
                    if let startX = startX, let endX = endX {
                        
                        return points.filter { $0.x >= startX && $0.x <= endX }
                        
                    } else if let startX = startX {
                        
                        return points.filter { $0.x >= startX }
                        
                    } else if let endX = endX {
                        
                        return points.filter { $0.x <= endX }
                        
                    } else {
                        
                        return points
                    }
                    
                } else {
                    
                    if let startX = startX, let endX = endX {
                        
                        return points.filter { $0.x <= startX && $0.x >= endX }
                        
                    } else if let startX = startX {
                        
                        return points.filter { $0.x <= startX }
                        
                    } else if let endX = endX {
                        
                        return points.filter { $0.x >= endX }
                        
                    } else {
                        
                        return points
                    }
                }
                
            }().sorted { $0.x < $1.x }
            
            let pointsAfter: [CGPoint] = {
                
                if propagatesRight {
                    
                    if let endX = endX {
                        
                        return points.filter { $0.x >= endX }
                        
                    } else {
                        
                        return []
                    }
                    
                } else {
                    
                    if let endX = endX {
                        
                        return points.filter { $0.x <= endX }
                        
                    } else {
                        
                        return []
                    }
                }
            }().sorted { $0.x < $1.x }
            
            if let segment = getRaySegment(
                from: pointsBefore,
                rayId: rayDescriptor.rayId,
                virtual: true
            ) {
                raySegments.append(segment)
            }
            
            if let segment = getRaySegment(
                from: pointsBetween,
                rayId: rayDescriptor.rayId,
                virtual: false
            ) {
                raySegments.append(segment)
            }
            
            if let segment = getRaySegment(
                from: pointsAfter,
                rayId: rayDescriptor.rayId,
                virtual: true
            ) {
                raySegments.append(segment)
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
    
    let currentDevice: OpticsDevice?
    let currentDevicePos: CGFloat?
    let currentDeviceCenter: CGPoint?
    let currentDeviceFocalLength: CGFloat?
    let currentDeviceFocalPointBefore: CGPoint?
    let currentDeviceFocalPointAfter: CGPoint?
    let currentDeviceCurveCenterPointBefore: CGPoint?
    let currentDeviceCurveCenterPointAfter: CGPoint?
    
    let previousDevice: OpticsDevice?
    let previousDevicePos: CGFloat?
    let previousDeviceCenter: CGPoint?
    let previousDeviceFocalLength: CGFloat?
    let previousDeviceFocalPointBefore: CGPoint?
    let previousDeviceFocalPointAfter: CGPoint?
}

struct DeviceInfo {
    
    let pos: CGFloat?
    let center: CGPoint?
    let focalLength: CGFloat?
    let focalPointBefore: CGPoint?
    let focalPointAfter: CGPoint?
    let curveCenterPointBefore: CGPoint?
    let curveCenterPointAfter: CGPoint?
}
