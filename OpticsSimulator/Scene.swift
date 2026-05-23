
import SwiftUI


@Observable
class OpticsScene {
    
    var objects: [Object] = []
    
    var lenses: [Lense] = []
    var mirrors: [SphericalMirror] = []
    
    var images: [Image] = []
    
    var screens: [Screen] = []
    
    
    func add(_ object: Object) {
        self.objects.append(object)
    }
    
    func add(_ lense: Lense) {
        self.lenses.append(lense)
    }
    
    func add(_ mirror: SphericalMirror) {
        self.mirrors.append(mirror)
    }
    
    func add(_ screen: Screen) {
        self.screens.append(screen)
    }
    
    
    func delete(_ object: Object) {
        self.objects.removeAll(where: { $0.id == object.id })
    }
    
    func delete(_ lense: Lense) {
        self.lenses.removeAll(where: { $0.id == lense.id })
    }
    
    func delete(_ mirror: SphericalMirror) {
        self.mirrors.removeAll(where: { $0.id == mirror.id })
    }
    
    func delete(_ screen: Screen) {
        self.screens.removeAll(where: { $0.id == screen.id })
    }
    
    
    func computeImages() {
        
        self.images = []
        
        if let object = self.objects.first,
           let lense = self.lenses.first {
            
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
            
            self.images.append(Image(pos: imagePos, size: imageSize))
        }
        
        if let object = self.objects.first,
           let mirror = self.mirrors.first {
            
            var imagePos: CGFloat
            var imageSize: CGFloat
            var gamma: CGFloat
            
            // compute image through mirror
            let posf = mirror.pos + (mirror.type == .convex ? +1 : -1) * mirror.focalLength
            let fa = object.pos - posf
            let fa_im = mirror.focalLength*mirror.focalLength / fa
            imagePos = fa_im + posf
            let sa = object.pos - mirror.pos
            let sa_im = imagePos - mirror.pos
            gamma = sa_im / sa
            imageSize = -object.size * gamma
            
            self.images.append(Image(pos: imagePos, size: imageSize))
        }
    }
}
