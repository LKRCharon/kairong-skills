#!/usr/bin/env perl
use strict;
use warnings;

my ($arch, $path) = @ARGV;
die "usage: patch_wetype_657_colors.pl arm64|x86_64 THIN_APP_FRAMEWORK_FILE\n"
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

sub pack_word {
    return pack('V', $_[0]);
}

sub arm_movz_x {
    my ($reg, $imm16, $shift) = @_;
    die "invalid ARM64 MOVZ shift\n" unless $shift == 0 || $shift == 16;
    my $hw = $shift / 16;
    return 0xd2800000 | ($hw << 21) | (($imm16 & 0xffff) << 5) | ($reg & 0x1f);
}

sub arm_patch_fragment {
    my ($offset, $old_imm16, $old_shift, $new_imm16, $new_shift, $label) = @_;
    my $actual = unpack('V', substr($data, $offset, 4));
    my $reg = $actual & 0x1f;
    my $old_movz = arm_movz_x($reg, $old_imm16, $old_shift);
    my $new_movz = arm_movz_x($reg, $new_imm16, $new_shift);
    return 0 if $actual == $new_movz;
    my $is_old_logical_ff00 = $old_imm16 == 0xff00
        && $old_shift == 0
        && (($actual & 0xffffffe0) == 0xb2781fe0);
    die sprintf("%s: unexpected ARM64 instruction at 0x%x for %s (got %08x, expected %08x)\n",
        $path, $offset, $label, $actual, $old_movz)
        unless $actual == $old_movz || $is_old_logical_ff00;
    patch_bytes($offset, pack_word($actual), pack_word($new_movz), $label);
}

sub arm_patch_full_group {
    my ($r_offset, $g_offset, $b_offset, $old, $new, $label) = @_;
    arm_patch_fragment($r_offset, $old->[0], 16, $new->[0], 16, "$label red");
    arm_patch_fragment($g_offset, $old->[1] << 8, 0, $new->[1] << 8, 0, "$label green");
    arm_patch_fragment($b_offset, $old->[2], 0, $new->[2], 0, "$label blue");
}

sub arm_patch_sparse_group {
    my ($g_offset, $b_offset, $old, $new, $label) = @_;
    arm_patch_fragment($g_offset, $old->[1] << 8, 0, $new->[1] << 8, 0, "$label green");
    arm_patch_fragment($b_offset, $old->[2], 0, $new->[2], 0, "$label blue");
}

sub x86_patch_imm {
    my ($instruction_offset, $old_value, $new_value, $label) = @_;
    patch_bytes(
        $instruction_offset + 1,
        pack_word($old_value),
        pack_word($new_value),
        $label,
    );
}

sub x86_patch_full_group {
    my ($r_offset, $g_offset, $b_offset, $old, $new, $label) = @_;
    x86_patch_imm($r_offset, $old->[0] << 16, $new->[0] << 16, "$label red");
    x86_patch_imm($g_offset, $old->[1] << 8, $new->[1] << 8, "$label green");
    x86_patch_imm($b_offset, $old->[2], $new->[2], "$label blue");
}

sub x86_patch_sparse_group {
    my ($g_offset, $b_offset, $old, $new, $label) = @_;
    x86_patch_imm($g_offset, $old->[1] << 8, $new->[1] << 8, "$label green");
    x86_patch_imm($b_offset, $old->[2], $new->[2], "$label blue");
}

# Flutter's snapshot contains the static green palette used by the V panel and
# other settings surfaces. These byte sequences are stable within the 657 AOT.
my @snapshot_patches = $arch eq 'arm64'
    ? (
        [0x4e336d, '11110fb9c0', '7f7501b8c0', 'static palette root'],
        [0x4e3372, '6f5002b8', '7f7501b8', 'static palette variant 1'],
        [0x4e3385, '766202b8', '7f6317bf', 'static palette variant 2'],
        [0x4e329e, '0e2903b8', '7f7501b8', 'static palette variant 3'],
        [0x4e32e4, '66585ab8', '7f7501b8', 'static palette variant 4'],
        [0x4e338a, '706f23bf', '7f6317bf', 'static palette variant 5'],
    )
    : (
        [0x51d84f, '11110fb9c0', '7f7501b8c0', 'static palette root'],
        [0x51d854, '6f5002b8', '7f7501b8', 'static palette variant 1'],
        [0x51d867, '766202b8', '7f6317bf', 'static palette variant 2'],
        [0x51d780, '0e2903b8', '7f7501b8', 'static palette variant 3'],
        [0x51d7c6, '66585ab8', '7f7501b8', 'static palette variant 4'],
        [0x51d86c, '706f23bf', '7f6317bf', 'static palette variant 5'],
    );

