import SwiftUI


struct ContentView: View {
    
    @State private var objectPosition: CGFloat = 0.25
    @State private var objectSize: CGFloat = 1
    
    @State private var lensePosition: CGFloat = 0.5
    @State private var lenseType: LenseType = .convergent
    @State private var focalLength: CGFloat = 0.25

    var body: some View {
        
        VStack {
            
            Canvas { context, size in
                
                // center at middle height, positive up
                
                context.translateBy(x: 0, y: size.height/2)
                context.scaleBy(x: 1, y: -1)
                
                // setup scene
                
                let objectPos = size.width*objectPosition
                let objectSize = size.height/2*0.9*objectSize
                
                let lensePos = size.width*lensePosition
                let lenseF = size.width*focalLength/2
                
                let lense = Lense(type: lenseType, focalLength: lenseF)
                let scene = OpticsScene(objectPos: objectPos, objectSize: objectSize, lensePos: lensePos, lense: lense)
                
                // render
                
                let engine = DrawEngine(context: context, size: size)
                engine.render(scene)
                
                // simulated rays
                
                var path = Path()
                
                // parallel ray object > lense
                path.move(to: CGPoint(x: scene.objectPos, y: scene.objectSize))
                path.addLine(to: CGPoint(x: scene.lensePos, y: scene.objectSize))
                
                // parallel ray lense > F
                if lense.type == .convergent {
                    path.move(to: CGPoint(x: scene.lensePos, y: scene.objectSize))
                    path.addLine(to: CGPoint(x: scene.lensePos+scene.lense.focalLength, y: 0))
                } else {
                    path.move(to: CGPoint(x: scene.lensePos, y: scene.objectSize))
                    path.addLine(to: CGPoint(x: scene.lensePos-scene.lense.focalLength, y: 0))
                }
                
                // parallel ray F > image
                if lense.type == .convergent {
                    path.move(to: CGPoint(x: scene.lensePos+scene.lense.focalLength, y: 0))
                    path.addLine(to: CGPoint(x: scene.imagePos, y: scene.imageSize))
                }
                
                // center ray object > O
                path.move(to: CGPoint(x: scene.objectPos, y: scene.objectSize))
                path.addLine(to: CGPoint(x: scene.lensePos, y: 0))
                
                // center ray O > image
                if lense.type == .convergent {
                    path.move(to: CGPoint(x: scene.lensePos, y: 0))
                    path.addLine(to: CGPoint(x: scene.imagePos, y: scene.imageSize))
                }
                
                context.stroke(path, with: .color(.yellow), lineWidth: 1)
            }
            Form {
                Slider(value: $objectPosition, in: 0...1) {
                    Text("Object position")
                }
                Slider(value: $objectSize, in: 0...1) {
                    Text("Object size")
                }
                Slider(value: $lensePosition, in: 0...1) {
                    Text("Lense position")
                }
                Slider(value: $focalLength, in: 0...1) {
                    Text("Lense focal length")
                }
                Picker("Lense type", selection: $lenseType) {
                    ForEach(LenseType.allCases) { type in
                        Text(type.label).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding([.horizontal])
        .frame(minWidth: 200, minHeight: 200)
        .padding()
    }
}


struct OpticsScene {
    
    let objectPos: CGFloat
    let objectSize: CGFloat
    
    let lensePos: CGFloat
    let lense: Lense
    
    let imagePos: CGFloat
    let imageSize: CGFloat
    
    
    init(objectPos: CGFloat, objectSize: CGFloat, lensePos: CGFloat, lense: Lense) {
        
        self.objectPos = objectPos
        self.objectSize = objectSize
        self.lensePos = lensePos
        self.lense = lense
        
        // compute image
        let f = lense.focalLength * (lense.type == .convergent ? +1 : -1)
        let distO = lensePos - objectPos
        let gamma = f / (distO - f)
        let distI = distO * gamma
        
        self.imagePos = lensePos + distI
        self.imageSize = -objectSize * gamma
    }
}


struct DrawEngine {
    
    let context: GraphicsContext
    let size: CGSize

    func drawAxis() {
        
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        
        context.stroke(path, with: .color(.gray), lineWidth: 1)
    }
    
    func pathForArrow(at h: CGFloat, pointing direction: ArrowDirection) -> Path {
        
        let a: CGFloat = 5
        let d: CGFloat = direction == .towardAxis ? +1 : -1
        
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: a, y: a))
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: -a, y: a))
        
        return path.applying(
            .init(scaleX: 1, y: h > 0 ? -d : +d)
            .concatenating(.init(translationX: 0, y: h))
        )
    }
    
    func drawObject(at position: CGFloat, size: CGFloat) {
        
        drawObjectOrImage(at: position, size: size, color: .blue)
    }
    
    func drawImage(at position: CGFloat, size: CGFloat) {
        
        drawObjectOrImage(at: position, size: size, color: .green)
    }
        
    func drawObjectOrImage(at position: CGFloat, size: CGFloat, color: Color) {
        
        let x = position
        let h = size
        
        let lineWidth: CGFloat = 2
        
        var path = Path()
        
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: h))
        
        path.addPath(pathForArrow(at: h, pointing: .towardAxis),
                     transform: .init(translationX: position, y: 0))
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth)
    }
    
    func draw(_ lense: Lense, at position: CGFloat) {
        
        let x = position
        let h = size.height/2*0.9
        
        let f = lense.focalLength
        let m: CGFloat = 5
        
        let arrowDir: ArrowDirection = lense.type == .convergent ? .towardAxis : .awayFromAxis
        
        var path = Path()
        
        // lense body
        path.move(to: CGPoint(x: x, y: h))
        path.addLine(to: CGPoint(x: x, y: -h))
        
        // arrows
        path.addPath(pathForArrow(at: h, pointing: arrowDir),
                     transform: .init(translationX: x, y: 0))
        path.addPath(pathForArrow(at: -h, pointing: arrowDir),
                     transform: .init(translationX: x, y: 0))
        
        // focal indicator before
        path.move(to: CGPoint(x: x-f, y: -m))
        path.addLine(to: CGPoint(x: x-f, y: +m))
        
        // focal indicator after
        path.move(to: CGPoint(x: x+f, y: -m))
        path.addLine(to: CGPoint(x: x+f, y: +m))
        
        context.stroke(path, with: .color(.red), lineWidth: 2)
    }
    
    func render(_ scene: OpticsScene) {
        
        drawAxis()
        drawObject(at: scene.objectPos, size: scene.objectSize)
        draw(scene.lense, at: scene.lensePos)
        drawImage(at: scene.imagePos, size: scene.imageSize)
    }
}


enum ArrowDirection {
    
    case towardAxis, awayFromAxis
}


enum LenseType: CaseIterable, Identifiable {
    
    case convergent, divergent
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .convergent: return "Convergent"
        case .divergent: return "Divergent"
        }
    }
}

struct Lense {
    
    let type: LenseType
    let focalLength: CGFloat
}


#Preview {
    ContentView()
}
