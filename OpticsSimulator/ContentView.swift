import SwiftUI


struct ContentView: View {
    
    @State private var focalLength: CGFloat = 0.25
    @State private var objectPosition: CGFloat = 0.25
    @State private var lensePosition: CGFloat = 0.5
    @State private var lenseType: LenseType = .convergent

    var body: some View {
        
        VStack {
            
            Canvas { context, size in
                
                let engine = DrawEngine(context: context, size: size)
                
                engine.drawAxis()
                
                engine.drawObject(at: CGPoint(x: size.width*objectPosition, y: size.height/2))
                
                let lense1 = Lense(type: lenseType, focalLength: size.width*focalLength/2)
                
                engine.draw(_: lense1, at: CGPoint(x: size.width*lensePosition, y: size.height/2))
            }
            Form {
                Slider(value: $objectPosition, in: 0...1) {
                    Text("Object position")
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
    
    func drawObject(at position: CGPoint) {
        
        var path = Path()
        
        let x = position.x
        let y = position.y
        let h = size.height/2*0.9
        let a: CGFloat = 5
        
        //main body
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x, y: y-h))
        
        // top arrow
        path.move(to: CGPoint(x: x, y: y-h))
        path.addLine(to: CGPoint(x: x+a, y: y-h+a))
        path.move(to: CGPoint(x: x, y: y-h))
        path.addLine(to: CGPoint(x: x-a, y: y-h+a))
        
        context.stroke(path, with: .color(.blue), lineWidth: 2)
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
