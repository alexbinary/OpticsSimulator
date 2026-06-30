import SwiftUI



struct ContentView: View {
    
    
    @State private var scene: OpticsScene = {
        let scene = OpticsScene()
        scene.add(Lense(
            type: .convergent,
            diameter: 100,
            focalLength: 10,
            position: CGPoint(x: 300, y: 300),
            rotation: .degrees(45)
        ))
        return scene
    }()
    
    @State private var canvasSize: CGSize = .zero
    
    @State private var viewportTransform = ViewportTransform(
        translation: .zero, rotation: .zero, scale: 1
    )
    @State private var viewportTransformOnLastMouseDown: ViewportTransform? = nil
    
    @State private var viewMouse: CGPoint = .zero
    @State private var viewMouseLastDown: CGPoint = .zero
    @State private var viewMouseLastUp: CGPoint = .zero
    
    @State private var draggingObject: Lense? = nil
    @State private var draggingObjectOffset: Vector? = nil
    
    @State private var scrollZooms: Bool = false
    
    
    var body: some View {
        
        VStack(alignment: .trailing) {
            
            ZStack {
                
                Canvas { context, size in
                    
                    print("Canvas", self.canvasSize)
                    
                    // origin bottom left, Y+ up
                    context.scaleBy(x: 1, y: -1)
                    context.translateBy(x: 0, y: -canvasSize.height)
                    
                    // origin at center of the screen
                    context.translateBy(x: viewportBaseOffset.dx, y: viewportBaseOffset.dy)
                    
                    let renderer = Renderer(
                        context: context,
                        canvasSize: size,
                        viewportTransform: viewportTransform,
                        gridSnapSize: gridSnapSize,
                        transformedMouse: transformedMouse,
                        transformedMouseSnapped: transformedMouseSnapped,
                        hoveringObject: scene.hoverObject
                    )
                    renderer.render(scene)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.size, initial: true) { _, newSize in
                                self.canvasSize = newSize
                                print("onChange", self.canvasSize)
                            }
                    }
                )
                MouseEventsArea(
                    onMouseMove: { point in
                        updateMouse(newPosition: point)
                    },
                    onMouseDown: { point in
                        draggingObject = scene.hoverObject
                        draggingObjectOffset = scene.hoverObjectOffset
                        viewMouseLastDown = viewMouse
                        viewportTransformOnLastMouseDown = viewportTransform
                    },
                    onMouseUp: { point in
                        draggingObject = nil
                        viewMouseLastUp = viewMouse
                    },
                    onMouseDrag: { point in
                        updateMouse(newPosition: point, dragging: true)
                    },
                    onScroll: { dx, dy, modifiers, phase, momentumPhase in
                        if phase == .began {
                            scrollZooms = modifiers.contains(.option)
                        }
                        if scrollZooms {
                            if momentumPhase == [] {
                                zoomViewport(by: dy*0.01)
                            }
                        } else {
                            panViewport(by: Vector(dx: dx, dy: -dy))
                        }
                    },
                    onRotate: { delta, point in
                        rotateViewport(by: delta)
                    },
                    onPinch: { delta, point in
                        zoomViewport(by: delta*0.5)
                    },
                )
            }
            
