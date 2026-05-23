import SwiftUI


struct ContentView: View {
    
    @State private var objectPosition: CGFloat = 0.25
    @State private var objectSize: CGFloat = 1
    
    @State private var lensePosition: CGFloat = 0.75
    @State private var lenseType: LenseType = .convergent
    @State private var lenseFocalLength: CGFloat = 0.25
    
    @State private var mirrorPosition: CGFloat = 0.6
    @State private var mirrorType: MirrorType = .convex
    @State private var mirrorFocalLength: CGFloat = 0.25

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
                let lenseF = size.width*lenseFocalLength/2
                
                let mirrorPos = size.width*mirrorPosition
                let mirrorF = size.width*mirrorFocalLength/2
                
                let lense = Lense(
                    pos: lensePos, type: lenseType, focalLength: lenseF
                )
                let mirror = SphericalMirror(
                    pos: mirrorPos, type: mirrorType, focalLength: mirrorF
                )
                
                let scene = OpticsScene(
                    objectPos: objectPos, objectSize: objectSize,
                    lense: lense, mirror: mirror
                )
                
                // render
                
                let engine = DrawEngine(context: context, size: size)
                engine.render(scene)
                
//                // simulated rays - lense
//                
//                var path = Path()
//                
//                // parallel ray object > lense
//                path.move(to: CGPoint(x: scene.objectPos, y: scene.objectSize))
//                path.addLine(to: CGPoint(x: scene.lense.pos, y: scene.objectSize))
//                
//                // parallel ray lense > F
//                if lense.type == .convergent {
//                    path.move(to: CGPoint(x: scene.lense.pos, y: scene.objectSize))
//                    path.addLine(to: CGPoint(x: scene.lense.pos+scene.lense.focalLength, y: 0))
//                } else {
//                    path.move(to: CGPoint(x: scene.lense.pos, y: scene.objectSize))
//                    path.addLine(to: CGPoint(x: scene.lense.pos-scene.lense.focalLength, y: 0))
//                }
//                
//                // parallel ray F > image
//                if lense.type == .convergent {
//                    path.move(to: CGPoint(x: scene.lense.pos+scene.lense.focalLength, y: 0))
//                    path.addLine(to: CGPoint(x: scene.imagePos, y: scene.imageSize))
//                }
//                
//                // center ray object > O
//                path.move(to: CGPoint(x: scene.objectPos, y: scene.objectSize))
//                path.addLine(to: CGPoint(x: scene.lense.pos, y: 0))
//                
//                // center ray O > image
//                if lense.type == .convergent {
//                    path.move(to: CGPoint(x: scene.lense.pos, y: 0))
//                    path.addLine(to: CGPoint(x: scene.imagePos, y: scene.imageSize))
//                }
//                
//                context.stroke(path, with: .color(.yellow), lineWidth: 1)
                
                // simulated rays - mirror
                
                var path = Path()
                
                // parallel ray object > mirror
                path.move(to: CGPoint(x: scene.objectPos, y: scene.objectSize))
                path.addLine(to: CGPoint(x: scene.mirror.pos, y: scene.objectSize))
                
                // parallel ray mirror > F
                if mirror.type == .concave {
                    path.move(to: CGPoint(x: scene.mirror.pos, y: scene.objectSize))
                    path.addLine(to: CGPoint(x: scene.mirror.pos-scene.mirror.focalLength, y: 0))
                } else {
                    path.move(to: CGPoint(x: scene.mirror.pos, y: scene.objectSize))
                    path.addLine(to: CGPoint(x: scene.mirror.pos+scene.mirror.focalLength, y: 0))
                }
                
                // parallel ray F > image
                if mirror.type == .concave {
                    path.move(to: CGPoint(x: scene.mirror.pos-scene.mirror.focalLength, y: 0))
                    path.addLine(to: CGPoint(x: scene.imagePos, y: scene.imageSize))
                }
                
                // center ray object > S
                path.move(to: CGPoint(x: scene.objectPos, y: scene.objectSize))
                path.addLine(to: CGPoint(x: scene.mirror.pos, y: 0))
                
