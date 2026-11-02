import SwiftUI



struct ViewportTransform {
    
    var translation: Vector
    var rotation: Angle
    var scale: CGFloat
    
    static var `default`: ViewportTransform {
        .init(translation: .zero, rotation: .zero, scale: 1)
    }
    
    var inverseTransform: CGAffineTransform {
        .identity
        .concatenating(.init(translationX: -translation.dx, y: -translation.dy))
        .concatenating(.init(rotationAngle: -rotation.radians))
        .concatenating(.init(scaleX: 1/scale, y: 1/scale))
    }
}


struct ContentView: View {
    
    
    @State private var scene: OpticsScene = .testScene
    
    @State private var canvasSize: CGSize = .zero
    
    @State private var viewportTransform: ViewportTransform = .default
    @State private var viewportTransformOnLastMouseDown: ViewportTransform? = nil
    
    @State private var screenMouse: CGPoint = .zero
    @State private var screenMouseOnLastDown: CGPoint = .zero
    @State private var screenMouseOnLastUp: CGPoint = .zero
    
    @State private var draggingObject: Lense? = nil
    @State private var draggingObjectOffset: Vector? = nil
    
    @State private var zoomOnScroll: Bool = false
    
    
    private let zoomScrollCoeff: CGFloat = 0.01
    private let zoomPinchCoeff: CGFloat = 0.5
    private let rotateCoeff: CGFloat = 1.0
    
    private let fitCoeff: CGFloat = 0.6
    
    
    let gridBaseScreenSize: CGFloat = 20
    
    var gridSnapSize: CGFloat {
        snap(gridBaseScreenSize/viewportTransform.scale, onClosestPowerOf: 10)
    }
    
    
    var viewportBaseOffset: Vector { // origin at center of the screen
        .init(dx: canvasSize.width/2, dy: canvasSize.height/2)
    }
    
    var worldMouse: CGPoint {
        screenMouse.applying(viewportTransform.inverseTransform)
    }

    var worldMouseSnapped: CGPoint {
        snap(worldMouse, onClosestMultipleOf: gridSnapSize)
    }
    
    
    var body: some View {
        
        VStack(alignment: .trailing) {
            
            ZStack {
                
                Canvas { context, canvasSize in
                    
                    context.scaleBy(x: 1, y: -1)
                    context.translateBy(x: 0, y: -canvasSize.height)
                    context.translateBy(x: viewportBaseOffset.dx, y: viewportBaseOffset.dy)
                    
                    let renderer = Renderer(
                        context: context,
                        canvasSize: canvasSize,
                        viewportTransform: viewportTransform,
                        gridSnapSize: gridSnapSize,
                        worldMouse: worldMouse,
                        worldMouseSnapped: worldMouseSnapped,
                        hoveringObject: scene.hoveringObject
                    )
                    renderer.render(scene)
                }
                .background(GeometryReader { proxy in
                    Color.clear.onChange(of: proxy.size, initial: true) { _, newSize in
                        self.canvasSize = newSize
                    }
                })
                
                MouseEventsArea(
                    onMouseMove: { point in
                        moveMouse(toNewScreenPosition: point)
                    },
                    onMouseDown: { point in
                        draggingObject = scene.hoveringObject
                        draggingObjectOffset = scene.hoveringObjectOffsetFromMouse
                        screenMouseOnLastDown = screenMouse
                        viewportTransformOnLastMouseDown = viewportTransform
                    },
                    onMouseUp: { point in
                        draggingObject = nil
                        screenMouseOnLastUp = screenMouse
                    },
                    onMouseDrag: { point in
                        moveMouse(toNewScreenPosition: point, dragging: true)
                    },
                    onScroll: { dx, dy, modifiers, phase, momentumPhase in
                        if phase == .began {
                            zoomOnScroll = modifiers.contains(.option)
                        }
                        if zoomOnScroll {
                            if momentumPhase == [] {
                                zoomViewport(by: dy*zoomScrollCoeff)
                            }
                        } else {
                            panViewport(by: Vector(dx: dx, dy: -dy))
                        }
                    },
                    onRotate: { delta, point in
                        rotateViewport(by: delta*rotateCoeff)
                    },
                    onPinch: { delta, point in
                        zoomViewport(by: delta*zoomPinchCoeff)
                    },
                )
            }
            
            HStack {
                Text("Size: \(canvasSize.width); \(canvasSize.height)")
                Text("Translation: \(viewportTransform.translation.dx); \(viewportTransform.translation.dy)")
                Text("Rotation: \(viewportTransform.rotation.degrees)°")
                Text("Scale: \(viewportTransform.scale)")
                Text("-")
                Text("View: \(screenMouse.x); \(screenMouse.y)")
                Text("Transformed: \(worldMouse.x); \(worldMouse.y)")
                Text("Snapped: \(worldMouseSnapped.x); \(worldMouseSnapped.y)")
            }
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .padding(.horizontal)
        }
        .frame(minWidth: 1600, minHeight: 800)
        .toolbar {
            ToolbarItem { Button("􀐩") { fitViewport() }}
            ToolbarItem { Button("􂣾") { resetViewport() }}
        }
    }
    
    
    func moveMouse(toNewScreenPosition sp: CGPoint, dragging: Bool = false) {
        
        screenMouse = sp.applying(.init(translationX: -viewportBaseOffset.dx, y: -viewportBaseOffset.dy))
        
        scene.moveMouse(
            toNewWorldPosition: worldMouse,
            viewportTransform: viewportTransform
        )
        
        if dragging {
            
            if let object = draggingObject, let offset = draggingObjectOffset {
                
                object.position = worldMouseSnapped + offset
                
            } else if let base = viewportTransformOnLastMouseDown {
                
                viewportTransform.translation = base.translation + screenMouse - screenMouseOnLastDown
            }
        }
    }
    
    
    func resetViewport() {
        
        viewportTransform = .default
    }
    
    
    func panViewport(by v: Vector) {
        
        viewportTransform.translation += v
    }
    
    
    func panViewport(toHaveWorldPoint wp: CGPoint, appearOnScreenAt sp: CGPoint) {
        
        let r = viewportTransform.rotation
        let s = viewportTransform.scale
        
        let cosr = cos(r.radians)
        let sinr = sin(r.radians)
        
        viewportTransform.translation = Vector(
            dx: sp.x - s*(wp.x*cosr - wp.y*sinr),
            dy: sp.y - s*(wp.y*cosr + wp.x*sinr)
        )
    }

    
    func rotateViewport(by delta: Angle) {
        
        let (wp, sp) = (worldMouse, screenMouse)
        viewportTransform.rotation += delta
        panViewport(toHaveWorldPoint: wp, appearOnScreenAt: sp)
    }
    

    func zoomViewport(by delta: CGFloat) {
        
        let (wp, sp) = (worldMouse, screenMouse)
        viewportTransform.scale *= (1 + delta)
        panViewport(toHaveWorldPoint: wp, appearOnScreenAt: sp)
    }
    
    
    func fitViewport() {
        
        if let bounds = scene.bounds {
            
            let boundsSize = max(bounds.width, bounds.height)
            let windowSize = min(self.canvasSize.width, self.canvasSize.height)
            
            let fitScale = windowSize/boundsSize
            
            viewportTransform.rotation = .zero
            viewportTransform.scale = fitScale*fitCoeff
            
            panViewport(toHaveWorldPoint: bounds.center, appearOnScreenAt: .zero)
        }
    }
}

#Preview {
    ContentView()
}
