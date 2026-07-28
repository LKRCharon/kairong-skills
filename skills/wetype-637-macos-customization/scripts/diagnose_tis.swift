import Carbon.HIToolbox
import Foundation

func stringProperty(_ source: TISInputSource, _ key: CFString) -> String {
    guard let raw = TISGetInputSourceProperty(source, key) else { return "-" }
    return Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
}

func boolProperty(_ source: TISInputSource, _ key: CFString) -> Bool {
    guard let raw = TISGetInputSourceProperty(source, key) else { return false }
    let value = Unmanaged<CFBoolean>.fromOpaque(raw).takeUnretainedValue()
    return CFBooleanGetValue(value)
}

let sources = TISCreateInputSourceList(nil, true).takeRetainedValue() as NSArray
for case let source as TISInputSource in sources {
    let bundleID = stringProperty(source, kTISPropertyBundleID)
    let sourceID = stringProperty(source, kTISPropertyInputSourceID)
    if bundleID.localizedCaseInsensitiveContains("wetype") || sourceID.localizedCaseInsensitiveContains("wetype") {
        let name = stringProperty(source, kTISPropertyLocalizedName)
        let type = stringProperty(source, kTISPropertyInputSourceType)
        let enabled = boolProperty(source, kTISPropertyInputSourceIsEnabled)
        let selected = boolProperty(source, kTISPropertyInputSourceIsSelected)
        let enableCapable = boolProperty(source, kTISPropertyInputSourceIsEnableCapable)
        let selectCapable = boolProperty(source, kTISPropertyInputSourceIsSelectCapable)
        print("bundle=\(bundleID) id=\(sourceID) name=\(name) type=\(type) enabled=\(enabled) selected=\(selected) enableCapable=\(enableCapable) selectCapable=\(selectCapable)")
    }
}
