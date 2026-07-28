#!/usr/bin/env perl
use strict;
use warnings;

my ($arch, $path) = @ARGV;
die "usage: patch_wetype_637_main.pl arm64|x86_64 THIN_WETYPE_EXECUTABLE\n"
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

sub patch_ascii {
    my ($old, $new, $label, $expected_count) = @_;
    my $old_count = () = $data =~ /\Q$old\E/g;
    if ($old_count == $expected_count) {
        $data =~ s/\Q$old\E/$new/g;
        print "patched 637 $label: $old -> $new ($expected_count occurrence(s))\n";
        return;
    }

    my $new_count = () = $data =~ /\Q$new\E/g;
    return if $old_count == 0 && $new_count >= $expected_count;

    die "$path: expected $expected_count $label literal(s), found $old_count\n";
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
    assert_bytes(0x7c624, pack('H*', '600486d2'), 'V-menu ARM64 anchor');
    patch_bytes(0x7c628, pack('H*', '0046a8f2'), pack('H*', '00e6a6f2'), 'V-menu blue immediate 1');
    patch_bytes(0x7c62c, pack('H*', '20e6c6f2'), pack('H*', '20c8c8f2'), 'V-menu blue immediate 2');
    patch_bytes(0x7c630, pack('H*', 'c006e0f2'), pack('H*', 'c008e0f2'), 'V-menu blue immediate 3');
} else {
    # The x86_64 slice stores the same colors as ASCII literals.
    patch_ascii('#00B176', '#007AFF', 'x86 V-menu selected state', 1);
    patch_ascii('#23C891', '#007AFF', 'x86 native accent', 1);
    patch_ascii('#62c999', '#64D2FF', 'x86 native voice accent light', 2);
    patch_ascii('#34C759', '#007AFF', 'x86 native voice accent', 4);
}

# VoiceRippleView is native code, separate from the Flutter App.framework.
# Its top color keeps red=0 in both slices, so the requested blue gradient is
# #0A84FF -> #0040DD without changing instruction widths or control flow.
my @top_channels = (
    [0x2cdc1b0, 212, 132, 'voice top green'],
    [0x2cdc1b8, 142, 255, 'voice top blue'],
);
my @bottom_channels = (
    [0x2cd3978, 35, 0, 'voice bottom red'],
    [0x2cd3980, 200, 64, 'voice bottom green'],
    [0x2cd3988, 145, 221, 'voice bottom blue'],
);

if ($arch eq 'x86_64') {
    @top_channels = (
        [0x1c270c8, 212, 132, 'voice top green'],
        [0x1c270d0, 142, 255, 'voice top blue'],
    );
    @bottom_channels = (
        [0x1c1eb78, 35, 0, 'voice bottom red'],
        [0x1c1eb80, 200, 64, 'voice bottom green'],
        [0x1c1eb88, 145, 221, 'voice bottom blue'],
    );
}

for my $channel (@top_channels, @bottom_channels) {
    patch_channel(@$channel);
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 637 $arch native colors: $path\n";
