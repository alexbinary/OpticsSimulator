import SwiftUI



struct ContentView: View {
    
    
    @State private var scene: OpticsScene = {
        let scene = OpticsScene()
        scene.add(Lense(
            type: .convergent,
            diameter: 100,
            focalLength: 10,
            position: CGPoint(x: 0, y: 0),
            rotation: .degrees(45)
        ))
        return scene
    }()
    
    @State private var canvasSize: CGSize = .zero
    @State private var mouse: CGPoint = .zero
    
    @State private var viewportCenter: CGPoint = .zero
    @State private var viewportRotation: Angle = .zero
    @State private var viewportZoom: CGFloat = 1
    
    
    var body: some View {
        
        VStack(alignment: .trailing) {
            
            ZStack {
                
                Canvas { context, size in
                    
                    let renderer = Renderer(
                        context: context,
                        canvasSize: size,
                        viewport: Viewport(
                            center: viewportCenter,
                            rotation: viewportRotation,
                            zoom: viewportZoom
                        ),
                        gridSnapSize: gridSnapSize,
                        mouse: localMouse,
                        sceneBoundingRect: scene.boundingRect
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
                    onMove: { point in
                        mouse = point
                    },
                    onScroll: { dx, dy, modifiers, phase, momentumPhase in
                        if modifiers.contains(.option) {
                            if momentumPhase == [] {
                                viewportZoom += dy*viewportZoom*0.01
                            }
                        } else {
                            viewportCenter = CGPoint(
                                x: viewportCenter.x + dx,
                                y: viewportCenter.y - dy
                            )
                        }
                    },
                    onRotate: { delta, point in
                        viewportRotation += delta
                    },
                    onPinch: { delta, point in
                        viewportZoom += delta*viewportZoom*0.5
                    }
                )
            }
            
            Text("\(localMouse.x); \(localMouse.y)")
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
    
    
    var localMouse: CGPoint {
        
        let mouse = mouse.applying(inverseViewportTransform)
        
        return snap(mouse, onMultipleOf: gridSnapSize/10)
    }
    
    
    var inverseViewportTransform: CGAffineTransform {
        
        CGAffineTransform.identity
            .concatenating(.init(
                translationX: -canvasSize.width/2, y: -canvasSize.height/2)
            )
            .concatenating(.init(
                translationX: -viewportCenter.x, y: -viewportCenter.y)
            )
            .concatenating(.init(
                rotationAngle: -viewportRotation.radians)
            )
            .concatenating(.init(
                scaleX: 1/viewportZoom, y: 1/viewportZoom)
            )
    }
    
    
    var gridSnapSize: CGFloat {
        
        return snap(20/viewportZoom, onPowerOf: 10)
    }
    
    
    func resetViewport() {
        
        viewportCenter = .zero
        viewportRotation = .zero
        viewportZoom = 1
    }
    
    
    func fitViewport() {
        
        let rect = scene.boundingRect
        
        viewportCenter = CGPoint(
            x: (rect.maxX + rect.minX)/2,
            y: (rect.maxY + rect.minY)/2
        )
        
        let size = max(rect.width, rect.height)
        let window = min(canvasSize.width, canvasSize.height)*0.6
        
        viewportZoom = window/size
    }
}

#Preview {
    ContentView()
}



func snap(_ n: CGFloat, onMultipleOf ref: CGFloat) -> CGFloat {
    
    return ceil(n/ref)*ref
}


func snap(_ p: CGPoint, onMultipleOf ref: CGFloat) -> CGPoint {
    
    return CGPoint(
        x: snap(p.x, onMultipleOf: ref),
        y: snap(p.y, onMultipleOf: ref)
    )
}


func snap(_ n: CGFloat, onPowerOf ref: CGFloat) -> CGFloat {
    
    return pow(ref, ceil(log(n)/log(ref)))
}
