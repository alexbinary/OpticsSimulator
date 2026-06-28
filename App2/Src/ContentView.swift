import SwiftUI



struct ContentView: View {
    
    
    @State private var scene: OpticsScene = {
        let scene = OpticsScene()
        scene.add(Lense(
            type: .convergent,
            diameter: 100,
            focalLength: 10,
            position: CGPoint(x: 100, y: 100),
            rotation: .degrees(45)
        ))
        return scene
    }()
    
    @State private var selectedLense: Lense? = nil
    
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
                        mouseSnapped: localMouseSnapped,
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
                        mouse = point
                        scene.setMouse(localMouse, zoom: viewportZoom)
                    },
                    onMouseDown: { point in
                        selectedLense = scene.hoveringLense
                    },
                    onMouseUp: { point in
                        selectedLense = nil
                    },
                    onMouseDrag: { point in
                        selectedLense?.position = localMouseSnapped
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
                    },
                )
            }
            
            Text("\(localMouseSnapped.x); \(localMouseSnapped.y)")
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
        
        mouse.applying(inverseViewportTransform)
    }
    
    
    var localMouseSnapped: CGPoint {
        
        return snap(localMouse, onMultipleOf: gridSnapSize/10)
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