for my $patch (@snapshot_patches) {
    patch_bytes($patch->[0], pack('H*', $patch->[1]), pack('H*', $patch->[2]), $patch->[3]);
}

if ($arch eq 'arm64') {
    my $blue_cyan = [0x64, 0xd2, 0xff];
    my $system_blue = [0x00, 0x7a, 0xff];
    my $deep_blue = [0x0a, 0x84, 0xff];
    my $button_start = [0x0a, 0x84, 0xff];
    my $button_end = [0x00, 0x40, 0xdd];
    my $deep_system_blue = [0x00, 0x51, 0xd5];
    my $light_blue = [0x5a, 0xc8, 0xfa];

    my @full_groups = (
        [0x24ae30, 0x24ae38, 0x24ae40, [0x25, 0xce, 0x96], $button_start, 'common button gradient 1'],
        [0x24ae8c, 0x24ae94, 0x24ae9c, [0x1f, 0xc3, 0x8d], $button_end, 'common button gradient 2'],
        [0x2e8a44, 0x2e8a4c, 0x2e8a54, [0x6a, 0xff, 0xcd], $blue_cyan, 'appearance example gradient 1'],
        [0x2e8aa4, 0x2e8aac, 0x2e8ab4, [0x23, 0xc8, 0x91], $deep_blue, 'appearance example gradient 2'],
        [0x2e8b18, 0x2e8b20, 0x2e8b28, [0x6a, 0xff, 0x8b], $system_blue, 'appearance example gradient 3'],
        [0x2e8b7c, 0x2e8b84, 0x2e8b8c, [0x58, 0xc8, 0x23], $deep_system_blue, 'appearance example gradient 4'],
        [0x3072cc, 0x3072d4, 0x3072dc, [0x6a, 0xff, 0xcd], $light_blue, 'phone example gradient 1'],
        [0x307328, 0x307330, 0x307338, [0x23, 0xc8, 0x91], $deep_blue, 'phone example gradient 2'],
        [0x307394, 0x30739c, 0x3073a4, [0x6a, 0xff, 0x8b], $system_blue, 'phone example gradient 3'],
        [0x3073f8, 0x307400, 0x307408, [0x58, 0xc8, 0x23], $deep_system_blue, 'phone example gradient 4'],
        [0x30b0dc, 0x30b0e4, 0x30b0ec, [0x6a, 0xff, 0xcd], $light_blue, 'toolbar preview gradient 1'],
        [0x30b13c, 0x30b144, 0x30b14c, [0x23, 0xc8, 0x91], $deep_blue, 'toolbar preview gradient 2'],
        [0x30b1b0, 0x30b1b8, 0x30b1c0, [0x6a, 0xff, 0x8b], $system_blue, 'toolbar preview gradient 3'],
        [0x30b214, 0x30b21c, 0x30b224, [0x58, 0xc8, 0x23], $deep_system_blue, 'toolbar preview gradient 4'],
    );
    for my $group (@full_groups) {
        arm_patch_full_group(@$group);
    }

    my @green_groups = (
        [0x24d444, 0x24d44c, 0x24d454, [0x23, 0xc8, 0x91], $system_blue, 'input settings accent'],
        [0x250834, 0x25083c, 0x250844, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 1'],
        [0x250aa0, 0x250aa8, 0x250ab0, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 2'],
        [0x251000, 0x251008, 0x251010, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 3'],
        [0x2e5d2c, 0x2e5d34, 0x2e5d3c, [0x23, 0xc8, 0x91], $system_blue, 'about accent'],
        [0x2f6930, 0x2f6938, 0x2f6940, [0x23, 0xc8, 0x91], $system_blue, 'hotword operation accent'],
        [0x302180, 0x302188, 0x302190, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 4'],
        [0x307970, 0x307978, 0x307980, [0x23, 0xc8, 0x91], $button_end, 'phone download gradient 2'],
    );
    for my $group (@green_groups) {
        arm_patch_full_group(@$group);
    }

    my @cyan_groups = (
        [0x2507e0, 0x2507e8, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 1 start'],
        [0x250a10, 0x250a14, [0x00, 0xd4, 0x8e], $button_start, 'multi-device branch preload'],
        [0x250a4c, 0x250a54, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 2 start'],
        [0x2f68dc, 0x2f68e4, [0x00, 0xd4, 0x8e], $blue_cyan, 'hotword operation gradient 1'],
        [0x30212c, 0x302134, [0x00, 0xd4, 0x8e], $blue_cyan, 'multi-device gradient 3 start'],
        [0x30791c, 0x307924, [0x00, 0xd4, 0x8e], $button_start, 'phone download gradient 1'],
    );
    for my $group (@cyan_groups) {
        arm_patch_sparse_group(@$group);
    }
} else {
    my $blue_cyan = [0x64, 0xd2, 0xff];
    my $system_blue = [0x00, 0x7a, 0xff];
    my $deep_blue = [0x0a, 0x84, 0xff];
    my $button_start = [0x0a, 0x84, 0xff];
    my $button_end = [0x00, 0x40, 0xdd];
    my $deep_system_blue = [0x00, 0x51, 0xd5];
    my $light_blue = [0x5a, 0xc8, 0xfa];

    my @full_groups = (
        [0x2cfb6b, 0x2cfb72, 0x2cfb79, [0x25, 0xce, 0x96], $button_start, 'common button gradient 1'],
        [0x2cfbc4, 0x2cfbcb, 0x2cfbd2, [0x1f, 0xc3, 0x8d], $button_end, 'common button gradient 2'],
        [0x3083fa, 0x308401, 0x308408, [0x6a, 0xff, 0xcd], $blue_cyan, 'appearance example gradient 1'],
        [0x308457, 0x30845e, 0x308465, [0x23, 0xc8, 0x91], $deep_blue, 'appearance example gradient 2'],
        [0x3084cc, 0x3084d3, 0x3084da, [0x6a, 0xff, 0x8b], $system_blue, 'appearance example gradient 3'],
        [0x30852e, 0x308535, 0x30853c, [0x58, 0xc8, 0x23], $deep_system_blue, 'appearance example gradient 4'],
        [0x328f48, 0x328f4f, 0x328f56, [0x6a, 0xff, 0xcd], $light_blue, 'phone example gradient 1'],
        [0x328fa2, 0x328fa9, 0x328fb0, [0x23, 0xc8, 0x91], $deep_blue, 'phone example gradient 2'],
        [0x329010, 0x329017, 0x32901e, [0x6a, 0xff, 0x8b], $system_blue, 'phone example gradient 3'],
        [0x329072, 0x329079, 0x329080, [0x58, 0xc8, 0x23], $deep_system_blue, 'phone example gradient 4'],
        [0x32d222, 0x32d229, 0x32d230, [0x6a, 0xff, 0xcd], $light_blue, 'toolbar preview gradient 1'],
        [0x32d27f, 0x32d286, 0x32d28d, [0x23, 0xc8, 0x91], $deep_blue, 'toolbar preview gradient 2'],
        [0x32d2f4, 0x32d2fb, 0x32d302, [0x6a, 0xff, 0x8b], $system_blue, 'toolbar preview gradient 3'],
        [0x32d356, 0x32d35d, 0x32d364, [0x58, 0xc8, 0x23], $deep_system_blue, 'toolbar preview gradient 4'],
    );
    for my $group (@full_groups) {
        x86_patch_full_group(@$group);
    }

    my @green_groups = (
        [0x31730e, 0x317315, 0x31731c, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 1'],
        [0x3238a5, 0x3238ac, 0x3238b3, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 2'],
        [0x2d24ea, 0x2d24f1, 0x2d24f8, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 1'],
        [0x2d5ce4, 0x2d5ceb, 0x2d5cf2, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 2'],
        [0x2d5f4f, 0x2d5f56, 0x2d5f5d, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 3'],
        [0x2d6510, 0x2d6517, 0x2d651e, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 4'],
        [0x3053fb, 0x305402, 0x305409, [0x23, 0xc8, 0x91], $system_blue, 'debug accent'],
        [0x329646, 0x32964d, 0x329654, [0x23, 0xc8, 0x91], $button_end, 'phone download gradient 2'],
    );
    for my $group (@green_groups) {
        x86_patch_full_group(@$group);
    }

    my @cyan_groups = (
        [0x2d5c92, 0x2d5c99, [0x00, 0xd4, 0x8e], $blue_cyan, 'settings gradient 1'],
        [0x2d5eba, 0x2d5ebf, [0x00, 0xd4, 0x8e], $blue_cyan, 'settings branch preload'],
        [0x2d5efd, 0x2d5f04, [0x00, 0xd4, 0x8e], $blue_cyan, 'settings gradient 2'],
        [0x3172bc, 0x3172c3, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 1 start'],
        [0x323853, 0x32385a, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 2 start'],
        [0x3295f4, 0x3295fb, [0x00, 0xd4, 0x8e], $button_start, 'phone download gradient 1 start'],
    );
    for my $group (@cyan_groups) {
        x86_patch_sparse_group(@$group);
    }
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 657 $arch colors: $path\n";
