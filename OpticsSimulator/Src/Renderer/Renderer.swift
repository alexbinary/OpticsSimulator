
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
    
    func render(
        
        _ scene: OpticsScene,
        
        showImages: Bool,
        showVirtualImages: Bool,
        showVirtualRays: Bool
    
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
                
                for (ray, horizontalIncidence, points) in rays {
                    
                    var pointsForRay: [CGPoint] = [
                        ray.point(atX: loop.currentDevicePos!),
                    ]
                    
                    if shouldConnectToSource(loop.currentSource, showVirtualImages) {
                        pointsForRay.append(ray.point(atX: loop.currentSourcePos))
                    }
                    
                    let pointFromRayOnCurrentDevice =
                    ray.point(
                        atX: loop.currentDevicePos!
                    )
                    
                    rayPointsOnCurrentDevice.append(RayPoint(
                        point: pointFromRayOnCurrentDevice,
                        horizontalIncidence: horizontalIncidence
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
                            horizontalIncidence: horizontalIncidence
                        ))
                    }
                    
                    allRayDescriptors.append(RayDescriptor(
                        deviceBefore: loop.previousDevice,
                        deviceAfter: loop.currentDevice!,
                        source: loop.currentSource,
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
            showVirtualRays: showVirtualRays
        )
        
        
        
        
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
    
    
    func shouldGenerateParallelRay(
    
        to device: OpticsDevice
        
    ) -> Bool {
        
        if let lense = device as? Lense {
            
            return lense.generatesParallelRay
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
        _ showVirtualImages: Bool
    
    ) -> Bool {
        
        if source is Object {
            return true
        }
        
        let image = source as! Image
        if showVirtualImages || !image.virtual {
            return true
        }
        
        return false
    }
    
    
    func propagateRayForwards(
        
        from sourceRayPoint: RayPoint,
        
        sources: [ObjectOrImage],
        devices: [OpticsDevice],
        sourceIndex: Int,
        
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
            let endX = loop.currentDevicePos ?? renderSize.width
            
            var pointsForRay: [CGPoint] = [
                ray.point(atX: rayPointOnPreviousDevice.point.x),
                ray.point(atX: endX),
            ]
            
            if shouldConnectToSource(loop.currentSource, showVirtualImages) {
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
                source: loop.currentSource,
                points: pointsForRay
            ))
            
            rayPointOnPreviousDevice = RayPoint(
                point: ray.point(atX: endX)
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
                source: loop.currentSource,
                points: pointsForRay
            ))
            
            rayPointOnCurrentDevice = RayPoint(
                point: ray.point(atX: startX)
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
            pos: devicePos,
            center: deviceCenter,
            focalLength: deviceFocalLength,
            focalPointBefore: deviceFocalPointBefore,
            focalPointAfter: deviceFocalPointAfter
        )
        
        return info
    }
    
    
    func drawRays(
        
        from rayDescriptors: [RayDescriptor],
        showVirtualRays: Bool
        
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
        
        drawRays(
            from: raySegments,
            showVirtualRays: showVirtualRays
        )
    }
    
    
    func drawRays(
    
        from raySegments: [RaySegment],
        showVirtualRays: Bool
        
    ) {
        
        for segment in raySegments {
            
            let p1 = segment.p1
            let p2 = segment.p2
            let virtual = segment.virtual
            
            if showVirtualRays || !segment.virtual {
                
                draw(
                    Ray(
                        from: segment.p1,
                        to: segment.p2
                    ),
                    minX: segment.p1.x,
                    maxX: segment.p2.x,
                    virtual: segment.virtual
                )
            }
        }
    }
    
    
    func getRaySegments(
        
        from rayDescriptors: [RayDescriptor]
        
    ) -> [RaySegment] {
        
        var raySegments: [RaySegment] = []
        
        for rayDescriptor in rayDescriptors {
            
            let startX: CGFloat? = {
                
                var pos: [CGFloat] = [resolvedPos(from: rayDescriptor.source.pos)]
                
                if let deviceBefore = rayDescriptor.deviceBefore {
                    pos.append(resolvedPos(from: deviceBefore.pos))
                }
                
                return pos.max()
            }()
            
            let endX: CGFloat? = {
                
                if let deviceAfter = rayDescriptor.deviceAfter {
                    return resolvedPos(from: deviceAfter.pos)
                }
                return nil
            }()
            
            var points = rayDescriptor.points
            
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
            
            let pointsBefore = points.filter { point in
                
                if let startX = startX {
                    return point.x <= startX
                }
                return false
                
            }.sorted { $0.x < $1.x }
            
            let pointsBetween = points.filter { point in
                    
                if let startX = startX, let endX = endX {
                    
                    return (
                        point.x >= startX
                        &&
                        point.x <= endX
                    )
                    
                } else if let startX = startX {
                    
                    return point.x >= startX
                    
                } else if let endX = endX {
                    
                    return point.x <= endX
                }
                return true
            }
            .sorted { $0.x < $1.x }
            
            let pointsAfter = points.filter { point in
                
                if let endX = endX {
                    return point.x >= endX
                }
                return false
            }
            .sorted { $0.x < $1.x }
            
            if let segment = getRaySegment(
                from: pointsBefore, virtual: true
            ) {
                raySegments.append(segment)
            }
            
            if let segment = getRaySegment(
                from: pointsBetween, virtual: false
            ) {
                raySegments.append(segment)
            }
            
            if let segment = getRaySegment(
                from: pointsAfter, virtual: true
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
}
