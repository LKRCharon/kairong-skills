#!/usr/bin/env perl
use strict;
use warnings;

my ($arch, $path) = @ARGV;
die "usage: patch_wetype_637_colors.pl arm64|x86_64 THIN_APP_FRAMEWORK_FILE\n"
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
    my $expected_movz = arm_movz_x($reg, $old_imm16, $old_shift);
    my $is_old_logical_ff00 = $old_imm16 == 0xff00
        && $old_shift == 0
        && (($actual & 0xffffffe0) == 0xb2781fe0);
    die sprintf("%s: unexpected ARM64 instruction at 0x%x for %s (got %08x, expected %08x)\n",
        $path, $offset, $label, $actual, $expected_movz)
        unless $actual == $expected_movz || $is_old_logical_ff00;
    my $new_word = arm_movz_x($reg, $new_imm16, $new_shift);
    patch_bytes($offset, pack_word($actual), pack_word($new_word), $label);
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
# other settings surfaces. These byte sequences are stable within the 637 AOT.
my @snapshot_patches = $arch eq 'arm64'
    ? (
        [0x4e12a8, '11110fb9c0', '7f7501b8c0', 'static palette root'],
        [0x4e12ad, '6f5002b8', '7f7501b8', 'static palette variant 1'],
        [0x4e12c0, '766202b8', '7f6317bf', 'static palette variant 2'],
        [0x4e11d9, '0e2903b8', '7f7501b8', 'static palette variant 3'],
        [0x4e121f, '66585ab8', '7f7501b8', 'static palette variant 4'],
        [0x4e12c5, '706f23bf', '7f6317bf', 'static palette variant 5'],
    )
    : (
        [0x5176d6, '11110fb9c0', '7f7501b8c0', 'static palette root'],
        [0x5176db, '6f5002b8', '7f7501b8', 'static palette variant 1'],
        [0x5176ee, '766202b8', '7f6317bf', 'static palette variant 2'],
        [0x517607, '0e2903b8', '7f7501b8', 'static palette variant 3'],
        [0x51764d, '66585ab8', '7f7501b8', 'static palette variant 4'],
        [0x5176f3, '706f23bf', '7f6317bf', 'static palette variant 5'],
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
        [0x232c00, 0x232c08, 0x232c10, [0x25, 0xce, 0x96], $button_start, 'common button gradient 1'],
        [0x232c5c, 0x232c64, 0x232c6c, [0x1f, 0xc3, 0x8d], $button_end, 'common button gradient 2'],
        [0x2843bc, 0x2843c4, 0x2843cc, [0x6a, 0xff, 0xcd], $blue_cyan, 'appearance example gradient 1'],
        [0x28441c, 0x284424, 0x28442c, [0x23, 0xc8, 0x91], $deep_blue, 'appearance example gradient 2'],
        [0x284490, 0x284498, 0x2844a0, [0x6a, 0xff, 0x8b], $system_blue, 'appearance example gradient 3'],
        [0x2844f4, 0x2844fc, 0x284504, [0x58, 0xc8, 0x23], $deep_system_blue, 'appearance example gradient 4'],
        [0x2a2df8, 0x2a2e00, 0x2a2e08, [0x6a, 0xff, 0xcd], $light_blue, 'phone example gradient 1'],
        [0x2a2e54, 0x2a2e5c, 0x2a2e64, [0x23, 0xc8, 0x91], $deep_blue, 'phone example gradient 2'],
        [0x2a2ec0, 0x2a2ec8, 0x2a2ed0, [0x6a, 0xff, 0x8b], $system_blue, 'phone example gradient 3'],
        [0x2a2f24, 0x2a2f2c, 0x2a2f34, [0x58, 0xc8, 0x23], $deep_system_blue, 'phone example gradient 4'],
        [0x2a6c50, 0x2a6c58, 0x2a6c60, [0x6a, 0xff, 0xcd], $light_blue, 'toolbar preview gradient 1'],
        [0x2a6cac, 0x2a6cb4, 0x2a6cbc, [0x23, 0xc8, 0x91], $deep_blue, 'toolbar preview gradient 2'],
        [0x2a6d18, 0x2a6d20, 0x2a6d28, [0x6a, 0xff, 0x8b], $system_blue, 'toolbar preview gradient 3'],
        [0x2a6d7c, 0x2a6d84, 0x2a6d8c, [0x58, 0xc8, 0x23], $deep_system_blue, 'toolbar preview gradient 4'],
        [0x2a6b74, 0x2a6b7c, 0x2a6b84, [0x1a, 0xc7, 0x85], $deep_blue, 'toolbar preview accent'],
    );
    for my $group (@full_groups) {
        arm_patch_full_group(@$group);
    }

    my @green_groups = (
        [0x235214, 0x23521c, 0x235224, [0x23, 0xc8, 0x91], $system_blue, 'input settings accent'],
        [0x23855c, 0x238564, 0x23856c, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 1'],
        [0x2387c8, 0x2387d0, 0x2387d8, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 2'],
        [0x238d28, 0x238d30, 0x238d38, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 3'],
        [0x2816a4, 0x2816ac, 0x2816b4, [0x23, 0xc8, 0x91], $system_blue, 'about accent'],
        [0x2922a0, 0x2922a8, 0x2922b0, [0x23, 0xc8, 0x91], $system_blue, 'hotword operation accent'],
        [0x29daf0, 0x29daf8, 0x29db00, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 4'],
        [0x2a34a4, 0x2a34ac, 0x2a34b4, [0x23, 0xc8, 0x91], $button_end, 'phone download gradient 2'],
    );
    for my $group (@green_groups) {
        arm_patch_full_group(@$group);
    }

    my @cyan_groups = (
        [0x238508, 0x238510, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 1 start'],
        [0x238738, 0x23873c, [0x00, 0xd4, 0x8e], $button_start, 'multi-device branch preload'],
        [0x238774, 0x23877c, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 2 start'],
        [0x29224c, 0x292254, [0x00, 0xd4, 0x8e], $blue_cyan, 'hotword operation gradient 1'],
        [0x29da9c, 0x29daa4, [0x00, 0xd4, 0x8e], $blue_cyan, 'multi-device gradient 3 start'],
        [0x2a3450, 0x2a3458, [0x00, 0xd4, 0x8e], $button_start, 'phone download gradient 1'],
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
        [0x29adab, 0x29adb2, 0x29adb9, [0x25, 0xce, 0x96], $button_start, 'common button gradient 1'],
        [0x29ae04, 0x29ae0b, 0x29ae12, [0x1f, 0xc3, 0x8d], $button_end, 'common button gradient 2'],
        [0x3003d6, 0x3003dd, 0x3003e4, [0x6a, 0xff, 0xcd], $blue_cyan, 'appearance example gradient 1'],
        [0x300433, 0x30043a, 0x300441, [0x23, 0xc8, 0x91], $deep_blue, 'appearance example gradient 2'],
        [0x3004a8, 0x3004af, 0x3004b6, [0x6a, 0xff, 0x8b], $system_blue, 'appearance example gradient 3'],
        [0x30050a, 0x300511, 0x300518, [0x58, 0xc8, 0x23], $deep_system_blue, 'appearance example gradient 4'],
        [0x320fd0, 0x320fd7, 0x320fde, [0x6a, 0xff, 0xcd], $light_blue, 'phone example gradient 1'],
        [0x32102a, 0x321031, 0x321038, [0x23, 0xc8, 0x91], $deep_blue, 'phone example gradient 2'],
        [0x321098, 0x32109f, 0x3210a6, [0x6a, 0xff, 0x8b], $system_blue, 'phone example gradient 3'],
        [0x3210fa, 0x321101, 0x321108, [0x58, 0xc8, 0x23], $deep_system_blue, 'phone example gradient 4'],
        [0x3252da, 0x3252e1, 0x3252e8, [0x6a, 0xff, 0xcd], $light_blue, 'toolbar preview gradient 1'],
        [0x325334, 0x32533b, 0x325342, [0x23, 0xc8, 0x91], $deep_blue, 'toolbar preview gradient 2'],
        [0x3253a2, 0x3253a9, 0x3253b0, [0x6a, 0xff, 0x8b], $system_blue, 'toolbar preview gradient 3'],
        [0x325404, 0x32540b, 0x325412, [0x58, 0xc8, 0x23], $deep_system_blue, 'toolbar preview gradient 4'],
        [0x3251e4, 0x3251eb, 0x3251f2, [0x1a, 0xc7, 0x85], $deep_blue, 'toolbar preview accent'],
    );
    for my $group (@full_groups) {
        x86_patch_full_group(@$group);
    }

    my @green_groups = (
        [0x30f21e, 0x30f225, 0x30f22c, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 1'],
        [0x31b7b5, 0x31b7bc, 0x31b7c3, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 2'],
        [0x29d736, 0x29d73d, 0x29d744, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 1'],
        [0x2a0e67, 0x2a0e6e, 0x2a0e75, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 2'],
        [0x2a10d2, 0x2a10d9, 0x2a10e0, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 3'],
        [0x2a1693, 0x2a169a, 0x2a16a1, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 4'],
        [0x2fd3d7, 0x2fd3de, 0x2fd3e5, [0x23, 0xc8, 0x91], $system_blue, 'debug accent'],
        [0x3216ce, 0x3216d5, 0x3216dc, [0x23, 0xc8, 0x91], $button_end, 'phone download gradient 2'],
    );
    for my $group (@green_groups) {
        x86_patch_full_group(@$group);
    }

    my @cyan_groups = (
        [0x2a0e15, 0x2a0e1c, [0x00, 0xd4, 0x8e], $blue_cyan, 'settings gradient 1'],
        [0x2a103d, 0x2a1042, [0x00, 0xd4, 0x8e], $blue_cyan, 'settings branch preload'],
        [0x2a1080, 0x2a1087, [0x00, 0xd4, 0x8e], $blue_cyan, 'settings gradient 2'],
        [0x30f1cc, 0x30f1d3, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 1 start'],
        [0x31b763, 0x31b76a, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 2 start'],
        [0x32167c, 0x321683, [0x00, 0xd4, 0x8e], $button_start, 'phone download gradient 1 start'],
    );
    for my $group (@cyan_groups) {
        x86_patch_sparse_group(@$group);
    }
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 637 $arch colors: $path\n";
