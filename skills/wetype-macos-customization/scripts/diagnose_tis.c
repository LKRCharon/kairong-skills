#include <Carbon/Carbon.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

static void string_property(
    TISInputSourceRef source,
    CFStringRef key,
    char *output,
    size_t output_size
) {
    const void *raw = TISGetInputSourceProperty(source, key);
    if (!raw || CFGetTypeID(raw) != CFStringGetTypeID()) {
        snprintf(output, output_size, "-");
        return;
    }
    if (!CFStringGetCString((CFStringRef)raw, output, output_size, kCFStringEncodingUTF8)) {
        snprintf(output, output_size, "<unprintable>");
    }
}

static bool bool_property(TISInputSourceRef source, CFStringRef key) {
    const void *raw = TISGetInputSourceProperty(source, key);
    return raw && CFGetTypeID(raw) == CFBooleanGetTypeID()
        && CFBooleanGetValue((CFBooleanRef)raw);
}

static bool contains_wetype(const char *value) {
    char lowered[2048];
    size_t index = 0;
    for (; value[index] && index + 1 < sizeof(lowered); index++) {
        char character = value[index];
        lowered[index] = character >= 'A' && character <= 'Z'
            ? (char)(character - 'A' + 'a')
            : character;
    }
    lowered[index] = '\0';
    return strstr(lowered, "wetype") != NULL;
}

int main(void) {
    CFArrayRef sources = TISCreateInputSourceList(NULL, true);
    if (!sources) {
        fprintf(stderr, "could not read the TIS input-source registry\n");
        return 1;
    }

    CFIndex count = CFArrayGetCount(sources);
    for (CFIndex index = 0; index < count; index++) {
        TISInputSourceRef source = (TISInputSourceRef)CFArrayGetValueAtIndex(sources, index);
        char bundle[2048];
        char source_id[2048];
        char name[2048];
        char type[2048];
        string_property(source, kTISPropertyBundleID, bundle, sizeof(bundle));
        string_property(source, kTISPropertyInputSourceID, source_id, sizeof(source_id));
        if (!contains_wetype(bundle) && !contains_wetype(source_id)) continue;

        string_property(source, kTISPropertyLocalizedName, name, sizeof(name));
        string_property(source, kTISPropertyInputSourceType, type, sizeof(type));
        printf(
            "bundle=%s id=%s name=%s type=%s enabled=%s selected=%s "
            "enableCapable=%s selectCapable=%s\n",
            bundle,
            source_id,
            name,
            type,
            bool_property(source, kTISPropertyInputSourceIsEnabled) ? "true" : "false",
            bool_property(source, kTISPropertyInputSourceIsSelected) ? "true" : "false",
            bool_property(source, kTISPropertyInputSourceIsEnableCapable) ? "true" : "false",
            bool_property(source, kTISPropertyInputSourceIsSelectCapable) ? "true" : "false"
        );
    }

    CFRelease(sources);
    return 0;
}
