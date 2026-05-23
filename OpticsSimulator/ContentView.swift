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
                
                let renderer = Renderer(context: context, size: size)
                renderer.render(scene)
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


#Preview {
    ContentView()
        .frame(width: 1200, height: 800)
}