                // center ray S > image
                path.move(to: CGPoint(x: scene.mirror.pos, y: 0))
                path.addLine(to: CGPoint(x: scene.imagePos, y: scene.imageSize))
                
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
                Slider(value: $lenseFocalLength, in: 0...1) {
                    Text("Lense focal length")
                }
                Picker("Lense type", selection: $lenseType) {
                    ForEach(LenseType.allCases) { type in
                        Text(type.label).tag(type)
                    }
                }
                Slider(value: $mirrorPosition, in: 0...1) {
                    Text("Mirror position")
                }
                Slider(value: $mirrorFocalLength, in: 0...1) {
                    Text("Mirror focal length")
                }
                Picker("Mirror type", selection: $mirrorType) {
                    ForEach(MirrorType.allCases) { type in
                        Text(type.label).tag(type)
                    }
                }
            }
            .pickerStyle(.segmented)
        }
        .padding([.horizontal])
        .frame(minWidth: 200, minHeight: 200)
        .padding()
    }
}


struct OpticsScene {
    
    let objectPos: CGFloat
    let objectSize: CGFloat
    
    let lense: Lense
    let mirror: SphericalMirror
    
    let imagePos: CGFloat
    let imageSize: CGFloat
    
    
    init(
        objectPos: CGFloat, objectSize: CGFloat,
        lense: Lense, mirror: SphericalMirror
    ) {
        
        self.objectPos = objectPos
        self.objectSize = objectSize
        self.lense = lense
        self.mirror = mirror
        
//        // compute image through lense
//        let f = lense.focalLength * (lense.type == .convergent ? +1 : -1)
//        let distO = lense.pos - objectPos
//        let gamma = f / (distO - f)
//        let distI = distO * gamma
//        self.imagePos = lense.pos + distI
//        self.imageSize = -objectSize * gamma

        // compute image through mirror
        let posf = mirror.pos + (mirror.type == .convex ? +1 : -1) * mirror.focalLength
        let fa = objectPos - posf
        
        let fa_im = mirror.focalLength*mirror.focalLength / fa
        // fa_im = imagePos - posf
        self.imagePos = fa_im + posf
        
        let sa = objectPos - mirror.pos
        let sa_im = self.imagePos - mirror.pos
        let gamma = sa_im / sa
        
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
    
    func draw(_ mirror: SphericalMirror, at position: CGFloat) {
        
        let x = position
        let h = size.height/2*0.8
        
        let f = mirror.focalLength
        let m: CGFloat = 5
        
        let a: CGFloat = 5
        
        var path = Path()
        
        // mirror body
        path.move(to: CGPoint(x: x, y: h))
        path.addLine(to: CGPoint(x: x, y: -h))
        
        if mirror.type == .concave {
            
            path.move(to: CGPoint(x: x-2*a, y: h+2*a))
            path.addLine(to: CGPoint(x: x, y: h))
            
            path.move(to: CGPoint(x: x, y: -h))
            path.addLine(to: CGPoint(x: x-2*a, y: -h-2*a))
            
        } else {
            
            path.move(to: CGPoint(x: x, y: h))
            path.addLine(to: CGPoint(x: x+2*a, y: h+2*a))
            
            path.move(to: CGPoint(x: x, y: -h))
            path.addLine(to: CGPoint(x: x+2*a, y: -h-2*a))
        }
        
        let n = 15
        for i in 0...n {
            
            let hi: CGFloat = -h + CGFloat(i)*2*h/CGFloat(n)
            
            path.move(to: CGPoint(x: x, y: hi))
            path.addLine(to: CGPoint(x: x+a, y: hi-a))
        }
        
        if mirror.type == .concave {
            
            // focal indicator
            path.move(to: CGPoint(x: x-f, y: -m))
            path.addLine(to: CGPoint(x: x-f, y: +m))
            
            // center indicator
            path.move(to: CGPoint(x: x-2*f, y: -m))
            path.addLine(to: CGPoint(x: x-2*f, y: +m))
            
        } else {
            
            // focal indicator
            path.move(to: CGPoint(x: x+f, y: -m))
            path.addLine(to: CGPoint(x: x+f, y: +m))
            
            // center indicator
            path.move(to: CGPoint(x: x+2*f, y: -m))
            path.addLine(to: CGPoint(x: x+2*f, y: +m))
        }
        
        context.stroke(path, with: .color(.red), lineWidth: 2)
    }
    
    func render(_ scene: OpticsScene) {
        
        drawAxis()
        drawObject(at: scene.objectPos, size: scene.objectSize)
//        draw(scene.lense, at: scene.lense.pos)
        draw(scene.mirror, at: scene.mirror.pos)
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
    
    let pos: CGFloat
    let type: LenseType
    let focalLength: CGFloat
}

enum MirrorType: CaseIterable, Identifiable {
    
    case convex, concave
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .convex: return "Convex"
        case .concave: return "Concave"
        }
    }
}

struct SphericalMirror {
    
    let pos: CGFloat
    let type: MirrorType
    let focalLength: CGFloat
}


#Preview {
    ContentView()
}