            HStack {
                Text("Translation: \(viewportTransform.translation.dx); \(viewportTransform.translation.dy)")
                Text("Rotation: \(viewportTransform.rotation.degrees)°")
                Text("Scale: \(viewportTransform.scale)")
                Text("View: \(viewMouse.x); \(viewMouse.y)")
                Text("Transformed: \(transformedMouseSnapped.x); \(transformedMouseSnapped.y)")
            }
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(minWidth: 1600, minHeight: 800)
        .toolbar {
            ToolbarItem {
                Button("􀐩") {
                    fitViewport()
                }
            }
            ToolbarItem {
                Button("􂣾") {
                    resetViewport()
                }
            }
        }
    }
    
    
    var viewportBaseOffset: Vector {
     
        return Vector(
            dx: canvasSize.width/2,
            dy: canvasSize.height/2
        )
    }
    
    
    var inverseViewportTransform: CGAffineTransform {
        
        CGAffineTransform.identity
            .concatenating(.init(
                translationX: -viewportTransform.translation.dx, y: -viewportTransform.translation.dy)
            )
            .concatenating(.init(
                rotationAngle: -viewportTransform.rotation.radians)
            )
            .concatenating(.init(
                scaleX: 1/viewportTransform.scale, y: 1/viewportTransform.scale)
            )
    }
    
    
    func updateMouse(newPosition point: CGPoint, dragging: Bool = false) {
        
        viewMouse = CGPoint(
            x: point.x - viewportBaseOffset.dx,
            y: point.y - viewportBaseOffset.dy
        )
        
        scene.updateMouse(
            newTransformedPosition: transformedMouse,
            viewportTransform: viewportTransform
        )
        
        if dragging {
            
            if let object = draggingObject,
               let offset = draggingObjectOffset {
                
                let target = transformedMouseSnapped
                
                object.position = CGPoint(
                    x: target.x - offset.dx,
                    y: target.y - offset.dy
                )
                
            } else if let base = viewportTransformOnLastMouseDown?.translation {
                
                let offset = Vector(
                    dx: viewMouse.x - viewMouseLastDown.x,
                    dy: viewMouse.y - viewMouseLastDown.y
                )
                
                viewportTransform.translation = Vector(
                    dx: base.dx + offset.dx,
                    dy: base.dy + offset.dy
                )
            }
        }
    }
    
    
    var transformedMouse: CGPoint {
        
        viewMouse.applying(inverseViewportTransform)
    }
    
    
    var transformedMouseSnapped: CGPoint {
        
        return snap(transformedMouse, onMultipleOf: gridSnapSize/10)
    }
    
    
    var gridSnapSize: CGFloat {
        
        return snap(20/viewportTransform.scale, onPowerOf: 10)
    }
    
    
    func resetViewport() {
        
        viewportTransform.translation = .zero
        viewportTransform.rotation = .zero
        viewportTransform.scale = 1
    }
    
    
    func panViewport(by v: Vector) {
        
        viewportTransform.translation = Vector(
            dx: viewportTransform.translation.dx + v.dx,
            dy: viewportTransform.translation.dy + v.dy
        )
    }
    
    
    func panViewport(toHave worldPoint: CGPoint, appearAt screenPoint: CGPoint) {
        
        let a = viewportTransform.rotation
        let s = viewportTransform.scale
        
        let cosa = cos(a.radians)
        let sina = sin(a.radians)
        
        let xc = worldPoint.x
        let yc = worldPoint.y
        
        let xs = screenPoint.x
        let ys = screenPoint.y
        
        viewportTransform.translation = Vector(
            dx: xs - s*(xc*cosa - yc*sina),
            dy: ys - s*(yc*cosa + xc*sina)
        )
    }

    
    func rotateViewport(by delta: Angle) {
        
        let worldPoint = transformedMouse
        let screenPoint = viewMouse
        
        viewportTransform.rotation += delta
        
        panViewport(toHave: worldPoint, appearAt: screenPoint)
    }
    

    func zoomViewport(by delta: CGFloat) {
        
        let worldPoint = transformedMouse
        let screenPoint = viewMouse
        
        viewportTransform.scale *= (1 + delta)
        
        panViewport(toHave: worldPoint, appearAt: screenPoint)
    }
    
    
    func fitViewport() {
        
        let bounds = scene.bounds
        
        if let maxX = bounds.maxX, let minX = bounds.minX,
           let maxY = bounds.maxY, let minY = bounds.minY {
            
            let boundsWidth = maxX - minX
            let boundsHeight = maxY - minY
            
            let boundsSize = max(boundsWidth, boundsHeight)
            let windowSize = min(canvasSize.width, canvasSize.height)*0.6
            
            let fitScale = windowSize/boundsSize
            
            let boundsCenter = CGPoint(x: (minX + maxX)/2, y: (minY + maxY)/2)
            
            viewportTransform.rotation = .zero
            viewportTransform.scale = fitScale
            
            panViewport(toHave: boundsCenter, appearAt: .zero)
        }
    }
    
    
    
    
    
    
    
}

#Preview {
    ContentView()
}



struct ViewportTransform {
    
    var translation: Vector
    var rotation: Angle
    var scale: CGFloat
}
