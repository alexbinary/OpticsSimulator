import SwiftUI


struct ContentView: View {
    
    @State private var scene = {
        let s = OpticsScene()
        s.add(Object(
            name: "Object 1",
            pos: 0.01, size: 0.3
        ))
        s.add(Lense(
            name: "Lense 1",
            pos: 0.12, type: .convergent, focalLength: 0.05
        ))
        s.add(Lense(
            name: "Lense 2",
            pos: 0.32, type: .convergent, focalLength: 0.06
        ))
        let l3 = Lense(
            name: "Lense 3",
            pos: 0.55, type: .convergent, focalLength: 0.05
        )
        l3.generatesParallelRay = true
        l3.retroPropagatesRays = true
        s.add(l3)
//        s.add(SphericalMirror(
//            name: "Mirror 1",
//            pos: 0.8, type: .convex, focalLength: 0.1
//        ))
        s.add(Screen(
            name: "Screen 1",
            pos: 0.95
        ))
        return s
    }()
    
    @State var userActiveDevice: OpticsDevice? = nil

    var body: some View {
        
        HStack(alignment: .top) {
            
            Canvas { context, size in
                
                // center at middle height, positive up
                
                context.translateBy(x: 0, y: size.height/2)
                context.scaleBy(x: 1, y: -1)
                
                // render
                
                let renderer = Renderer(context: context, renderSize: size)
                renderer.render(scene, userActiveDevice: userActiveDevice)
            }
            
            Divider()
            
            VStack(alignment: .center) {
                    
                Grid {
                    
                    GridRow {
                        
                        Button {
                            scene.add(Object(
                                name: "Object \(scene.objects.count+1)",
                                pos: 0.1, size: 1
                            ))
                        } label: {
                            Text("Add object")
                        }
                        
                        Button {
                            scene.add(Screen(
                                name: "Screen \(scene.screens.count+1)",
                                pos: 0.9
                            ))
                        } label: {
                            Text("Add screen")
                        }
                    }
                    
                    GridRow {
                        
                        Button {
                            scene.add(Lense(
                                name: "Lense \(scene.lenses.count+1)",
                                pos: 0.5, type: .convergent, focalLength: 0.1
                            ))
                        } label: {
                            Text("Add lense")
                        }
                        
                        Button {
                            scene.add(SphericalMirror(
                                name: "Mirror \(scene.mirrors.count+1)",
                                pos: 0.5, type: .concave, focalLength: 0.1
                            ))
                        } label: {
                            Text("Add mirror")
                        }
                    }
                }
                .padding()
                
                Divider()
                
                List {
                    
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
                                HStack {
                                    Slider(value: $object.pos, in: 0...1) {
                                        Text("Position")
                                    }
                                    Text("\(object.pos, specifier: "%.2f")")
                                }
                                HStack {
                                    Slider(value: $object.size, in: 0...1) {
                                        Text("Size")
                                    }
                                    Text("\(object.size, specifier: "%.2f")")
                                }
                            }
                        }
                        .padding(.vertical)
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
                                Button {
                                    if self.userActiveDevice?.id == lense.id {
                                        self.userActiveDevice = nil
                                    } else {
                                        self.userActiveDevice = lense
                                    }
                                } label: {
                                    Text(self.userActiveDevice?.id == lense.id ? "􀋮" : "􀋭")
                                }
                                Toggle("Enabled", isOn: $lense.enabled)
                            }
                            Form {
                                HStack {
                                    Slider(value: $lense.pos, in: 0...1) {
                                        Text("Position")
                                    }
                                    Text("\(lense.pos, specifier: "%.2f")")
                                }
                                HStack {
                                    Slider(value: $lense.focalLength, in: 0...1) {
                                        Text("Focal length")
                                    }
                                    Text("\(lense.focalLength, specifier: "%.2f")")
                                }
                                Picker("Type", selection: $lense.type) {
                                    ForEach(LenseType.allCases) { type in
                                        Text(type.label).tag(type)
                                    }
                                }
                                LabeledContent("Rays") {
                                    HStack {
                                        Toggle("Parallel", isOn: $lense.generatesParallelRay)
                                        Toggle("Center", isOn: $lense.generatesCenterRay)
                                        Toggle("Focal", isOn: $lense.generatesFocalRay)
                                        Toggle("Retropropagate", isOn: $lense.retroPropagatesRays)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
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
                                Button {
                                    if self.userActiveDevice?.id == mirror.id {
                                        self.userActiveDevice = nil
                                    } else {
                                        self.userActiveDevice = mirror
                                    }
                                } label: {
                                    Text(self.userActiveDevice?.id == mirror.id ? "􀋮" : "􀋭")
                                }
                                Toggle("Enabled", isOn: $mirror.enabled)
                            }
                            Form {
                                HStack {
                                    Slider(value: $mirror.pos, in: 0...1) {
                                        Text("Position")
                                    }
                                    Text("\(mirror.pos, specifier: "%.2f")")
                                }
                                HStack {
                                    Slider(value: $mirror.focalLength, in: 0...1) {
                                        Text("Focal length")
                                    }
                                    Text("\(mirror.focalLength, specifier: "%.2f")")
                                }
                                Picker("Type", selection: $mirror.type) {
                                    ForEach(MirrorType.allCases) { type in
                                        Text(type.label).tag(type)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    ForEach(scene.screens) { screen in
                        
                        @Bindable var screen = screen
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(screen.name).font(.title2)
                                Button {
                                    scene.delete(screen)
                                } label: {
                                    Text("􀈑")
                                }
                                Toggle("Enabled", isOn: $screen.enabled)
                            }
                            Form {
                                HStack {
                                    Slider(value: $screen.pos, in: 0...1) {
                                        Text("Position")
                                    }
                                    Text("\(screen.pos, specifier: "%.2f")")
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .pickerStyle(.segmented)
//            .fixedSize(horizontal: true, vertical: false)
        }
        .padding([.horizontal])
        .frame(minWidth: 1600, minHeight: 800)
        .padding()
    }
}


#Preview {
    ContentView()
}
