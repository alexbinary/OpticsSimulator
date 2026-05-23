
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
}
