
import SwiftUI



struct MouseEventsArea: NSViewRepresentable {

    var onMove: (CGPoint) -> Void
    var onScroll: (CGFloat, CGFloat, NSEvent.ModifierFlags, NSEvent.Phase, NSEvent.Phase) -> Void
    var onRotate: (Angle, CGPoint) -> Void
    var onPinch: (CGFloat, CGPoint) -> Void

    func makeNSView(context: Context) -> NSView {

        let view = MouseEventView()
        view.onMove = onMove
        view.onScroll = onScroll
        view.onRotate = onRotate
        view.onPinch = onPinch
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}


final class MouseEventView: NSView {

    var trackingArea: NSTrackingArea?
    var onMove: ((CGPoint) -> Void)?
    var onScroll: ((CGFloat, CGFloat, NSEvent.ModifierFlags, NSEvent.Phase, NSEvent.Phase) -> Void)?
    var onRotate: ((Angle, CGPoint) -> Void)?
    var onPinch: ((CGFloat, CGPoint) -> Void)?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [
            .mouseMoved,
            .activeInKeyWindow,
            .inVisibleRect
        ]

        trackingArea = NSTrackingArea(
            rect: .zero,
            options: options,
            owner: self,
            userInfo: nil
        )

        addTrackingArea(trackingArea!)
    }

    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        onMove?(point)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let dx = event.scrollingDeltaX
        let dy = event.scrollingDeltaY
        onScroll?(
            dx, dy, event.modifierFlags,
            event.phase, event.momentumPhase
        )
    }
    
    override func rotate(with event: NSEvent) {
        let delta = Angle.degrees(Double(event.rotation))
        let point = convert(event.locationInWindow, from: nil)
        onRotate?(delta, point)
    }
    
    override func magnify(with event: NSEvent) {
        let delta = event.magnification
        let point = convert(event.locationInWindow, from: nil)
        onPinch?(delta, point)
    }
}
