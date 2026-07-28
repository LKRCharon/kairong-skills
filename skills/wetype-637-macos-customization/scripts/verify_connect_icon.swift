import CoreGraphics
import Foundation
import ImageIO

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    fputs("usage: verify_connect_icon.swift ICON_PNG\n", stderr)
    exit(2)
}

let path = arguments[1]
let url = URL(fileURLWithPath: path)
guard url.lastPathComponent == "icon_button_connect.png",
      let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
      image.width == 60,
      image.height == 60 else {
    fputs("invalid 637 connect icon: \(path)\n", stderr)
    exit(1)
}

let width = image.width
let height = image.height
let bytesPerRow = width * 4
var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
var nonTransparent = 0
var opaqueTarget = 0
var opaqueOther = 0
let pixelCount = pixels.count

pixels.withUnsafeMutableBytes { buffer in
    let info = CGImageAlphaInfo.premultipliedLast.rawValue
        | CGBitmapInfo.byteOrder32Big.rawValue
    guard let context = CGContext(
        data: buffer.baseAddress,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: info
    ) else {
        return
    }
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    for index in stride(from: 0, to: pixelCount, by: 4) {
        let alpha = buffer[index + 3]
        guard alpha > 0 else { continue }
        nonTransparent += 1
        guard alpha == 255 else { continue }
        if buffer[index] == 0 && buffer[index + 1] == 122 && buffer[index + 2] == 255 {
            opaqueTarget += 1
        } else {
            opaqueOther += 1
        }
    }
}

guard nonTransparent > 0, opaqueTarget > 0, opaqueOther == 0 else {
    fputs("connect icon is not solid #007AFF: opaqueOther=\(opaqueOther)\n", stderr)
    exit(1)
}

print("connect icon verified: 60x60 RGBA, opaque #007AFF pixels=\(opaqueTarget)")
