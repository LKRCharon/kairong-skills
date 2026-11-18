#!/usr/bin/env perl
use strict;
use warnings;

my ($arch, $path) = @ARGV;
die "usage: patch_wetype_684_main.pl arm64|x86_64 THIN_WETYPE_EXECUTABLE\n"
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

sub assert_bytes {
    my ($offset, $expected, $label) = @_;
    my $actual = substr($data, $offset, length($expected));
    die sprintf("%s: unexpected bytes at 0x%x for %s (got %s, expected %s)\n",
        $path, $offset, $label, unpack('H*', $actual), unpack('H*', $expected))
        unless $actual eq $expected;
}

sub patch_ascii_at {
    my ($offset, $old, $new, $label) = @_;
    my $changed = patch_bytes($offset, $old, $new, $label);
    print "patched 684 $label at " . sprintf('0x%x', $offset)
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
    assert_bytes(0x10c004, pack('H*', '600486d2'), 'V-menu ARM64 anchor');
    patch_bytes(0x10c008, pack('H*', '0046a8f2'), pack('H*', '00e6a6f2'), 'V-menu blue immediate 1');
    patch_bytes(0x10c00c, pack('H*', '20e6c6f2'), pack('H*', '20c8c8f2'), 'V-menu blue immediate 2');
    patch_bytes(0x10c010, pack('H*', 'c006e0f2'), pack('H*', 'c008e0f2'), 'V-menu blue immediate 3');
} else {
    # The x86_64 slice stores these colors as fixed-position ASCII literals.
    patch_ascii_at(0x11f8af, '#00B176', '#007AFF', 'x86 V-menu selected state');
    patch_ascii_at(0x6fd560, '#23C891', '#007AFF', 'x86 native accent');
    patch_ascii_at(0x1c1a6e, '#62c999', '#64D2FF', 'x86 native voice accent light 1');
    patch_ascii_at(0x1c1f36, '#62c999', '#64D2FF', 'x86 native voice accent light 2');
    patch_ascii_at(0x1c1a94, '#34C759', '#007AFF', 'x86 native voice accent 1');
    patch_ascii_at(0x1c1f5c, '#34C759', '#007AFF', 'x86 native voice accent 2');
    patch_ascii_at(0x1c2b54, '#34C759', '#007AFF', 'x86 native voice accent 3');
    patch_ascii_at(0x1c2ce5, '#34C759', '#007AFF', 'x86 native voice accent 4');
}

# VoiceRippleView is native code, separate from the Flutter App.framework.
# Its top color keeps red=0 in both slices, so the requested blue gradient is
# #0A84FF -> #0040DD without changing instruction widths or control flow.
my @top_channels = (
    [0x2cfeee0, 212, 132, 'voice top green'],
    [0x2cfeee8, 142, 255, 'voice top blue'],
);
my @bottom_channels = (
    [0x2cf28c0, 35, 0, 'voice bottom red'],
    [0x2cf28c8, 200, 64, 'voice bottom green'],
    [0x2cf28d0, 145, 221, 'voice bottom blue'],
);

if ($arch eq 'x86_64') {
    @top_channels = (
        [0x1ff52b8, 212, 132, 'voice top green'],
        [0x1ff52c0, 142, 255, 'voice top blue'],
    );
    @bottom_channels = (
        [0x1fe9538, 35, 0, 'voice bottom red'],
        [0x1fe9540, 200, 64, 'voice bottom green'],
        [0x1fe9548, 145, 221, 'voice bottom blue'],
    );
}

for my $channel (@top_channels, @bottom_channels) {
    patch_channel(@$channel);
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 684 $arch native colors: $path\n";
