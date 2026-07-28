import CoreGraphics
import Foundation
import ImageIO

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    fputs("usage: patch_wetype_637_connect_icon.swift ICON_PNG\n", stderr)
    exit(2)
}

let path = arguments[1]
let url = URL(fileURLWithPath: path)
guard url.lastPathComponent == "icon_button_connect.png" else {
    fputs("refusing unexpected icon path: \(path)\n", stderr)
    exit(2)
}

guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
      image.width == 60,
      image.height == 60 else {
    fputs("refusing non-637 connect icon: expected 60x60 PNG at \(path)\n", stderr)
    exit(2)
}

let width = image.width
let height = image.height
let bytesPerRow = width * 4
var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    | CGBitmapInfo.byteOrder32Big.rawValue

let targetColor = (r: 0, g: 122, b: 255)
var nonTransparentPixels = 0
var opaquePixels = 0
var unexpectedOpaquePixels = 0
var firstOpaqueColor: (r: Int, g: Int, b: Int)?
var outputImage: CGImage?

pixels.withUnsafeMutableBytes { buffer in
    guard let baseAddress = buffer.baseAddress else {
        return
    }
    guard let context = CGContext(
        data: baseAddress,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: bitmapInfo
    ) else {
        return
    }

    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    for y in 0..<height {
        for x in 0..<width {
            let index = y * bytesPerRow + x * 4
            let alpha = buffer[index + 3]
            guard alpha > 0 else { continue }

            nonTransparentPixels += 1
            if alpha == 255 {
                opaquePixels += 1
                let color = (
                    r: Int(buffer[index]),
                    g: Int(buffer[index + 1]),
                    b: Int(buffer[index + 2])
                )
                if let firstOpaqueColor {
                    if abs(color.r - firstOpaqueColor.r) > 3
                        || abs(color.g - firstOpaqueColor.g) > 3
                        || abs(color.b - firstOpaqueColor.b) > 3 {
                        unexpectedOpaquePixels += 1
                    }
                } else {
                    firstOpaqueColor = color
                }
            }

            // The bitmap is premultiplied RGBA; keep alpha and edge antialiasing.
            buffer[index] = UInt8((targetColor.r * Int(alpha) + 127) / 255)
            buffer[index + 1] = UInt8((targetColor.g * Int(alpha) + 127) / 255)
            buffer[index + 2] = UInt8((targetColor.b * Int(alpha) + 127) / 255)
        }
    }

    outputImage = context.makeImage()
}

guard nonTransparentPixels > 0 else {
    fputs("refusing empty connect icon\n", stderr)
    exit(2)
}
guard opaquePixels > 0, let sourceColor = firstOpaqueColor,
      sourceColor.r <= 80,
      sourceColor.g >= 150,
      sourceColor.b >= 80,
      sourceColor.g > sourceColor.b + 20,
      unexpectedOpaquePixels == 0 else {
    fputs("refusing unexpected source palette in connect icon\n", stderr)
    exit(2)
}

guard let outputImage else {
    fputs("could not create patched connect icon image\n", stderr)
    exit(1)
}

let temporaryURL = URL(fileURLWithPath: path + ".tmp")
let fileManager = FileManager.default
try? fileManager.removeItem(at: temporaryURL)
guard let destination = CGImageDestinationCreateWithURL(
    temporaryURL as CFURL,
    "public.png" as CFString,
    1,
    nil
) else {
    fputs("could not create temporary PNG destination\n", stderr)
    exit(1)
}
CGImageDestinationAddImage(destination, outputImage, nil)
guard CGImageDestinationFinalize(destination) else {
    fputs("could not write patched connect icon\n", stderr)
    exit(1)
}

do {
    try fileManager.removeItem(at: url)
    try fileManager.moveItem(at: temporaryURL, to: url)
} catch {
    fputs("could not replace connect icon: \(error)\n", stderr)
    try? fileManager.removeItem(at: temporaryURL)
    exit(1)
}

print("patched connect icon: green -> #007AFF; preserved alpha samples")
