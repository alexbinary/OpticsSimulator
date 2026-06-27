import SwiftUI



struct ContentView: View {
    
    
    @State private var canvasSize: CGSize = .zero
    @State private var mouse: CGPoint = .zero
    
    @State private var viewportCenter: CGPoint = .zero
    @State private var viewportRotation: Angle = .zero
    @State private var viewportZoom: CGFloat = 1
    
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                Canvas { context, size in
                    
                    let renderer = Renderer(
                        context: context,
                        canvasSize: size,
                        viewportCenter: viewportCenter,
                        viewportRotation: viewportRotation,
                        viewportZoom: viewportZoom,
                        mouse: localMouse
                    )
                    renderer.render(
                        lense: Lense(
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
        }
        .frame(minWidth: 1600, minHeight: 800)
    }
    
    
    var localMouse: CGPoint {
        
        return mouse
            .applying(.init(
                translationX: -canvasSize.width/2, y: -canvasSize.height/2)
            )
            .applying(.init(
                translationX: -viewportCenter.x, y: -viewportCenter.y)
            )
            .applying(.init(
                rotationAngle: -viewportRotation.radians)
            )
            .applying(.init(
                scaleX: 1/viewportZoom, y: 1/viewportZoom)
            )
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
    let canvasSize: CGSize
    
    let viewportCenter: CGPoint
    let viewportRotation: Angle
    let viewportZoom: CGFloat
    
    let mouse: CGPoint
    let viewportBounds: CGRect
    
    
    init(
        context: GraphicsContext,
        canvasSize: CGSize,
        viewportCenter: CGPoint,
        viewportRotation: Angle,
        viewportZoom: CGFloat,
        mouse: CGPoint
    ) {
        self.context = context
        self.canvasSize = canvasSize
        self.viewportCenter = viewportCenter
        self.viewportRotation = viewportRotation
        self.viewportZoom = viewportZoom
        self.mouse = mouse
        
        let center = viewportCenter.applying(.init(rotationAngle: -viewportRotation.radians))
        
        let dim = max(canvasSize.width, canvasSize.height)
        
        let minX: CGFloat = (-dim-center.x)/viewportZoom
        let maxX: CGFloat = (dim-center.x)/viewportZoom
        
        let minY: CGFloat = (-dim-center.y)/viewportZoom
        let maxY: CGFloat = (dim-center.y)/viewportZoom
        
        self.viewportBounds = CGRect(
            origin: CGPoint(x: minX, y: minY),
            size: CGSize(width: maxX-minX, height: maxY-minY)
        )
    }
    
    
    func lineWidth(_ width: CGFloat) -> CGFloat {
        
        return width/viewportZoom
    }
    
    
    func render(lense: Lense) {
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -canvasSize.height)
        context.translateBy(x: canvasSize.width/2, y: canvasSize.height/2)
        
        context.translateBy(x: viewportCenter.x, y: viewportCenter.y)
        context.rotate(by: viewportRotation)
        context.scaleBy(x: viewportZoom, y: viewportZoom)
        drawAxis()
        drawGrid()

        draw(lense)
        
        drawCursor()
    }
    
    
    func drawAxis() {
        
        var path = Path()
        let color: Color = .white
        
        path.move(to: CGPoint(x: viewportBounds.minX, y: 0))
        path.addLine(to: CGPoint(x: viewportBounds.maxX, y: 0))
        
        path.move(to: CGPoint(x: 0, y: viewportBounds.minY))
        path.addLine(to: CGPoint(x: 0, y: viewportBounds.maxY))
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth(1))
    }
    
    
    func align(_ n: CGFloat, on ref: CGFloat) -> CGFloat {
        
        return ceil(n/ref)*ref
    }
    
    
    func drawGrid() {
        
        var path = Path()
        let color: Color = .white
        
        let spacing: CGFloat = 100
        let r: CGFloat = 10
        
        let minX = viewportBounds.minX
        let maxX = viewportBounds.maxX
        let minY = viewportBounds.minY
        let maxY = viewportBounds.maxY
        
        let span = max(maxX - minX, maxY - minY)
        let n = span/spacing
        
        let startX = align(
            -n/2*spacing + minX + (maxX-minX)/2,
            on: spacing
        )
        let startY = align(
            -n/2*spacing + minY + (maxY-minY)/2,
             on: spacing
        )
        
        for ix in 1...Int(n) {
            for iy in 1...Int(n) {
                
                path.addArc(
                    center: CGPoint(
                        x: startX + CGFloat(ix)*spacing,
                        y: startY + CGFloat(iy)*spacing
                    ), radius: r,
                    startAngle: .zero, endAngle: .degrees(360), clockwise: true
                )
            }
        }
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth(1))
    }
    
    
    func drawCursor() {
        
        var path = Path()
        let color: Color = .white
        
        path.move(to: CGPoint(x: viewportBounds.minX, y: mouse.y))
        path.addLine(to: CGPoint(x: viewportBounds.maxX, y: mouse.y))
        
        path.move(to: CGPoint(x: mouse.x, y: viewportBounds.minY))
        path.addLine(to: CGPoint(x: mouse.x, y: viewportBounds.maxY))
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth(1))
    }
    
    
    func draw(_ lense: Lense) {
        
        var context = context
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
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth(2))
        
        // connect focal points
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: -f, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -h))
        path.addLine(to: CGPoint(x: f, y: 0))
        path.addLine(to: CGPoint(x: 0, y: h))
        
        context.stroke(path, with: .color(color), style: StrokeStyle(
            lineWidth: lineWidth(1),
            dash: [4, 4]
        ))
    }
}
