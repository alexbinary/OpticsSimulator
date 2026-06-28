
import SwiftUI



class Renderer {
    
    var context: GraphicsContext
    let canvasSize: CGSize
    
    let viewportTransform: ViewportTransform
    let gridSnapSize: CGFloat
    
    let transformedMouse: CGPoint
    let transformedMouseSnapped: CGPoint
    let hoveringLense: Lense?
    
    private let visibleBounds: CGRect
    
    
    init(
        context: GraphicsContext,
        canvasSize: CGSize,
        viewportTransform: ViewportTransform,
        gridSnapSize: CGFloat,
        transformedMouse: CGPoint,
        transformedMouseSnapped: CGPoint,
        hoveringLense: Lense?
    ) {
        self.context = context
        self.canvasSize = canvasSize
        self.viewportTransform = viewportTransform
        self.gridSnapSize = gridSnapSize
        
        self.transformedMouse = transformedMouse
        self.transformedMouseSnapped = transformedMouseSnapped
        self.hoveringLense = hoveringLense
        
        let center = CGPoint(
            x: viewportTransform.translation.dx,
            y: viewportTransform.translation.dy
        ).applying(.init(
            rotationAngle: -viewportTransform.rotation.radians
        ))
        
        let dim = max(canvasSize.width, canvasSize.height)
        
        let minX: CGFloat = (-dim-center.x)/viewportTransform.scale
        let maxX: CGFloat = (dim-center.x)/viewportTransform.scale
        
        let minY: CGFloat = (-dim-center.y)/viewportTransform.scale
        let maxY: CGFloat = (dim-center.y)/viewportTransform.scale
        
        self.visibleBounds = CGRect(
            origin: CGPoint(x: minX, y: minY),
            size: CGSize(width: maxX-minX, height: maxY-minY)
        )
    }
    
    
    func lineWidth(_ width: CGFloat) -> CGFloat {
        
        return width/viewportTransform.scale
    }
    
    
    func render(_ scene: OpticsScene) {
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -canvasSize.height)
        drawDebugAxis() // <--- view mouse
        context.translateBy(x: canvasSize.width/2, y: canvasSize.height/2)
        drawDebugAxis()
        
        context.translateBy(
            x: viewportTransform.translation.dx,
            y: viewportTransform.translation.dy
        )
        drawDebugAxis()
        context.rotate(by: viewportTransform.rotation)
        drawDebugAxis()
        context.scaleBy(x: viewportTransform.scale, y: viewportTransform.scale)
        drawDebugAxis() // <--- transformed
        
        drawGrid()

        let lense = scene.lenses.first!
        draw(lense, highlighted: self.hoveringLense != nil)
        drawDebugRect(lense.boundingRect)
        
//        drawCursor()
    }
    
    
    func drawGrid() {
        
        var path = Path()
        let color: Color = .white
        
        let r: CGFloat = 0.1/viewportTransform.scale
        
        let minX = visibleBounds.minX
        let maxX = visibleBounds.maxX
        let minY = visibleBounds.minY
        let maxY = visibleBounds.maxY
        
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
        
        let mouse = transformedMouseSnapped
        
        var path = Path()
        let color: Color = .white
        
        path.move(to: CGPoint(x: visibleBounds.minX, y: mouse.y))
        path.addLine(to: CGPoint(x: visibleBounds.maxX, y: mouse.y))
        
        path.move(to: CGPoint(x: mouse.x, y: visibleBounds.minY))
        path.addLine(to: CGPoint(x: mouse.x, y: visibleBounds.maxY))
        
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
    
    
    func drawDebugAxis() {
        
        let size: CGFloat = 100
        let a: CGFloat = 5
                
        // X
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size, y: 0))
        path.addLine(to: CGPoint(x: size-a, y: a))
        path.addLine(to: CGPoint(x: size-a, y: -a))
        path.addLine(to: CGPoint(x: size, y: 0))
        
        context.stroke(path, with: .color(.green), lineWidth: 2)
        
        // Y
        path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: a, y: size-a))
        path.addLine(to: CGPoint(x: -a, y: size-a))
        path.addLine(to: CGPoint(x: 0, y: size))
        
        context.stroke(path, with: .color(.blue), lineWidth: 2)
    }
    
    
    func drawDebugRect(_ rect: CGRect) {
        
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        context.stroke(path, with: .color(.yellow), lineWidth: 2)
    }
}
