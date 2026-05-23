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
                
                let object = Object(
                    pos: objectPos, size: objectSize
                )
                let lense = Lense(
                    pos: lensePos, type: lenseType, focalLength: lenseF
                )
                let mirror = SphericalMirror(
                    pos: mirrorPos, type: mirrorType, focalLength: mirrorF
                )
                
                var scene = OpticsScene()
                scene.add(object)
                scene.add(lense)
                scene.add(mirror)
                scene.computeImage()
                
                // render
                
                let engine = DrawEngine(context: context, size: size)
                engine.render(scene)
            }
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Object").font(.title2)
                    Form {
                        Slider(value: $objectPosition, in: 0...1) {
                            Text("Position")
                        }
                        Slider(value: $objectSize, in: 0...1) {
                            Text("Size")
                        }
                    }
                }
                .padding()
                Divider()
                VStack(alignment: .leading) {
                    Text("Lense").font(.title2)
                    Form {
                        Slider(value: $lensePosition, in: 0...1) {
                            Text("Position")
                        }
                        Slider(value: $lenseFocalLength, in: 0...1) {
                            Text("Focal length")
                        }
                        Picker("Type", selection: $lenseType) {
                            ForEach(LenseType.allCases) { type in
                                Text(type.label).tag(type)
                            }
                        }
                    }
                }
                .padding()
                Divider()
                VStack(alignment: .leading) {
                    Text("Mirror").font(.title2)
                    Form {
                        Slider(value: $mirrorPosition, in: 0...1) {
                            Text("Position")
                        }
                        Slider(value: $mirrorFocalLength, in: 0...1) {
                            Text("Focal length")
                        }
                        Picker("Type", selection: $mirrorType) {
                            ForEach(MirrorType.allCases) { type in
                                Text(type.label).tag(type)
                            }
                        }
                    }
                }
                .padding()
            }
            .pickerStyle(.segmented)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding([.horizontal])
        .frame(minWidth: 1200, minHeight: 600)
        .padding()
    }
}


struct OpticsScene {
    
    var objects: [Object] = []
    
    var lenses: [Lense] = []
    var mirrors: [SphericalMirror] = []
    
    var image: Image = Image(pos: 0, size: 0)
    
    
    mutating func add(_ object: Object) {
        self.objects.append(object)
    }
    
    mutating func add(_ lense: Lense) {
        self.lenses.append(lense)
    }
    
    mutating func add(_ mirror: SphericalMirror) {
        self.mirrors.append(mirror)
    }
    
    
    mutating func computeImage() {
        
        let object = self.objects.first!
        let lense = self.lenses.first!
        let mirror = self.mirrors.first!
        
        var imagePos: CGFloat
        var imageSize: CGFloat
        var gamma: CGFloat
        
        // compute image through lense
        let f = lense.focalLength * (lense.type == .convergent ? +1 : -1)
        let distO = lense.pos - object.pos
        gamma = f / (distO - f)
        let distI = distO * gamma
        imagePos = lense.pos + distI
        imageSize = -object.size * gamma

        // compute image through mirror
        let posf = mirror.pos + (mirror.type == .convex ? +1 : -1) * mirror.focalLength
        let fa = object.pos - posf
        let fa_im = mirror.focalLength*mirror.focalLength / fa
        imagePos = fa_im + posf
        let sa = object.pos - mirror.pos
        let sa_im = imagePos - mirror.pos
        gamma = sa_im / sa
        imageSize = -object.size * gamma
        
        self.image = Image(pos: imagePos, size: imageSize)
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
    
    func draw(_ object: Object) {
        
        drawObjectOrImage(at: object.pos, size: object.size, color: .blue)
    }
    
    func draw(_ image: Image) {
        
        drawObjectOrImage(at: image.pos, size: image.size, color: .green)
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
    
    func draw(_ lense: Lense) {
        
        let x = lense.pos
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
    
    func draw(_ mirror: SphericalMirror) {
        
        let x = mirror.pos
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
    
    func drawRays(for object: Object, _ lense: Lense, _ image: Image) {
        
        var path = Path()
        
        // parallel ray object > lense
        path.move(to: CGPoint(x: object.pos, y: object.size))
        path.addLine(to: CGPoint(x: lense.pos, y: object.size))
        
        // parallel ray lense > F
        if lense.type == .convergent {
            path.move(to: CGPoint(x: lense.pos, y: object.size))
            path.addLine(to: CGPoint(x: lense.pos+lense.focalLength, y: 0))
        } else {
            path.move(to: CGPoint(x: lense.pos, y: object.size))
            path.addLine(to: CGPoint(x: lense.pos-lense.focalLength, y: 0))
        }
        
        // parallel ray F > image
        if lense.type == .convergent {
            path.move(to: CGPoint(x: lense.pos+lense.focalLength, y: 0))
            path.addLine(to: CGPoint(x: image.pos, y: image.size))
        }
        
        // center ray object > O
        path.move(to: CGPoint(x: object.pos, y: object.size))
        path.addLine(to: CGPoint(x: lense.pos, y: 0))
        
        // center ray O > image
        if lense.type == .convergent {
            path.move(to: CGPoint(x: lense.pos, y: 0))
            path.addLine(to: CGPoint(x: image.pos, y: image.size))
        }
        
        context.stroke(path, with: .color(.yellow), lineWidth: 1)
    }
    
    func drawRays(for object: Object, _ mirror: SphericalMirror, _ image: Image) {
        
        var path = Path()
        
        // parallel ray object > mirror
        path.move(to: CGPoint(x: object.pos, y: object.size))
        path.addLine(to: CGPoint(x: mirror.pos, y: object.size))
        
        // parallel ray mirror > F
        if mirror.type == .concave {
            path.move(to: CGPoint(x: mirror.pos, y: object.size))
            path.addLine(to: CGPoint(x: mirror.pos-mirror.focalLength, y: 0))
        } else {
            path.move(to: CGPoint(x: mirror.pos, y: object.size))
            path.addLine(to: CGPoint(x: mirror.pos+mirror.focalLength, y: 0))
        }
        
        // parallel ray F > image
        if mirror.type == .concave {
            path.move(to: CGPoint(x: mirror.pos-mirror.focalLength, y: 0))
            path.addLine(to: CGPoint(x: image.pos, y: image.size))
        }
        
        // center ray object > S
        path.move(to: CGPoint(x: object.pos, y: object.size))
        path.addLine(to: CGPoint(x: mirror.pos, y: 0))
        
        // center ray S > image
        path.move(to: CGPoint(x: mirror.pos, y: 0))
        path.addLine(to: CGPoint(x: image.pos, y: image.size))
        
        context.stroke(path, with: .color(.yellow), lineWidth: 1)
    }
    
    func render(_ scene: OpticsScene) {
        
        let object = scene.objects.first!
        let lense = scene.lenses.first!
        let mirror = scene.mirrors.first!
        let image = scene.image
        
        drawAxis()
        draw(object)
        draw(lense)
        draw(mirror)
        draw(image)
        
        drawRays(for: object, lense, image)
        drawRays(for: object, mirror, image)
    }
}


enum ArrowDirection {
    
    case towardAxis, awayFromAxis
}


struct Object {
    
    let pos: CGFloat
    let size: CGFloat
}

struct Image {
    
    let pos: CGFloat
    let size: CGFloat
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
        .frame(width: 1200, height: 800)
}
