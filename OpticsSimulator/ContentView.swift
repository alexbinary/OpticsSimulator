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
    
    @State private var scene = {
        let s = OpticsScene()
        s.add(Object(name: "Object 1", pos: 0.1, size: 1))
        s.add(Lense(name: "Lense 1", pos: 0.5, type: .convergent, focalLength: 0.5))
        return s
    }()

    var body: some View {
        
        VStack {
            
            Canvas { context, size in
                
                // center at middle height, positive up
                
                context.translateBy(x: 0, y: size.height/2)
                context.scaleBy(x: 1, y: -1)
                
                // setup scene
                
                scene.computeImages()
                
                // render
                
                let renderer = Renderer(context: context, size: size)
                renderer.render(scene)
            }
            HStack(alignment: .top) {
                
                ForEach(scene.objects) { object in
                    
                    @Bindable var object = object
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(object.name).font(.title2)
                            Button {
                                scene.delete(object)
                            } label: {
                                Text("􀈑")
                            }
                        }
                        Form {
                            Slider(value: $object.pos, in: 0...1) {
                                Text("Position")
                            }
                            Slider(value: $object.size, in: 0...1) {
                                Text("Size")
                            }
                        }
                    }
                    .padding()
                    Divider()
                }
                
                ForEach(scene.lenses) { lense in
                    
                    @Bindable var lense = lense
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(lense.name).font(.title2)
                            Button {
                                scene.delete(lense)
                            } label: {
                                Text("􀈑")
                            }
                        }
                        Form {
                            Slider(value: $lense.pos, in: 0...1) {
                                Text("Position")
                            }
                            Slider(value: $lense.focalLength, in: 0...1) {
                                Text("Focal length")
                            }
                            Picker("Type", selection: $lense.type) {
                                ForEach(LenseType.allCases) { type in
                                    Text(type.label).tag(type)
                                }
                            }
                        }
                    }
                    .padding()
                    Divider()
                }
                
                ForEach(scene.mirrors) { mirror in
                    
                    @Bindable var mirror = mirror
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(mirror.name).font(.title2)
                            Button {
                                scene.delete(mirror)
                            } label: {
                                Text("􀈑")
                            }
                        }
                        Form {
                            Slider(value: $mirror.pos, in: 0...1) {
                                Text("Position")
                            }
                            Slider(value: $mirror.focalLength, in: 0...1) {
                                Text("Focal length")
                            }
                            Picker("Type", selection: $mirror.type) {
                                ForEach(MirrorType.allCases) { type in
                                    Text(type.label).tag(type)
                                }
                            }
                        }
                    }
                    .padding()
                    Divider()
                }
                
                Spacer()
                
                Divider()
                
                VStack {
                    Button {
                        scene.add(Object(
                            name: "Object \(scene.objects.count+1)",
                            pos: 0.1, size: 1
                        ))
                    } label: {
                        Text("Add object")
                    }
                    Button {
                        scene.add(Lense(
                            name: "Lense \(scene.lenses.count+1)",
                            pos: 0.9, type: .convergent, focalLength: 0.5
                        ))
                    } label: {
                        Text("Add lense")
                    }
                    Button {
                        scene.add(SphericalMirror(
                            name: "Mirror \(scene.mirrors.count+1)",
                            pos: 0.9, type: .convex, focalLength: 0.5
                        ))
                    } label: {
                        Text("Add mirror")
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
