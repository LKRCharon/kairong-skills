#!/usr/bin/env perl
use strict;
use warnings;

my ($arch, $path) = @ARGV;
die "usage: patch_wetype_657_main.pl arm64|x86_64 THIN_WETYPE_EXECUTABLE\n"
    unless $arch && $path && ($arch eq 'arm64' || $arch eq 'x86_64');

open my $fh, '+<:raw', $path or die "$path: $!\n";
local $/;
my $data = <$fh>;

sub patch_bytes {
    my ($offset, $old, $new, $label) = @_;
    my $actual = substr($data, $offset, length($old));
    return 0 if $actual eq $new;
    die sprintf("%s: unexpected bytes at 0x%x for %s (got %s, expected %s)\n",
        $path, $offset, $label, unpack('H*', $actual), unpack('H*', $old))
        unless $actual eq $old;
    substr($data, $offset, length($old), $new);
    return 1;
}

sub patch_ascii_at {
    my ($offset, $old, $new, $label) = @_;
    my $changed = patch_bytes($offset, $old, $new, $label);
    print "patched 657 $label at " . sprintf('0x%x', $offset)
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
    patch_bytes(0xf8ee8, pack('H*', '600486d2'), pack('H*', '608488d2'), 'V-menu string fragment 1');
    patch_bytes(0xf8eec, pack('H*', '0046a8f2'), pack('H*', '2047a6f2'), 'V-menu string fragment 2');
    patch_bytes(0xf8ef0, pack('H*', '20e6c6f2'), pack('H*', '80e8c6f2'), 'V-menu string fragment 3');
    patch_bytes(0xf8ef4, pack('H*', 'c006e0f2'), pack('H*', '0006e0f2'), 'V-menu string fragment 4');
} else {
    # The x86_64 slice stores these colors as fixed-position ASCII literals.
    patch_ascii_at(0x108d4f, '#00B176', '#D92D70', 'x86 V-menu selected state');
    patch_ascii_at(0x54faa0, '#23C891', '#D92D70', 'x86 native accent');
    patch_ascii_at(0x1954ee, '#62c999', '#FFA9CA', 'x86 native voice accent light 1');
    patch_ascii_at(0x1959b6, '#62c999', '#FFA9CA', 'x86 native voice accent light 2');
    patch_ascii_at(0x195514, '#34C759', '#D92D70', 'x86 native voice accent 1');
    patch_ascii_at(0x1959dc, '#34C759', '#D92D70', 'x86 native voice accent 2');
    patch_ascii_at(0x1965d4, '#34C759', '#D92D70', 'x86 native voice accent 3');
    patch_ascii_at(0x196765, '#34C759', '#D92D70', 'x86 native voice accent 4');
}

# VoiceRippleView passes RGB doubles to a shared initializer. Its top
# red is normally zeroed in a register instead of loaded from data.
if ($arch eq 'arm64') {
    # Replace movi d0, #0 with fmov d0, #1.0.
    patch_bytes(0x52d3f0, pack('H*', '00e4002f'), pack('H*', '00106e1e'), 'voice top red');
} else {
    # Load 1.0 from the alignment padding, pop rbp, and jump to the
    # same initializer. The short jump skips the inline double.
    patch_bytes(0x5a5c2b,
        pack('H*', '0f57c05de93c0000006666662e0f1f840000000000'),
        pack('H*', 'f20f1005030000005deb3a000000000000f03f6690'),
        'voice top red and alignment padding');
}

my @top_channels = (
    [0x2e28250, 212, 109, 'voice top green'],
    [0x2e28258, 142, 156, 'voice top blue'],
);
my @bottom_channels = (
    [0x2e24f80, 35, 169, 'voice bottom red'],
    [0x2e203d0, 200, 22, 'voice bottom green'],
    [0x2e24f88, 145, 80, 'voice bottom blue'],
);

if ($arch eq 'x86_64') {
    @top_channels = (
        [0x1d7f5d8, 212, 109, 'voice top green'],
        [0x1d7f5e0, 142, 156, 'voice top blue'],
    );
    @bottom_channels = (
        [0x1d7c9a0, 35, 169, 'voice bottom red'],
        [0x1d77fb0, 200, 22, 'voice bottom green'],
        [0x1d7c9a8, 145, 80, 'voice bottom blue'],
    );
}

for my $channel (@top_channels, @bottom_channels) {
    patch_channel(@$channel);
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 657 $arch native colors: $path\n";
