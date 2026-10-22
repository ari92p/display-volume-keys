import AppKit

/// Menu bar icon: a display with a speaker on its screen. It is a template
/// image, so macOS tints it for the menu bar and dims it when disabled.
enum StatusIcon {
  static func make(accessibilityDescription: String) -> NSImage {
    let image = NSImage(size: NSSize(width: 20, height: 16), flipped: false) { _ in
      NSColor.black.set()

      let screen = NSBezierPath(
        roundedRect: NSRect(x: 1.75, y: 4.75, width: 16.5, height: 10.5),
        xRadius: 2,
        yRadius: 2
      )
      screen.lineWidth = 1.5
      screen.stroke()
      NSRect(x: 9.25, y: 2, width: 1.5, height: 3).fill()
      NSBezierPath(
        roundedRect: NSRect(x: 6, y: 1, width: 8, height: 1.5),
        xRadius: 0.75,
        yRadius: 0.75
      ).fill()

      if let speaker = NSImage(
        systemSymbolName: "speaker.wave.2.fill",
        accessibilityDescription: nil
      )?.withSymbolConfiguration(.init(pointSize: 6.5, weight: .semibold)) {
        let size = speaker.size
        speaker.draw(
          in: NSRect(
            x: 10 - size.width / 2,
            y: 10 - size.height / 2,
            width: size.width,
            height: size.height
          )
        )
      }
      return true
    }
    image.isTemplate = true
    image.accessibilityDescription = accessibilityDescription
    return image
  }
}
