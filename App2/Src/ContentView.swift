import SwiftUI



struct ContentView: View {
    
    
    @State private var viewportCenter: CGPoint = .zero
    @State private var viewportRotation: Angle = .zero
    @State private var viewportZoom: CGFloat = 1
    
    @State private var canvasSize: CGSize = .zero
    

    var body: some View {
        
        ZStack {
        
            Canvas { context, size in
                
                // move origin to canvas center, y positive up
                context.translateBy(x: size.width/2, y: size.height/2)
//                context.translateBy(x: 0, y: size.height)
                context.scaleBy(x: 1, y: -1)
                
                let renderer = Renderer(
                    context: context,
                    renderSize: size,
                    viewportCenter: viewportCenter,
                    viewportRotation: viewportRotation,
                    viewportZoom: viewportZoom
                )
                renderer.draw(
                    Lense(
                        type: .convergent,
                        diameter: 100,
                        focalLength: 10,
                        position: CGPoint(x: 0, y: 0),
                        rotation: .degrees(45)
                    )
                )
                
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onChange(of: proxy.size, initial: true) { _, newSize in
                            // update canvas size safely outside of drawing
                            self.canvasSize = newSize
                        }
                }
            )
            MouseEventsArea(
                onMove: { point in
                    print("canvas size: \(canvasSize)")
                    viewportCenter = CGPoint(
                        x: point.x - canvasSize.width/2,
                        y: point.y - canvasSize.height/2,
                    )
                },
                onScroll: { dx, dy, modifiers, phase, momentumPhase in
                    if modifiers.contains(.option) {
                        if momentumPhase == [] {
                            viewportZoom += dy*0.001*viewportZoom
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
                    viewportZoom += delta
                }
            )
        }
        .frame(minWidth: 1600, minHeight: 800)
    }
}

#Preview {
    ContentView()
}



enum LenseType {
    
    case convergent, divergent
}

struct Lense {
    
    var type: LenseType
    var diameter: CGFloat
    var focalLength: CGFloat
    var position: CGPoint
    var rotation: Angle
}



class Renderer {
    
    var context: GraphicsContext
    let renderSize: CGSize
    
    let viewportCenter: CGPoint
    let viewportRotation: Angle
    let viewportZoom: CGFloat
    
    
    init(
        context: GraphicsContext,
        renderSize: CGSize,
        viewportCenter: CGPoint,
        viewportRotation: Angle,
        viewportZoom: CGFloat
    ) {
        self.context = context
        self.renderSize = renderSize
        self.viewportCenter = viewportCenter
        self.viewportRotation = viewportRotation
        self.viewportZoom = viewportZoom
    }
    
    
    func draw(_ lense: Lense) {
        
        // apply viewport
        context.translateBy(x: viewportCenter.x, y: viewportCenter.y)
        context.rotate(by: viewportRotation)
        context.scaleBy(x: viewportZoom, y: viewportZoom)

        // move to local coordinates
        context.translateBy(x: lense.position.x, y: lense.position.y)
        context.rotate(by: lense.rotation)

        let h: CGFloat = lense.diameter/2
        let f: CGFloat = lense.focalLength
        let a: CGFloat = 5

        var path = Path()
        let color: Color = .red
        
        // lense body
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: -h))
        
        // arrow top
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: a, y: h-a))
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: -a, y: h-a))
        
        // arrow bottom
        path.move(to: CGPoint(x: 0, y: -h))
        path.addLine(to: CGPoint(x: a, y: -h+a))
        path.move(to: CGPoint(x: 0, y: -h))
        path.addLine(to: CGPoint(x: -a, y: -h+a))
        
        context.stroke(path, with: .color(color), lineWidth: 2)
        
        // connect focal points
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: -f, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -h))
        path.addLine(to: CGPoint(x: f, y: 0))
        path.addLine(to: CGPoint(x: 0, y: h))
        
        context.stroke(path, with: .color(color), style: StrokeStyle(
            lineWidth: 1,
            dash: [4, 4]
        ))
    }
}
