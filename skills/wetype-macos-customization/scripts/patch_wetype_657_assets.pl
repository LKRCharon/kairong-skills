#!/usr/bin/env perl
use strict;
use warnings;

my ($path) = @ARGV;
die "usage: patch_wetype_657_assets.pl ASSETS_CAR\n" unless $path;

open my $fh, '+<:raw', $path or die "$path: $!\n";
local $/;
my $data = <$fh>;

sub patch_double {
    my ($offset, $old_hex, $new_hex, $label) = @_;
    my $old = pack('H*', $old_hex);
    my $new = pack('H*', $new_hex);
    my $actual = substr($data, $offset, length($old));
    return if $actual eq $new;
    die sprintf("%s: unexpected bytes at 0x%x for %s (got %s, expected %s)\n",
        $path, $offset, $label, unpack('H*', $actual), $old_hex)
        unless $actual eq $old;
    substr($data, $offset, length($old), $new);
}

sub double_hex {
    return unpack('H*', pack('d', $_[0]));
}

sub patch_color_record {
    my ($offset, $old, $new, $label) = @_;
    for my $channel (0 .. 2) {
        patch_double(
            $offset + $channel * 8,
            double_hex($old->[$channel] / 255),
            double_hex($new->[$channel] / 255),
            "$label RGB[$channel]",
        );
    }
}

# Build 657 stores named colors as four consecutive normalized doubles (RGBA).
# Patch only the RGB tuple; alpha stays 1. Every record start was cross-checked
# against assetutil's name, appearance, and color-component output.
my @v_menu_records = (
    [0x21eb44, [0, 177, 118], [217, 45, 112], 'bg03 default selected state'],
    [0x2a98f4, [0, 177, 118], [217, 45, 112], 'bg03 Aqua selected state'],
    [0x2a7684, [0, 168, 111], [217, 45, 112], 'bg03 dark selected state'],
    [0x21eed4, [22, 172, 102], [217, 45, 112], 'bc16 default selected state'],
    [0x2aa144, [22, 172, 102], [217, 45, 112], 'bc16 Aqua selected state'],
    [0x2a8264, [0, 212, 142], [183, 29, 86], 'bc16 dark selected state'],
    [0x21f394, [232, 247, 240], [255, 240, 245], 'bg02 default V-menu background'],
    [0x2aa4d4, [232, 247, 240], [255, 240, 245], 'bg02 Aqua V-menu background'],
    [0x21fbe4, [35, 200, 145], [217, 45, 112], 'bg04 default V-menu accent'],
    [0x2a8ab4, [35, 200, 145], [217, 45, 112], 'bg04 dark V-menu accent'],
    [0x2aae54, [35, 200, 145], [217, 45, 112], 'bg04 Aqua V-menu accent'],
);
for my $record (@v_menu_records) {
    patch_color_record(@$record);
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 657 Assets.car candidate and V-menu colors: $path\n";
