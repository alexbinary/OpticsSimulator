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
                
                let engine = DrawEngine(context: context, size: size)
                
                let objectPos = CGPoint(x: size.width*objectPosition, y: size.height/2)
                let objectSize = size.height/2*0.9*objectSize
                
                let lensePos = CGPoint(x: size.width*lensePosition, y: size.height/2)
                let lenseF = size.width*focalLength/2
                
                let lense1 = Lense(type: lenseType, focalLength: lenseF)
                
                engine.drawAxis()
                engine.drawObject(at: objectPos, size: objectSize, color: .blue)
                engine.draw(lense1, at: lensePos)
                
                // compute image
                
                let distO = lensePos.x - objectPos.x
                let gamma = lenseF / (distO - lenseF)
                
                let distI = distO * gamma
                
                let imagePos = CGPoint(x: lensePos.x+distI, y: size.height/2)
                let imageSize = -objectSize * gamma
                
                // draw image
                
                engine.drawObject(at: imagePos, size: imageSize, color: .green)
                
                // simulated rays
                
                var path = Path()
                
                let parallelRayY = size.height/2-objectSize
                
                // parallel ray object > lense
                path.move(to: CGPoint(x: objectPos.x, y: parallelRayY))
                path.addLine(to: CGPoint(x: lensePos.x, y: parallelRayY))
                
                // parallel ray lense > F
                path.move(to: CGPoint(x: lensePos.x, y: parallelRayY))
                path.addLine(to: CGPoint(x: lensePos.x+lenseF, y: lensePos.y))
                
                // parallel ray F > image
                path.move(to: CGPoint(x: lensePos.x+lenseF, y: lensePos.y))
                path.addLine(to: CGPoint(x: imagePos.x, y: lensePos.y-imageSize))
                
                // center ray object > O
                path.move(to: CGPoint(x: objectPos.x, y: parallelRayY))
                path.addLine(to: CGPoint(x: lensePos.x, y: lensePos.y))
                
                // center ray O > image
                path.move(to: CGPoint(x: lensePos.x, y: lensePos.y))
                path.addLine(to: CGPoint(x: imagePos.x, y: lensePos.y-imageSize))
                
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


struct DrawEngine {
    
    let context: GraphicsContext
    let size: CGSize
    
    func drawAxis() {
        
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: size.height/2))
        path.addLine(to: CGPoint(x: size.width, y: size.height/2))
        
        context.stroke(path, with: .color(.gray), lineWidth: 1)
    }
    
    func drawObject(at position: CGPoint, size: CGFloat, color: Color) {
        
        var path = Path()
        
        let x = position.x
        let y = position.y
        let h = size
        let a: CGFloat = 5
        let d: CGFloat = size > 0 ? 1 : -1
        
        //main body
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x, y: y-h))
        
        // arrow
        path.move(to: CGPoint(x: x, y: y-h))
        path.addLine(to: CGPoint(x: x+a, y: y-h+d*a))
        path.move(to: CGPoint(x: x, y: y-h))
        path.addLine(to: CGPoint(x: x-a, y: y-h+d*a))
        
        context.stroke(path, with: .color(color), lineWidth: 2)
    }
    
    func draw(_ lense: Lense, at position: CGPoint) {
        
        let x = position.x
        let y = position.y
        let h = size.height/2*0.9
        
        let a: CGFloat = 5
        let d: CGFloat = lense.type == .convergent ? -1 : 1
        
        let f = lense.focalLength
        let m: CGFloat = 5
        
        var path = Path()
        
        // lense body
        path.move(to: CGPoint(x: x, y: y+h))
        path.addLine(to: CGPoint(x: x, y: y-h))
        
        // top arrow
        path.move(to: CGPoint(x: x, y: y+h))
        path.addLine(to: CGPoint(x: x+a, y: y+h+d*a))
        path.move(to: CGPoint(x: x, y: y+h))
        path.addLine(to: CGPoint(x: x-a, y: y+h+d*a))
        
        // bottom arrow
        path.move(to: CGPoint(x: x, y: y-h))
        path.addLine(to: CGPoint(x: x+a, y: y-h-d*a))
        path.move(to: CGPoint(x: x, y: y-h))
        path.addLine(to: CGPoint(x: x-a, y: y-h-d*a))
        
        // focal indicator before
        path.move(to: CGPoint(x: x-f, y: y-m))
        path.addLine(to: CGPoint(x: x-f, y: y+m))
        
        // focal indicator after
        path.move(to: CGPoint(x: x+f, y: y-m))
        path.addLine(to: CGPoint(x: x+f, y: y+m))
        
        context.stroke(path, with: .color(.red), lineWidth: 2)
    }
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
