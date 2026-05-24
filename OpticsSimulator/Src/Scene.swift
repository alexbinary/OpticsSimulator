
import SwiftUI


@Observable
class OpticsScene {
    
    var objects: [Object] = []
    var devices: [OpticsDevice] = []
    
    var lenses: [Lense] { devices.compactMap { $0 as? Lense }}
    var mirrors: [SphericalMirror] { devices.compactMap { $0 as? SphericalMirror }}
    var screens: [Screen] { devices.compactMap { $0 as? Screen }}
    
    
    func add(_ object: Object) {
        self.objects.append(object)
    }
    
    func add(_ device: OpticsDevice) {
        self.devices.append(device)
    }
    
    
    func delete(_ object: Object) {
        self.objects.removeAll(where: { $0.id == object.id })
    }
    
    func delete(_ device: OpticsDevice) {
        self.devices.removeAll(where: { $0.id == device.id })
    }
    
    
    var presets: [ScenePresetDescriptor] = []
    
    func savePreset() {
        
        let preset = ScenePresetDescriptor(
            id: UUID(),
            name: "Preset \(presets.count+1)",
            objects: objects.map { object in
                ObjectDescriptor(
                    enabled: object.enabled,
                    pos: object.pos,
                    size: object.size,
                    name: object.name
                )
            },
            lenses: lenses.map { lense in
                LenseDescriptor(
                    enabled: lense.enabled,
                    pos: lense.pos,
                    focalLength: lense.focalLength,
                    type: lense.type,
                    name: lense.name,
                    generatesParallelRay: lense.generatesParallelRay,
                    generatesCenterRay: lense.generatesCenterRay,
                    generatesFocalRay: lense.generatesFocalRay,
                    retroPropagatesRays: lense.retroPropagatesRays
                )
            },
            mirrors: mirrors.map { mirror in
                MirrorDescriptor(
                    enabled: mirror.enabled,
                    pos: mirror.pos,
                    focalLength: mirror.focalLength,
                    type: mirror.type,
                    name: mirror.name
                )
            },
            screens: screens.map { screen in
                ScreenDescriptor(
                    enabled: screen.enabled,
                    pos: screen.pos,
                    name: screen.name
                )
            }
        )
        
        presets.append(preset)
        writePresetsToFile()
    }
    
    func loadPreset(_ preset: ScenePresetDescriptor) {

        for object in objects {
            delete(object)
        }
        for device in devices {
            delete(device)
        }
        
        preset.objects.map { descriptor in
            Object(
                name: descriptor.name,
                pos: descriptor.pos,
                size: descriptor.size,
                enabled: descriptor.enabled
            )
        }.forEach { object in
            add(object)
        }
        
        preset.lenses.map { descriptor in
            Lense(
                name: descriptor.name,
                pos: descriptor.pos,
                type: descriptor.type,
                focalLength: descriptor.focalLength,
                generatesParallelRay: descriptor.generatesParallelRay,
                generatesCenterRay: descriptor.generatesCenterRay,
                generatesFocalRay: descriptor.generatesFocalRay,
                retroPropagatesRays: descriptor.retroPropagatesRays,
                enabled: descriptor.enabled
            )
        }.forEach { lense in
            add(lense)
        }
        
        preset.mirrors.map { descriptor in
            SphericalMirror(
                name: descriptor.name,
                pos: descriptor.pos,
                type: descriptor.type,
                focalLength: descriptor.focalLength,
                enabled: descriptor.enabled
            )
        }.forEach { mirror in
            add(mirror)
        }
        
        preset.screens.map { descriptor in
            Screen(
                name: descriptor.name,
                pos: descriptor.pos,
                enabled: descriptor.enabled
            )
        }.forEach { screen in
            add(screen)
        }
    }
    
    func deletePreset(_ preset: ScenePresetDescriptor) {
        
        presets.removeAll { $0.id == preset.id }
        writePresetsToFile()
    }
    
    let presetsFileUrl: URL = {
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return URL(fileURLWithPath: path)
    }()
    
    func loadPresetsFromFile() {
        
        let decoder = JSONDecoder()
        
        if let rawData = try? Data(contentsOf: presetsFileUrl),
           let decodedData = try? decoder.decode(FileRoot.self, from: rawData) {
            
            self.presets = decodedData.presets
            
        } else {
            
            self.presets = []
        }
    }
    
    func writePresetsToFile() {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let rawData = try! encoder.encode(FileRoot(presets: presets))
        try! rawData.write(to: self.presetsFileUrl)
    }
}


struct ObjectDescriptor: Codable {
    
    let enabled: Bool
    
    let pos: CGFloat
    let size: CGFloat
    let name: String
}

struct LenseDescriptor: Codable {
    
    let enabled: Bool
    
    let pos: CGFloat
    let focalLength: CGFloat
    let type: LenseType
    let name: String
    
    var generatesParallelRay: Bool
    var generatesCenterRay: Bool
    var generatesFocalRay: Bool
    
    var retroPropagatesRays: Bool
}

struct MirrorDescriptor: Codable {
    
    let enabled: Bool
    
    let pos: CGFloat
    let focalLength: CGFloat
    let type: MirrorType
    let name: String
}

struct ScreenDescriptor: Codable {
    
    let enabled: Bool
    
    let pos: CGFloat
    let name: String
}

struct ScenePresetDescriptor: Codable {
    
    let id: UUID
    let name: String
    let objects: [ObjectDescriptor]
    let lenses: [LenseDescriptor]
    let mirrors: [MirrorDescriptor]
    let screens: [ScreenDescriptor]
}


struct FileRoot: Codable {
    
    let presets: [ScenePresetDescriptor]
}
