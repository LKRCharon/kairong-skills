#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 2) {
            fprintf(stderr, "usage: verify_connect_icon ICON_PNG\n");
            return 2;
        }

        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]];
        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        CGImageRef image = source ? CGImageSourceCreateImageAtIndex(source, 0, NULL) : NULL;
        if (![url.lastPathComponent isEqualToString:@"icon_button_connect.png"]
            || !image || CGImageGetWidth(image) != 60 || CGImageGetHeight(image) != 60) {
            fprintf(stderr, "invalid 657 connect icon: %s\n", argv[1]);
            if (image) CGImageRelease(image);
            if (source) CFRelease(source);
            return 1;
        }

        const size_t width = CGImageGetWidth(image);
        const size_t height = CGImageGetHeight(image);
        const size_t bytesPerRow = width * 4;
        uint8_t *pixels = calloc(height, bytesPerRow);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(
            pixels,
            width,
            height,
            8,
            bytesPerRow,
            colorSpace,
            kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big
        );
        if (!pixels || !colorSpace || !context) {
            fprintf(stderr, "could not create RGBA bitmap context\n");
            return 1;
        }

        CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
        int nonTransparent = 0;
        int opaqueTarget = 0;
        int opaqueOther = 0;

        for (size_t index = 0; index < height * bytesPerRow; index += 4) {
            const int alpha = pixels[index + 3];
            if (alpha == 0) continue;
            nonTransparent++;
            if (alpha != 255) continue;
            if (pixels[index] == 0 && pixels[index + 1] == 122 && pixels[index + 2] == 255) {
                opaqueTarget++;
            } else {
                opaqueOther++;
            }
        }

        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(image);
        CFRelease(source);
        free(pixels);

        if (nonTransparent == 0 || opaqueTarget == 0 || opaqueOther != 0) {
            fprintf(stderr, "connect icon is not solid #007AFF: opaqueOther=%d\n", opaqueOther);
            return 1;
        }

        printf("connect icon verified: 60x60 RGBA, opaque #007AFF pixels=%d\n", opaqueTarget);
        return 0;
    }
}
