import SwiftUI



struct ContentView: View {

    var body: some View {

        Canvas { context, size in
            
            // move origin to canvas center, y positive up
            context.translateBy(x: size.width/2, y: size.height/2)
            context.scaleBy(x: 1, y: -1)
            
            let renderer = Renderer(
                context: context,
                renderSize: size,
                viewportCenter: CGPoint(x: 0, y: 0),
                viewportZoom: 2
            )
            renderer.draw(
                Lense(
                    type: .convergent,
                    diameter: 100,
                    focalLength: 10,
                    position: CGPoint(x: 100, y: 100),
                    rotation: .degrees(45)
                )
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
    let viewportZoom: CGFloat
    
    
    init(
        context: GraphicsContext,
        renderSize: CGSize,
        viewportCenter: CGPoint,
        viewportZoom: CGFloat
    ) {
        self.context = context
        self.renderSize = renderSize
        self.viewportCenter = viewportCenter
        self.viewportZoom = viewportZoom
    }
    
    
    func draw(_ lense: Lense) {
        
        // apply viewport
        context.translateBy(x: viewportCenter.x, y: viewportCenter.y)
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

