#include <Carbon/Carbon.h>
#include <stdio.h>

int main(void) {
    CFStringRef source_id = CFSTR("com.tencent.inputmethod.wetype.pinyin");
    const void *keys[] = { kTISPropertyInputSourceID };
    const void *values[] = { source_id };
    CFDictionaryRef properties = CFDictionaryCreate(
        kCFAllocatorDefault,
        keys,
        values,
        1,
        &kCFTypeDictionaryKeyCallBacks,
        &kCFTypeDictionaryValueCallBacks
    );
    CFArrayRef sources = TISCreateInputSourceList(NULL, true);
    CFRelease(properties);

    TISInputSourceRef source = NULL;
    if (sources) {
        CFIndex count = CFArrayGetCount(sources);
        for (CFIndex index = 0; index < count; index++) {
            TISInputSourceRef candidate = (TISInputSourceRef)CFArrayGetValueAtIndex(sources, index);
            CFStringRef candidate_id = TISGetInputSourceProperty(candidate, kTISPropertyInputSourceID);
            if (candidate_id && CFEqual(candidate_id, source_id)) {
                source = candidate;
                break;
            }
        }
    }

    if (!source) {
        fprintf(stderr, "input source not found\n");
        if (sources) CFRelease(sources);
        return 2;
    }

    OSStatus status = TISEnableInputSource(source);
    if (status == noErr) {
        status = TISSelectInputSource(source);
    }
    CFRelease(sources);

    if (status != noErr) {
        fprintf(stderr, "TISSelectInputSource failed: %d\n", (int)status);
        return 3;
    }

    puts("selected com.tencent.inputmethod.wetype.pinyin");
    return 0;
}
