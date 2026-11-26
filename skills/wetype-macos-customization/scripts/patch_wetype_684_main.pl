#!/usr/bin/env perl
use strict;
use warnings;

my ($arch, $path, $build) = @ARGV;
$build //= '684';
die "usage: patch_wetype_684_main.pl arm64|x86_64 THIN_WETYPE_EXECUTABLE [684|689]\n"
    unless $arch && $path && ($arch eq 'arm64' || $arch eq 'x86_64');

die "unsupported native patch profile: $build\n" unless $build eq '684' || $build eq '689';

# Build 689 retains these color encodings at different thin-file offsets.
my %offsets_689 = $arch eq 'arm64'
    ? (
        0x10c004 => 0x10d78c,
        0x10c008 => 0x10d790,
        0x10c00c => 0x10d794,
        0x10c010 => 0x10d798,
        0x6c757c => 0x6e5af8,
        0x2cfeee0 => 0x2d1fea0,
        0x2cfeee8 => 0x2d1fea8,
        0x2cf28c0 => 0x2d137b0,
        0x2cf28c8 => 0x2d137b8,
        0x2cf28d0 => 0x2d137c0,
    )
    : (
        0x11f8af => 0x12165f,
        0x6fd560 => 0x71ef60,
        0x1c1a6e => 0x1c5a7e,
        0x1c1f36 => 0x1c5f46,
        0x1c1a94 => 0x1c5aa4,
        0x1c1f5c => 0x1c5f6c,
        0x1c2b54 => 0x1c6b64,
        0x1c2ce5 => 0x1c6cf5,
        0x76adbb => 0x78c54b,
        0x1ff52b8 => 0x2019258,
        0x1ff52c0 => 0x2019260,
        0x1fe9538 => 0x200d438,
        0x1fe9540 => 0x200d440,
        0x1fe9548 => 0x200d448,
    );

open my $fh, '+<:raw', $path or die "$path: $!\n";
local $/;
my $data = <$fh>;

sub patch_bytes {
    my ($offset, $old, $new, $label) = @_;
    if ($build eq '689') {
        $offset = $offsets_689{$offset} // die sprintf("no 689 native patch offset for 0x%x\n", $offset);
    }
    my $actual = substr($data, $offset, length($old));
    return 0 if $actual eq $new;
    die sprintf("%s: unexpected bytes at 0x%x for %s (got %s, expected %s)\n",
        $path, $offset, $label, unpack('H*', $actual), unpack('H*', $old))
        unless $actual eq $old;
    substr($data, $offset, length($old), $new);
    return $offset;
}

sub patch_ascii_at {
    my ($offset, $old, $new, $label) = @_;
    my $changed = patch_bytes($offset, $old, $new, $label);
    print "patched $build $label at " . sprintf('0x%x', $changed)
        . ": $old -> $new\n" if $changed;
}

sub double_bytes {
    my ($channel) = @_;
    return pack('d', $channel / 255);
}

sub patch_channel {
    my ($offset, $old_channel, $new_channel, $label) = @_;
    patch_bytes(
        $offset,
        double_bytes($old_channel),
        double_bytes($new_channel),
        $label,
    );
}

if ($arch eq 'arm64') {
    # VModeMenuItemView.updateLayer builds #00B176 with MOVK fragments;
    # there is no ASCII color literal for this ARM64 path.
    patch_bytes(0x10c004, pack('H*', '600486d2'), pack('H*', '608488d2'), 'V-menu string fragment 1');
    patch_bytes(0x10c008, pack('H*', '0046a8f2'), pack('H*', '2047a6f2'), 'V-menu string fragment 2');
    patch_bytes(0x10c00c, pack('H*', '20e6c6f2'), pack('H*', '80e8c6f2'), 'V-menu string fragment 3');
    patch_bytes(0x10c010, pack('H*', 'c006e0f2'), pack('H*', '0006e0f2'), 'V-menu string fragment 4');
} else {
    # The x86_64 slice stores these colors as fixed-position ASCII literals.
    patch_ascii_at(0x11f8af, '#00B176', '#D92D70', 'x86 V-menu selected state');
    patch_ascii_at(0x6fd560, '#23C891', '#D92D70', 'x86 native accent');
    patch_ascii_at(0x1c1a6e, '#62c999', '#FFA9CA', 'x86 native voice accent light 1');
    patch_ascii_at(0x1c1f36, '#62c999', '#FFA9CA', 'x86 native voice accent light 2');
    patch_ascii_at(0x1c1a94, '#34C759', '#D92D70', 'x86 native voice accent 1');
    patch_ascii_at(0x1c1f5c, '#34C759', '#D92D70', 'x86 native voice accent 2');
    patch_ascii_at(0x1c2b54, '#34C759', '#D92D70', 'x86 native voice accent 3');
    patch_ascii_at(0x1c2ce5, '#34C759', '#D92D70', 'x86 native voice accent 4');
}

# VoiceRippleView passes RGB doubles to a shared initializer. Its top
# red is normally zeroed in a register instead of loaded from data.
if ($arch eq 'arm64') {
    # Replace movi d0, #0 with fmov d0, #1.0.
    patch_bytes(0x6c757c, pack('H*', '00e4002f'), pack('H*', '00106e1e'), 'voice top red');
} else {
    # Load 1.0 from the alignment padding, pop rbp, and jump to the
    # same initializer. The short jump skips the inline double.
    patch_bytes(0x76adbb,
        pack('H*', '0f57c05de93c0000006666662e0f1f840000000000'),
        pack('H*', 'f20f1005030000005deb3a000000000000f03f6690'),
        'voice top red and alignment padding');
}

my @top_channels = (
    [0x2cfeee0, 212, 109, 'voice top green'],
    [0x2cfeee8, 142, 156, 'voice top blue'],
);
my @bottom_channels = (
    [0x2cf28c0, 35, 169, 'voice bottom red'],
    [0x2cf28c8, 200, 22, 'voice bottom green'],
    [0x2cf28d0, 145, 80, 'voice bottom blue'],
);

if ($arch eq 'x86_64') {
    @top_channels = (
        [0x1ff52b8, 212, 109, 'voice top green'],
        [0x1ff52c0, 142, 156, 'voice top blue'],
    );
    @bottom_channels = (
        [0x1fe9538, 35, 169, 'voice bottom red'],
        [0x1fe9540, 200, 22, 'voice bottom green'],
        [0x1fe9548, 145, 80, 'voice bottom blue'],
    );
}

for my $channel (@top_channels, @bottom_channels) {
    patch_channel(@$channel);
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched $build $arch native colors: $path\n";
