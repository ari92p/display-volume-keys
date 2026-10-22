// Draws the app icon, a display with a speaker on its screen, and writes
// Resources/AppIcon.png and Resources/AppIcon.icns.
//
// Usage: swift scripts/make-app-icon.swift

import AppKit

let resources = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .appendingPathComponent("Resources")

func color(_ hex: UInt32) -> NSColor {
  NSColor(
    srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
    green: CGFloat((hex >> 8) & 0xFF) / 255,
    blue: CGFloat(hex & 0xFF) / 255,
    alpha: 1
  )
}

/// Draws the icon on a 1024 × 1024 canvas, following the macOS icon grid.
func drawIcon() {
  // Background tile with a soft shadow.
  let tile = NSBezierPath(
    roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
  NSGraphicsContext.saveGraphicsState()
  let shadow = NSShadow()
  shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
  shadow.shadowOffset = NSSize(width: 0, height: -10)
  shadow.shadowBlurRadius = 20
  shadow.set()
  color(0x1F2D6E).setFill()
  tile.fill()
  NSGraphicsContext.restoreGraphicsState()
  NSGradient(starting: color(0x2C3D86), ending: color(0x16225A))!.draw(in: tile, angle: -90)

  // Stand.
  color(0x18171B).setFill()
  let neck = NSBezierPath()
  neck.move(to: NSPoint(x: 462, y: 262))
  neck.line(to: NSPoint(x: 562, y: 262))
  neck.line(to: NSPoint(x: 548, y: 340))
  neck.line(to: NSPoint(x: 476, y: 340))
  neck.close()
  neck.fill()
  color(0x222225).setFill()
  NSBezierPath(
    roundedRect: NSRect(x: 372, y: 236, width: 280, height: 36), xRadius: 18, yRadius: 18
  ).fill()

  // Bezel and screen.
  let bezelRect = NSRect(x: 182, y: 330, width: 660, height: 440)
  color(0x1C1C1F).setFill()
  let bezel = NSBezierPath(roundedRect: bezelRect, xRadius: 36, yRadius: 36)
  bezel.fill()
  color(0x4F4F50).setStroke()
  bezel.lineWidth = 4
  bezel.stroke()
  let screenRect = bezelRect.insetBy(dx: 26, dy: 26)
  let screen = NSBezierPath(roundedRect: screenRect, xRadius: 14, yRadius: 14)
  NSGradient(starting: color(0x4DB9FC), ending: color(0x006EE1))!.draw(in: screen, angle: -40)

  // Speaker.
  let configuration = NSImage.SymbolConfiguration(pointSize: 210, weight: .semibold)
    .applying(.init(paletteColors: [.white]))
  let speaker = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: nil)!
    .withSymbolConfiguration(configuration)!
  let size = speaker.size
  speaker.draw(
    in: NSRect(
      x: screenRect.midX - size.width / 2, y: screenRect.midY - size.height / 2,
      width: size.width, height: size.height))
}

func png(pixels: Int) -> Data {
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
    bytesPerRow: 0, bitsPerPixel: 0)!
  rep.size = NSSize(width: 1024, height: 1024)
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  NSGraphicsContext.current?.imageInterpolation = .high
  drawIcon()
  NSGraphicsContext.restoreGraphicsState()
  return rep.representation(using: .png, properties: [:])!
}

let fileManager = FileManager.default
let iconset = fileManager.temporaryDirectory.appendingPathComponent("AppIcon.iconset")
try? fileManager.removeItem(at: iconset)
try fileManager.createDirectory(at: iconset, withIntermediateDirectories: true)
for points in [16, 32, 128, 256, 512] {
  try png(pixels: points).write(to: iconset.appendingPathComponent("icon_\(points)x\(points).png"))
  try png(pixels: points * 2).write(
    to: iconset.appendingPathComponent("icon_\(points)x\(points)@2x.png"))
}
try png(pixels: 1024).write(to: resources.appendingPathComponent("AppIcon.png"))

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = [
  "--convert", "icns", "--output", resources.appendingPathComponent("AppIcon.icns").path,
  iconset.path,
]
try iconutil.run()
iconutil.waitUntilExit()
try? fileManager.removeItem(at: iconset)
guard iconutil.terminationStatus == 0 else { exit(1) }
print("Wrote Resources/AppIcon.png and Resources/AppIcon.icns")
