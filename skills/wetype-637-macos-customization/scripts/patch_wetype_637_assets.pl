#!/usr/bin/env perl
use strict;
use warnings;

my ($path) = @ARGV;
die "usage: patch_wetype_637_assets.pl ASSETS_CAR\n" unless $path;

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

# 637 Assets.car stores the V-menu palette as named colors. Only RGB component
# doubles are changed; alpha stays 1. The offsets are guarded by exact values.
my $blue_green = '9f9e9e9e9e9ede3f';
my $blue_blue  = '000000000000f03f';
my @records = (
    [0x20218c, '363636363636e63f', 'bg03 light record 1 green'],
    [0x202194, '9e9d9d9d9d9ddd3f', 'bg03 light record 1 blue'],
    [0x28e59c, '363636363636e63f', 'bg03 light record 2 green'],
    [0x28e5a4, '9e9d9d9d9d9ddd3f', 'bg03 light record 2 blue'],
    [0x28c6bc, '151515151515e53f', 'bg03 dark record green'],
    [0x28c6c4, 'dcdbdbdbdbdbdb3f', 'bg03 dark record blue'],
);
for my $record (@records) {
    my ($offset, $old, $label) = @$record;
    my $new = $label =~ /blue/ ? $blue_blue : $blue_green;
    patch_double($offset, $old, $new, $label);
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

my @v_menu_records = (
    [0x201f24, [22, 172, 102], [0, 122, 255], 'bc16 light selected state'],
    [0x28f044, [22, 172, 102], [0, 122, 255], 'bc16 Aqua selected state'],
    [0x28c914, [0, 212, 142], [0, 81, 213], 'bc16 dark selected state'],
    [0x202fc4, [232, 247, 240], [234, 243, 255], 'bg02 light V-menu background'],
    [0x28f504, [232, 247, 240], [234, 243, 255], 'bg02 Aqua V-menu background'],
    [0x2030f4, [35, 200, 145], [0, 122, 255], 'bg04 V-menu accent'],
    [0x28d9b4, [35, 200, 145], [0, 122, 255], 'bg04 dark accent'],
    [0x28eb84, [35, 200, 145], [0, 122, 255], 'bg04 Aqua accent'],
);
for my $record (@v_menu_records) {
    patch_color_record(@$record);
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 637 Assets.car candidate and V-menu colors: $path\n";
