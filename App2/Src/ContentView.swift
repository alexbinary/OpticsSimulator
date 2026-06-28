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
    
    @State private var selectedLense: Lense? = nil
    
    @State private var canvasSize: CGSize = .zero
    @State private var viewMouse: CGPoint = .zero
    
    @State private var viewportTransform = ViewportTransform(
        translation: .zero, rotation: .zero, scale: 1
    )
    
    
    var body: some View {
        
        VStack(alignment: .trailing) {
            
            ZStack {
                
                Canvas { context, size in
                    
                    let renderer = Renderer(
                        context: context,
                        canvasSize: size,
                        viewportTransform: viewportTransform,
                        gridSnapSize: gridSnapSize,
                        transformedMouse: transformedMouse,
                        transformedMouseSnapped: transformedMouseSnapped,
                        hoveringLense: scene.hoveringLense
                    )
                    renderer.render(scene)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.size, initial: true) { _, newSize in
                                self.canvasSize = newSize
                            }
                    }
                )
                MouseEventsArea(
                    onMouseMove: { point in
                        viewMouse = point
                        scene.setMouse(transformedMouse, viewportTransform: viewportTransform)
                    },
                    onMouseDown: { point in
                        selectedLense = scene.hoveringLense
                    },
                    onMouseUp: { point in
                        selectedLense = nil
                    },
                    onMouseDrag: { point in
                        selectedLense?.position = transformedMouseSnapped
                    },
                    onScroll: { dx, dy, modifiers, phase, momentumPhase in
                        if modifiers.contains(.option) {
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
    
    
    var inverseViewportTransform: CGAffineTransform {
        
        CGAffineTransform.identity
            .concatenating(.init(
                translationX: -canvasSize.width/2, y: -canvasSize.height/2)
            )
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
    
    
    var transformedMouse: CGPoint {
        
        viewMouse.applying(inverseViewportTransform)
    }
    
    
    var transformedMouseSnapped: CGPoint {
        
        return snap(transformedMouse, onMultipleOf: gridSnapSize/10)
    }
    
    
    var gridSnapSize: CGFloat {
        
        return snap(20/viewportTransform.scale, onPowerOf: 10)
    }
    
    
    func zoomViewport(by delta: CGFloat) {
        
        let oldScale = viewportTransform.scale
        let newScale = oldScale * (1 + delta)
        
        let xw = transformedMouse.x
        let yw = transformedMouse.y
        
        let cosa = cos(viewportTransform.rotation.radians)
        let sina = sin(viewportTransform.rotation.radians)
        
        let offset = (oldScale-newScale)*Vector(
            dx: xw*cosa - yw*sina,
            dy: yw*cosa + xw*sina
        )
        
        viewportTransform.scale = newScale
        viewportTransform.translation += offset
    }
    
    func rotateViewport(by delta: Angle) {
        
        viewportTransform.rotation += delta
    }
    
    func panViewport(by v: Vector) {
        
        viewportTransform.translation = Vector(
            dx: viewportTransform.translation.dx + v.dx,
            dy: viewportTransform.translation.dy + v.dy
        )
    }
    
    
    func resetViewport() {
        
        viewportTransform.translation = .zero
        viewportTransform.rotation = .zero
        viewportTransform.scale = 1
    }
    
    
    func fitViewport() {
        
        let rect = scene.boundingRect
        
        let size = max(rect.width, rect.height)
        let window = min(canvasSize.width, canvasSize.height)*0.6
        
        let scale = window/size
        
        let xw = (rect.minX + rect.maxX)/2
        let yw = (rect.minY + rect.maxY)/2
        
        viewportTransform.rotation = .zero
        
        let cosa = cos(viewportTransform.rotation.radians)
        let sina = sin(viewportTransform.rotation.radians)
        
        let x0: CGFloat = 0
        let y0: CGFloat = 0
        
        viewportTransform.translation = Vector(
            dx: x0 - scale*(xw*cosa - yw*sina),
            dy: y0 - scale*(yw*cosa + xw*sina)
        )
        
        viewportTransform.scale = scale
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
