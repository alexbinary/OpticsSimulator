
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
        let direction = Ray(from: p1, to: p2)
        
        let startPoint = direction.point(
            atX: minX ?? p1.x
        )
        let endPoint = direction.point(
            atX: maxX ?? p2.x
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
        
        resIndependantPos * size.width
    }
    
    func rendererFocalLength(from resIndependantF: CGFloat) -> CGFloat {
        
        resIndependantF * size.width
    }
    
    func rendererObjectSize(from resIndependantSize: CGFloat) -> CGFloat {
        
        resIndependantSize * size.height/2*0.7
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
        
        for object in scene.objects {
            draw(object)
        }
        for lense in scene.lenses {
            draw(lense)
        }
        for mirror in scene.mirrors {
            draw(mirror)
        }
        for screen in scene.screens {
            draw(screen)
        }
        
        
        // compute images
        
        let devicesByPosition = scene.devices.sorted { $0.pos < $1.pos }
        
        var images: [Image] = []
        
        if let object = scene.objects.first {
            
            let devices = devicesByPosition
                .filter { $0.pos > object.pos }
            
            // compute images
            
            for device in devices {
                
                if device is Screen {
                    break
                }
                
                images.append(image(of: images.last ?? object, through: device))
            }
            
            // draw rays
            
            let images = [object] + images
            
            for i1 in 0..<images.count {
            
//                if ![1].contains(i1) { continue }
                
                // draw rays from image to devices on both side
                
                let currentImage = images[i1]
                
                let deviceBefore = (i1-1) >= 0 ? devices[i1-1] : nil
                let deviceAfter = i1 < devices.count ? devices[i1] : nil
                
                if deviceAfter == nil {
                    
                    break
                }
                   
                if deviceAfter is Screen,
                   currentImage is Image {
                    
                    break
                }
                
                let imagePos = rendererPos(from: currentImage.pos)
                let imageSize = rendererObjectSize(from: currentImage.size)
                let imageTop = CGPoint(x: imagePos, y: imageSize)
                
                let deviceBeforePos = rendererPos(
                    from: deviceBefore?.pos ?? currentImage.pos
                )
                let deviceAfterPos = rendererPos(
                    from: deviceAfter?.pos ?? currentImage.pos
                )
                
                let deviceAfterCenter = CGPoint(x: deviceAfterPos, y: 0)
                let deviceAfterFocalPoint = CGPoint(
                    x: deviceAfterPos - rendererFocalLength(from: (deviceAfter as? Lense)?.focalLength ?? 0), y: 0
                )
                
                // parallel ray
                
                let parallelRay = Ray(
                    horizontalFrom: imageTop
                )
                
                let pointFromHorizontalOnDeviceBefore = parallelRay.point(
                    atX: deviceBeforePos
                )
                
                let pointFromHorizontalOnDeviceAfter = parallelRay.point(
                    atX: deviceAfterPos
                )
                
                drawRay(
                    from: pointFromHorizontalOnDeviceBefore,
                    to: pointFromHorizontalOnDeviceAfter
                )
                
                // center ray
                
                let centerRay = Ray(
                    from: imageTop, to: deviceAfterCenter,
                )
                
                let pointFromCenterOnDeviceBefore = centerRay.point(
                    atX: deviceBeforePos
                )
                
                let pointFromCenterOnDeviceAfter = centerRay.point(
                    atX: deviceAfterPos
                )
                
                drawRay(
                    from: pointFromCenterOnDeviceBefore,
                    to: pointFromCenterOnDeviceAfter
                )
                
                // focal ray
                
                let focalRay = Ray(
                    from: imageTop, to: deviceAfterFocalPoint,
                )
                
                let pointFromFocalPointOnDeviceBefore = focalRay.point(
                    atX: deviceBeforePos
                )
                
                let pointFromFocalPointOnDeviceAfter = focalRay.point(
                    atX: deviceAfterPos
                )
                
                drawRay(
                    from: pointFromFocalPointOnDeviceBefore,
                    to: pointFromFocalPointOnDeviceAfter
                )

                // continue rays forward through all devices
                
                var pointsOnDeviceBefore: [CGPoint] = [
                    pointFromHorizontalOnDeviceAfter,
                    pointFromCenterOnDeviceAfter,
                    pointFromFocalPointOnDeviceAfter,
                ]
                
                for i2 in (i1+1)..<images.count {

//                    if ![].contains(i2) { continue }
                    
                    let currentImage = images[i2]
                    
                    let deviceBefore = (i2-1) >= 0 ? devices[i2-1] : nil
                    let deviceAfter = i2 < devices.count ? devices[i2] : nil
                    
                    let imagePos = rendererPos(from: currentImage.pos)
                    let imageSize = rendererObjectSize(from: currentImage.size)
                    let imageTop = CGPoint(x: imagePos, y: imageSize)
                    
                    let deviceAfterPos = rendererPos(
                        from: deviceAfter?.pos ?? currentImage.pos
                    )
                    
                    var pointsOnDeviceAfter: [CGPoint] = []

                    for pointOnDeviceBefore in pointsOnDeviceBefore {

                        let pointOnDeviceAfter = Ray(
                            from: pointOnDeviceBefore, to: imageTop
                        ).point(
                            atX: deviceAfterPos
                        )

                        drawRay(
                            from: pointOnDeviceBefore,
                            to: pointOnDeviceAfter
                        )
                        
                        if imagePos > deviceAfterPos {
                            
                            drawRay(
                                from: pointOnDeviceBefore,
                                to: pointOnDeviceAfter,
                                minX: deviceAfterPos, maxX: imagePos,
                                virtual: true
                            )
                        }

                        pointsOnDeviceAfter.append(pointOnDeviceAfter)
                    }

                    pointsOnDeviceBefore = pointsOnDeviceAfter
                }
                
                // continue rays backwards through all devices
                
                var pointsOnDeviceAfter: [CGPoint] = [
                    pointFromHorizontalOnDeviceBefore,
                    pointFromCenterOnDeviceBefore,
                    pointFromFocalPointOnDeviceBefore,
                ]
                
                for i2 in 0..<i1 {
                    
                    let i3 = i1-1-i2
                    
//                    if ![].contains(i2) { continue }
                    
                    let currentImage = images[i3]
                    
                    let deviceBefore = (i3-1) >= 0 ? devices[i3-1] : nil
                    let deviceAfter = i3 < devices.count ? devices[i3] : nil
                    
                    let imagePos = rendererPos(from: currentImage.pos)
                    let imageSize = rendererObjectSize(from: currentImage.size)
                    let imageTop = CGPoint(x: imagePos, y: imageSize)
                    
                    let deviceBeforePos = rendererPos(
                        from: deviceBefore?.pos ?? currentImage.pos
                    )
                    
                    var pointsOnDeviceBefore: [CGPoint] = []

                    for pointOnDeviceAfter in pointsOnDeviceAfter {

                        let pointOnDeviceBefore = Ray(
                            from: pointOnDeviceAfter, to: imageTop
                        ).point(
                            atX: deviceBeforePos
                        )

                        drawRay(
                            from: pointOnDeviceBefore,
                            to: pointOnDeviceAfter
                        )

                        pointsOnDeviceAfter.append(pointOnDeviceAfter)
                    }

                    pointsOnDeviceAfter = pointsOnDeviceBefore
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
        
        for image in images {
            draw(image, virtual: image.pos > scene.screens.first?.pos ?? .infinity)
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
