# Installation, enablement, and troubleshooting

## Install safely

The installed input method lives at:

```text
/Library/Input Methods/WeType.app
```

Always keep the official source and a dated pre-install backup. Use the
provided installer from the user's Terminal, not an AppleScript administrator
shell:

```bash
sudo /bin/bash scripts/install_wetype.sh \
  "$CUSTOM" "/Library/Input Methods/WeType.app" "$BACKUPS"
```

The installer should:

1. Require root and reject an unsigned source.
2. Copy the installed bundle to a dated backup.
3. Verify the backup before replacement.
4. Stop WeType helper processes.
5. Stage and verify the new bundle.
6. Replace the installed path and restore `root:wheel`.
7. Restart `TextInputMenuAgent` and verify the installed signature.

It should not delete WeType dictionaries, `~/Library/Application Support`, or
`~/Library/Caches` as part of a normal install.

## Enable the input source

Open System Settings > Keyboard > Input Sources, add or select WeType Pinyin,
and remove duplicate WeType rows one at a time. Leave one parent input method
and one `com.tencent.inputmethod.wetype.pinyin` mode.

Inspect the actual TIS registry with:

```bash
/bin/bash scripts/diagnose_tis.sh
```

The app is lazy-started. No `WeType` process while another input source is
selected is normal; it is not proof of a stale process. The TIS result and an
actual text-entry test are more important.

For a one-time selection after TIS is clean, compile the optional selector:

```bash
/usr/bin/clang -framework Carbon scripts/select_wetype_tis.c \
  -o /tmp/select_wetype_tis
/tmp/select_wetype_tis
```

If macOS blocks an unsigned temporary helper, select WeType manually in System
Settings or compile/run it from a trusted local development directory.

## Test hosts in order

Use TextEdit first, then Edge, then the real target application. For each host
record:

- selected source ID;
- whether the candidate window appears;
- whether committed Chinese text arrives;
- installed bundle path and signature;
- whether the host is sandboxed/protected;
- whether voice input and auxiliary windows work.

TextEdit success only proves the basic InputMethodKit path. A protected host
may reject a personal Apple Development signature even when the input method
is otherwise correct.

## Triage matrix

### Input works in TextEdit but not another app

Run:

```bash
/usr/bin/codesign --verify --deep --strict \
  "/Library/Input Methods/WeType.app"
/usr/bin/codesign -d --verbose=4 \
  "/Library/Input Methods/WeType.app" 2>&1 \
  | /usr/bin/grep -E 'Authority|TeamIdentifier|Identifier'
/bin/bash scripts/diagnose_tis.sh
```

If TIS shows duplicate pinyin rows, remove the duplicate rows in System
Settings. Direct writes to protected `com.apple.inputsources` preferences can
be rejected or silently reverted. Do not start by deleting caches.

If TIS is clean and the bundle is correctly signed, the remaining likely
boundary is the host's trust/permission policy. Full compatibility would
require the original Tencent Developer ID identity.

### Settings is blue but candidates or voice are green

These are separate layers:

- candidate selection: native main executable plus `Assets.car`;
- voice ripple: native main executable's floating-point constants;
- settings pages: Flutter `App.framework`, SVG, PNG resources.

Re-run the versioned verifier and inspect the exact layer. Do not patch only
Flutter when the green view is native.

### A gradient is pale or flat

The earlier failed approach flattened several stops to `#007AFF`. Restore the
verified hierarchy:

```text
ExampleBox: #64D2FF -> #0A84FF -> #007AFF -> #0051D5
Buttons:    #0A84FF -> #0040DD
Voice:      #0A84FF -> #0040DD
```

These values are verified in the patched 657 binaries and resources, but the
rendered hierarchy still needs visual confirmation after signing and
installation. If a surface looks wrong, identify its owning layer before
changing another AOT group.

### The builder reports unexpected bytes

Treat this as a hard stop. It means one of:

- the source is not exactly 2.2.3 (657);
- a fat-file offset was used without thinning;
- the official package was already patched;
- an upstream update changed the AOT layout;
- the wrong resource was selected.

Make a fresh official copy, compare hashes, and re-disassemble. Never force a
patch by removing the assertion.

### Reboot or restart appears to undo the change

Check the installed bundle version, deep signature, TIS rows, selected source,
and process path. The system may have restored the official package, retained
a duplicate input-source registration, or selected a different input source.
Do not interpret an absent lazy-started process as cache residue.

## LaunchServices and stale work copies

If System Settings lists old work copies, inspect registration paths before
unregistering anything:

```bash
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$LSREGISTER" -dump | /usr/bin/grep -i -A5 -B2 'WeType'
```

Only unregister a path after confirming it no longer exists and is not the
installed `/Library/Input Methods/WeType.app`. Then re-register the installed
bundle and reopen System Settings. LaunchServices cleanup does not replace TIS
duplicate cleanup.

## Rollback

Use only the backup path printed by the installer and verify it first:

```bash
/usr/bin/codesign --verify --deep --strict \
  "/path/to/verified-backup.bundle"
sudo /bin/rm -rf "/Library/Input Methods/WeType.app"
sudo /usr/bin/ditto "/path/to/verified-backup.bundle" \
  "/Library/Input Methods/WeType.app"
sudo /usr/sbin/chown -R root:wheel \
  "/Library/Input Methods/WeType.app"
sudo /usr/bin/codesign --verify --deep --strict \
  "/Library/Input Methods/WeType.app"
```

Do not guess a backup filename. Do not remove user data to solve a signature or
input-source registration problem.

## CDP is not part of this workflow

WeType candidate, voice, and input-source surfaces are native InputMethodKit or
AppKit components. CDP is for Chromium/Electron pages and cannot bypass
codesigning, Team ID, TIS registration, or host trust. Runtime injection is not
a durable replacement for a correctly rebuilt and signed bundle.
