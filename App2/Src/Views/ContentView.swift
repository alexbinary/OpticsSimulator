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
                        updateMouse(newPosition: point)
                    },
                    onMouseDown: { point in
                        selectedLense = scene.hoveringLense
                    },
                    onMouseUp: { point in
                        selectedLense = nil
                    },
                    onMouseDrag: { point in
                        updateMouse(newPosition: point)
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
    
    
    func updateMouse(newPosition point: CGPoint) {
        
        viewMouse = point
        
        scene.updateMouse(
            newTransformedPosition: transformedMouse,
            viewportTransform: viewportTransform
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
        
        let a = viewportTransform.rotation
        
        let s1 = viewportTransform.scale
        let s2 = s1 * (1 + delta)
        
        let cosa = cos(a.radians)
        let sina = sin(a.radians)
        
        let xc = transformedMouse.x
        let yc = transformedMouse.y
        
        let offset = (s1-s2)*Vector(
            dx: xc*cosa - yc*sina,
            dy: yc*cosa + xc*sina
        )
        
        viewportTransform.scale = s2
        viewportTransform.translation += offset
    }
    
    func rotateViewport(by delta: Angle) {
        
        let a1 = viewportTransform.rotation
        let a2 = a1 + delta
        
        let s = viewportTransform.scale
        
        let cosa = cos(a1.radians)-cos(a2.radians)
        let sina = sin(a1.radians)-sin(a2.radians)
        
        let xc = transformedMouse.x
        let yc = transformedMouse.y
        
        let offset = s*Vector(
            dx: xc*cosa - yc*sina,
            dy: yc*cosa + xc*sina
        )
        
        viewportTransform.rotation = a2
        viewportTransform.translation += offset
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
        
        let bounds = scene.bounds
        
        if let maxX = bounds.maxX, let minX = bounds.minX,
           let maxY = bounds.maxY, let minY = bounds.minY{
            
            let boundsWidth = maxX - minX
            let boundsHeight = maxY - minY
            let boundsSize = max(boundsWidth, boundsHeight)
            
            let windowSize = min(canvasSize.width, canvasSize.height)*0.6
            
            let a: Angle = .zero
            let s = windowSize/boundsSize
            
            let cosa = cos(a.radians)
            let sina = sin(a.radians)
            
            let xc = (minX + maxX)/2
            let yc = (minY + maxY)/2
            
            viewportTransform.translation = -s*Vector(
                dx: xc*cosa - yc*sina,
                dy: yc*cosa + xc*sina
            )
            viewportTransform.rotation = a
            viewportTransform.scale = s
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
