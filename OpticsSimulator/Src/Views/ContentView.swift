import SwiftUI


struct ContentView: View {
    
    @State private var scene = OpticsScene()
    @State private var activeScenePresetIndex: Int = 0
    
    @State private var mouse: CGPoint = .zero

    var body: some View {
        
        HStack(alignment: .top) {
            
            Canvas { context, size in
                
                // center at middle height, positive up
                
                context.translateBy(x: 0, y: size.height/2)
                context.scaleBy(x: 1, y: -1)
                
                // render
                
                let renderer = Renderer(context: context, renderSize: size)
                renderer.render(
                    scene,
                    showImages: scene.showImages,
                    showVirtualImages: scene.showVirtualImages,
                    showConstructionRays: scene.showConstructionRays,
                    mouse: mouse.applying(CGAffineTransform(
                        translationX: 0, y: -size.height/2
                    ))
                )
            }
            .background(
                MouseTrackingArea { point in
                    mouse = point
                }
            )
            
            Divider()
            
            VStack(alignment: .center) {
                
                HStack {
                    
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
                                    pos: 0.9, facesLeft: true
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
                                scene.add(Mirror(
                                    name: "Mirror \(scene.mirrors.count+1)",
                                    pos: 0.5, type: .concave, focalLength: 0.1,
                                    facesLeft: true
                                ))
                            } label: {
                                Text("Add mirror")
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        
                        VStack {
                            
                            Button {
                                scene.clear()
                            } label: {
                                Text("Clear scene")
                            }
                            
                            Toggle("Show images", isOn: $scene.showImages)
                            
                            Toggle("Show virtual images", isOn: $scene.showVirtualImages)
                                .disabled(!scene.showImages)
                            
                            Toggle("Show constructions rays", isOn: $scene.showConstructionRays)
                        }
                        
                    }.padding()
                    
                    Divider()
                    
                    VStack {
                                
                        HStack {
                            
                            Button {
                                activeScenePresetIndex -= 1
                                updateActivePresetIndex()
                                loadActivePreset()
                            } label: {
                                Text("<")
                            }
                            .disabled(activeScenePresetIndex == 0)
                            
                            Button {
                                activeScenePresetIndex += 1
                                updateActivePresetIndex()
                                loadActivePreset()
                            } label: {
                                Text(">")
                            }
                            .disabled(activeScenePresetIndex >= scene.presets.count-1)
                            
                            if activeScenePresetIndex >= 0, activeScenePresetIndex < scene.presets.count {
                                
                                Text(scene.presets[activeScenePresetIndex].name)
                                
                                Button {
                                    deleteActivePreset()
                                    activeScenePresetIndex = max(0, activeScenePresetIndex-1)
                                    updateActivePresetIndex()
                                    if scene.presets.count > 0 {
                                        loadActivePreset()
                                    }
                                } label: {
                                    Text("􀈑")
                                }
                            }
                        }
                        
                        HStack {
                            
                            Button {
                                scene.savePreset()
                                activeScenePresetIndex = scene.presets.count-1
                                updateActivePresetIndex()
                                loadActivePreset()
                            } label: {
                                Text("Save new")
                            }
                        }
                    }
                    .padding()
                }
                .fixedSize()
                
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
                                Toggle("Enabled", isOn: $object.enabled)
                                Toggle("Visible", isOn: $object.visible)
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
                                LabeledContent("Rays") {
                                    HStack {
                                        Toggle("Right", isOn: $object.generatesRight)
                                        Toggle("Left", isOn: $object.generatesLeft)
                                    }
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
                                Toggle("Enabled", isOn: $lense.enabled)
                                Toggle("Visible", isOn: $lense.visible)
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
                                Toggle("Enabled", isOn: $mirror.enabled)
                                Toggle("Visible", isOn: $mirror.visible)
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
                                Picker("Direction", selection: $mirror.facesLeft) {
                                    ForEach([true, false], id: \.self) { value in
                                        Text(value ? "Left" : "Right").tag(value)
                                    }
                                }
                                LabeledContent("Rays") {
                                    HStack {
                                        Toggle("Parallel", isOn: $mirror.generatesParallelRay)
                                        Toggle("Center", isOn: $mirror.generatesCenterRay)
                                        Toggle("Focal", isOn: $mirror.generatesFocalRay)
                                            .disabled(mirror.type != .concave)
                                        Toggle("Curve center", isOn: $mirror.generatesCurveCenterRay)
                                            .disabled(mirror.type != .concave)
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
                                Toggle("Visible", isOn: $screen.visible)
                            }
                            Form {
                                HStack {
                                    Slider(value: $screen.pos, in: 0...1) {
                                        Text("Position")
                                    }
                                    Text("\(screen.pos, specifier: "%.2f")")
                                }
                                Picker("Direction", selection: $screen.facesLeft) {
                                    ForEach([true, false], id: \.self) { value in
                                        Text(value ? "Left" : "Right").tag(value)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .pickerStyle(.segmented)
        }
        .padding([.horizontal])
        .frame(minWidth: 1600, minHeight: 800)
        .padding()
        .onAppear() {
            scene.loadPresetsFromFile()
            activeScenePresetIndex = scene.activePresetIndex ?? 0
            if scene.presets.count > 0 {
                loadActivePreset()
            }
        }
    }
    
    func loadActivePreset() {
        
        scene.loadPreset(scene.presets[activeScenePresetIndex])
    }
    
    func deleteActivePreset() {
        
        scene.deletePreset(scene.presets[activeScenePresetIndex])
    }
    
    func updateActivePresetIndex() {
        
        scene.setActivePreset(activeScenePresetIndex)
    }
}


#Preview {
    ContentView()
}
