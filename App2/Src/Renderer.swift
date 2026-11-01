
import SwiftUI



class Renderer {
    
    var context: GraphicsContext
    let canvasSize: CGSize
    let viewportTransform: ViewportTransform
    let gridSnapSize: CGFloat
    let worldMouse: CGPoint
    let worldMouseSnapped: CGPoint
    let hoveringObject: Lense?
    
    private let worldVisibleBounds: CGRect
    
    
    init(
        context: GraphicsContext,
        canvasSize: CGSize,
        viewportTransform: ViewportTransform,
        gridSnapSize: CGFloat,
        worldMouse: CGPoint,
        worldMouseSnapped: CGPoint,
        hoveringObject: Lense?
    ) {
        self.context = context
        self.canvasSize = canvasSize
        self.viewportTransform = viewportTransform
        self.gridSnapSize = gridSnapSize
        self.worldMouse = worldMouse
        self.worldMouseSnapped = worldMouseSnapped
        self.hoveringObject = hoveringObject
        
        self.worldVisibleBounds = CGRect(
            origin: CGPoint(x: -canvasSize.width/2, y: -canvasSize.height/2),
            size: canvasSize
        ).applying(viewportTransform.inverseTransform)
    }
    
    
    func screenValue(_ value: CGFloat) -> CGFloat {
        
        return value/viewportTransform.scale
    }
    
    
    func worldValue(_ value: CGFloat) -> CGFloat {
        
        return value
    }
    
    
    func render(_ scene: OpticsScene) {
        
        context.translateBy(x: viewportTransform.translation.dx, y: viewportTransform.translation.dy)
        context.rotate(by: viewportTransform.rotation)
        context.scaleBy(x: viewportTransform.scale, y: viewportTransform.scale)
        
        drawGrid()

        let lense = scene.lenses.first!
        draw(lense, highlighted: self.hoveringObject != nil)
        if let bounds = scene.bounds { drawDebugRect(bounds) }
        
        drawCursor()
    }
    
    
    func drawGrid() {
        
        var path = Path()
        let color: Color = .white
        
        let r: CGFloat = screenValue(0.1)
        
        let minX = worldVisibleBounds.minX
        let maxX = worldVisibleBounds.maxX
        let minY = worldVisibleBounds.minY
        let maxY = worldVisibleBounds.maxY
        
        let span = max(maxX - minX, maxY - minY)
        let n = span/gridSnapSize
        
        let startX = snap((minX + maxX)/2 - n/2*gridSnapSize, onClosestMultipleOf: gridSnapSize)
        let startY = snap((minY + maxY)/2 - n/2*gridSnapSize, onClosestMultipleOf: gridSnapSize)
        
        for ix in 1...Int(n) {
            for iy in 1...Int(n) {
                
                path.addArc(
                    center: CGPoint(x: startX + CGFloat(ix)*gridSnapSize, y: startY + CGFloat(iy)*gridSnapSize),
                    radius: r, startAngle: .zero, endAngle: .degrees(360), clockwise: true
                )
            }
        }
        
        context.stroke(path, with: .color(color.opacity(0.5)), lineWidth: screenValue(1))
    }
    
    
    func drawCursor() {
        
        let mouse = worldMouseSnapped
        
        var path = Path()
        let color: Color = .white
        
        path.move(to: CGPoint(x: worldVisibleBounds.minX, y: mouse.y))
        path.addLine(to: CGPoint(x: worldVisibleBounds.maxX, y: mouse.y))
        
        path.move(to: CGPoint(x: mouse.x, y: worldVisibleBounds.minY))
        path.addLine(to: CGPoint(x: mouse.x, y: worldVisibleBounds.maxY))
        
        context.stroke(path, with: .color(color), lineWidth: screenValue(1))
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
        
        context.stroke(path, with: .color(color), lineWidth: screenValue(highlighted ? 4 : 2))
        
        path = Path()
        
        // connect focal points
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: -f, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -h))
        path.addLine(to: CGPoint(x: f, y: 0))
        path.addLine(to: CGPoint(x: 0, y: h))
        
        context.stroke(path, with: .color(color), style: StrokeStyle(
            lineWidth: screenValue(1),
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
    
    
    func drawDebugRect(_ bounds: Bounds) {
        
        var path = Path()
        
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
    
        path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
    
        path.move(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
    
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        
        context.stroke(path, with: .color(.yellow), lineWidth: 2)
    }
}
