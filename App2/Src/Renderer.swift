
import SwiftUI



struct Viewport {
    
    let center: CGPoint
    let rotation: Angle
    let zoom: CGFloat
}



class Renderer {
    
    var context: GraphicsContext
    let canvasSize: CGSize
    
    let viewport: Viewport
    let gridSnapSize: CGFloat
    
    let mouse: CGPoint
    let mouseSnapped: CGPoint
    let hoveringLense: Lense?
    
    private let viewportBounds: CGRect
    
    
    init(
        context: GraphicsContext,
        canvasSize: CGSize,
        viewport: Viewport,
        gridSnapSize: CGFloat,
        mouse: CGPoint,
        mouseSnapped: CGPoint,
        hoveringLense: Lense?
    ) {
        self.context = context
        self.canvasSize = canvasSize
        self.viewport = viewport
        self.gridSnapSize = gridSnapSize
        
        self.mouse = mouse
        self.mouseSnapped = mouseSnapped
        self.hoveringLense = hoveringLense
        
        let center = viewport.center.applying(.init(
            rotationAngle: -viewport.rotation.radians
        ))
        
        let dim = max(canvasSize.width, canvasSize.height)
        
        let minX: CGFloat = (-dim-center.x)/viewport.zoom
        let maxX: CGFloat = (dim-center.x)/viewport.zoom
        
        let minY: CGFloat = (-dim-center.y)/viewport.zoom
        let maxY: CGFloat = (dim-center.y)/viewport.zoom
        
        self.viewportBounds = CGRect(
            origin: CGPoint(x: minX, y: minY),
            size: CGSize(width: maxX-minX, height: maxY-minY)
        )
    }
    
    
    func lineWidth(_ width: CGFloat) -> CGFloat {
        
        return width/viewport.zoom
    }
    
    
    func render(_ scene: OpticsScene) {
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -canvasSize.height)
        context.translateBy(x: canvasSize.width/2, y: canvasSize.height/2)
        
        context.translateBy(x: viewport.center.x, y: viewport.center.y)
        context.rotate(by: viewport.rotation)
        context.scaleBy(x: viewport.zoom, y: viewport.zoom)
        drawGrid()

        let lense = scene.lenses.first!
        draw(lense, highlighted: self.hoveringLense != nil)
        
        drawCursor()
    }
    
    
    func drawGrid() {
        
        var path = Path()
        let color: Color = .white
        
        let r: CGFloat = 0.1/viewport.zoom
        
        let minX = viewportBounds.minX
        let maxX = viewportBounds.maxX
        let minY = viewportBounds.minY
        let maxY = viewportBounds.maxY
        
        let span = max(maxX - minX, maxY - minY)
        let n = span/gridSnapSize
        
        let startX = snap(
            -n/2*gridSnapSize + minX + (maxX-minX)/2,
            onMultipleOf: gridSnapSize
        )
        let startY = snap(
            -n/2*gridSnapSize + minY + (maxY-minY)/2,
             onMultipleOf: gridSnapSize
        )
        
        for ix in 1...Int(n) {
            for iy in 1...Int(n) {
                
                path.addArc(
                    center: CGPoint(
                        x: startX + CGFloat(ix)*gridSnapSize,
                        y: startY + CGFloat(iy)*gridSnapSize
                    ), radius: r,
                    startAngle: .zero, endAngle: .degrees(360), clockwise: true
                )
            }
        }
        
        context.stroke(path, with: .color(color.opacity(0.5)), lineWidth: lineWidth(1))
    }
    
    
    func drawCursor() {
        
        let mouse = mouseSnapped
        
        var path = Path()
        let color: Color = .white
        
        path.move(to: CGPoint(x: viewportBounds.minX, y: mouse.y))
        path.addLine(to: CGPoint(x: viewportBounds.maxX, y: mouse.y))
        
        path.move(to: CGPoint(x: mouse.x, y: viewportBounds.minY))
        path.addLine(to: CGPoint(x: mouse.x, y: viewportBounds.maxY))
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth(1))
    }
    
    
    func draw(_ lense: Lense, highlighted: Bool = false) {
        
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
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth(highlighted ? 4 : 2))
        
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
