#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

static void fail(NSString *message) {
    fprintf(stderr, "%s\n", message.UTF8String);
    exit(1);
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 2) {
            fprintf(stderr, "usage: patch_wetype_684_connect_icon ICON_PNG\n");
            return 2;
        }

        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSURL *url = [NSURL fileURLWithPath:path];
        if (![url.lastPathComponent isEqualToString:@"icon_button_connect.png"]) {
            fprintf(stderr, "refusing unexpected icon path: %s\n", argv[1]);
            return 2;
        }

        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        CGImageRef image = source ? CGImageSourceCreateImageAtIndex(source, 0, NULL) : NULL;
        if (!image || CGImageGetWidth(image) != 60 || CGImageGetHeight(image) != 60) {
            if (image) CGImageRelease(image);
            if (source) CFRelease(source);
            fprintf(stderr, "refusing unexpected connect icon: expected 60x60 PNG at %s\n", argv[1]);
            return 2;
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
        if (!pixels || !colorSpace || !context) fail(@"could not create RGBA bitmap context");

        CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);

        const int targetR = 217;
        const int targetG = 45;
        const int targetB = 112;
        int nonTransparent = 0;
        int opaque = 0;
        int unexpectedOpaque = 0;
        int sourceR = -1;
        int sourceG = -1;
        int sourceB = -1;

        for (size_t index = 0; index < height * bytesPerRow; index += 4) {
            const int alpha = pixels[index + 3];
            if (alpha == 0) continue;
            nonTransparent++;

            if (alpha == 255) {
                opaque++;
                if (sourceR < 0) {
                    sourceR = pixels[index];
                    sourceG = pixels[index + 1];
                    sourceB = pixels[index + 2];
                } else if (abs((int)pixels[index] - sourceR) > 3
                           || abs((int)pixels[index + 1] - sourceG) > 3
                           || abs((int)pixels[index + 2] - sourceB) > 3) {
                    unexpectedOpaque++;
                }
            }

            pixels[index] = (uint8_t)((targetR * alpha + 127) / 255);
            pixels[index + 1] = (uint8_t)((targetG * alpha + 127) / 255);
            pixels[index + 2] = (uint8_t)((targetB * alpha + 127) / 255);
        }

        if (nonTransparent == 0 || opaque == 0 || sourceR > 80 || sourceG < 150
            || sourceB < 80 || sourceG <= sourceB + 20 || unexpectedOpaque != 0) {
            fail(@"refusing unexpected source palette in connect icon");
        }

        CGImageRef outputImage = CGBitmapContextCreateImage(context);
        NSURL *temporaryURL = [NSURL fileURLWithPath:[path stringByAppendingString:@".tmp"]];
        NSFileManager *fileManager = NSFileManager.defaultManager;
        [fileManager removeItemAtURL:temporaryURL error:nil];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(
            (__bridge CFURLRef)temporaryURL,
            CFSTR("public.png"),
            1,
            NULL
        );
        if (!outputImage || !destination) fail(@"could not create PNG destination");
        CGImageDestinationAddImage(destination, outputImage, NULL);
        if (!CGImageDestinationFinalize(destination)) fail(@"could not write patched connect icon");

        NSError *error = nil;
        if (![fileManager replaceItemAtURL:url
                            withItemAtURL:temporaryURL
                           backupItemName:nil
                                  options:0
                         resultingItemURL:nil
                                    error:&error]) {
            fail([NSString stringWithFormat:@"could not replace connect icon: %@", error]);
        }

        CFRelease(destination);
        CGImageRelease(outputImage);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(image);
        CFRelease(source);
        free(pixels);

        puts("patched connect icon: green -> #D92D70; preserved alpha samples");
        return 0;
    }
}
