#!/usr/bin/env perl
use strict;
use warnings;

my ($arch, $path) = @ARGV;
die "usage: patch_wetype_684_colors.pl arm64|x86_64 THIN_APP_FRAMEWORK_FILE\n"
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
# other settings surfaces. These byte sequences are stable within the 684 AOT.
my @snapshot_patches = $arch eq 'arm64'
    ? (
        [0x4eb60b, '11110fb9c0', '7f7501b8c0', 'static palette root'],
        [0x4eb610, '6f5002b8', '7f7501b8', 'static palette variant 1'],
        [0x4eb61f, '766202b8', '7f6317bf', 'static palette variant 2'],
        [0x4eb538, '0e2903b8', '7f7501b8', 'static palette variant 3'],
        [0x4eb582, '66585ab8', '7f7501b8', 'static palette variant 4'],
        [0x4eb624, '706f23bf', '7f6317bf', 'static palette variant 5'],
    )
    : (
        [0x525af8, '11110fb9c0', '7f7501b8c0', 'static palette root'],
        [0x525afd, '6f5002b8', '7f7501b8', 'static palette variant 1'],
        [0x525b0c, '766202b8', '7f6317bf', 'static palette variant 2'],
        [0x525a25, '0e2903b8', '7f7501b8', 'static palette variant 3'],
        [0x525a6f, '66585ab8', '7f7501b8', 'static palette variant 4'],
        [0x525b11, '706f23bf', '7f6317bf', 'static palette variant 5'],
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
        [0x20c684, 0x20c68c, 0x20c694, [0x25, 0xce, 0x96], $button_start, 'common button gradient 1'],
        [0x20c6e0, 0x20c6e8, 0x20c6f0, [0x1f, 0xc3, 0x8d], $button_end, 'common button gradient 2'],
        [0x27b3d4, 0x27b3dc, 0x27b3e4, [0x6a, 0xff, 0xcd], $blue_cyan, 'appearance example gradient 1'],
        [0x27b434, 0x27b43c, 0x27b444, [0x23, 0xc8, 0x91], $deep_blue, 'appearance example gradient 2'],
        [0x27b4a8, 0x27b4b0, 0x27b4b8, [0x6a, 0xff, 0x8b], $system_blue, 'appearance example gradient 3'],
        [0x27b50c, 0x27b514, 0x27b51c, [0x58, 0xc8, 0x23], $deep_system_blue, 'appearance example gradient 4'],
        [0x29a494, 0x29a49c, 0x29a4a4, [0x6a, 0xff, 0xcd], $light_blue, 'phone example gradient 1'],
        [0x29a4f0, 0x29a4f8, 0x29a500, [0x23, 0xc8, 0x91], $deep_blue, 'phone example gradient 2'],
        [0x29a55c, 0x29a564, 0x29a56c, [0x6a, 0xff, 0x8b], $system_blue, 'phone example gradient 3'],
        [0x29a5c0, 0x29a5c8, 0x29a5d0, [0x58, 0xc8, 0x23], $deep_system_blue, 'phone example gradient 4'],
        [0x29e4a8, 0x29e4b0, 0x29e4b8, [0x6a, 0xff, 0xcd], $light_blue, 'toolbar preview gradient 1'],
        [0x29e508, 0x29e510, 0x29e518, [0x23, 0xc8, 0x91], $deep_blue, 'toolbar preview gradient 2'],
        [0x29e57c, 0x29e584, 0x29e58c, [0x6a, 0xff, 0x8b], $system_blue, 'toolbar preview gradient 3'],
        [0x29e5e0, 0x29e5e8, 0x29e5f0, [0x58, 0xc8, 0x23], $deep_system_blue, 'toolbar preview gradient 4'],
    );
    for my $group (@full_groups) {
        arm_patch_full_group(@$group);
    }

    my @green_groups = (
        [0x20ec98, 0x20eca0, 0x20eca8, [0x23, 0xc8, 0x91], $system_blue, 'input settings accent'],
        [0x212ec8, 0x212ed0, 0x212ed8, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 1 end'],
        [0x213134, 0x21313c, 0x213144, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 2 end'],
        [0x213694, 0x21369c, 0x2136a4, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 3'],
        [0x2785e8, 0x2785f0, 0x2785f8, [0x23, 0xc8, 0x91], $system_blue, 'about accent'],
        [0x2895e4, 0x2895ec, 0x2895f4, [0x23, 0xc8, 0x91], $system_blue, 'hotword operation accent'],
        [0x295028, 0x295030, 0x295038, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 4'],
        [0x29ab38, 0x29ab40, 0x29ab48, [0x23, 0xc8, 0x91], $button_end, 'phone download gradient 2'],
    );
    for my $group (@green_groups) {
        arm_patch_full_group(@$group);
    }

    my @cyan_groups = (
        [0x212e74, 0x212e7c, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 1 start'],
        [0x2130e0, 0x2130e8, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 2 start'],
        [0x289590, 0x289598, [0x00, 0xd4, 0x8e], $blue_cyan, 'hotword operation gradient 1'],
        [0x294fd4, 0x294fdc, [0x00, 0xd4, 0x8e], $blue_cyan, 'multi-device gradient 3 start'],
        [0x29aae4, 0x29aaec, [0x00, 0xd4, 0x8e], $button_start, 'phone download gradient 1'],
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
        [0x28ba63, 0x28ba6a, 0x28ba71, [0x25, 0xce, 0x96], $button_start, 'common button gradient 1'],
        [0x28babc, 0x28bac3, 0x28baca, [0x1f, 0xc3, 0x8d], $button_end, 'common button gradient 2'],
        [0x30b893, 0x30b89a, 0x30b8a1, [0x6a, 0xff, 0xcd], $blue_cyan, 'appearance example gradient 1'],
        [0x30b8f0, 0x30b8f7, 0x30b8fe, [0x23, 0xc8, 0x91], $deep_blue, 'appearance example gradient 2'],
        [0x30b965, 0x30b96c, 0x30b973, [0x6a, 0xff, 0x8b], $system_blue, 'appearance example gradient 3'],
        [0x30b9c7, 0x30b9ce, 0x30b9d5, [0x58, 0xc8, 0x23], $deep_system_blue, 'appearance example gradient 4'],
        [0x32cc80, 0x32cc87, 0x32cc8e, [0x6a, 0xff, 0xcd], $light_blue, 'phone example gradient 1'],
        [0x32ccda, 0x32cce1, 0x32cce8, [0x23, 0xc8, 0x91], $deep_blue, 'phone example gradient 2'],
        [0x32cd48, 0x32cd4f, 0x32cd56, [0x6a, 0xff, 0x8b], $system_blue, 'phone example gradient 3'],
        [0x32cdaa, 0x32cdb1, 0x32cdb8, [0x58, 0xc8, 0x23], $deep_system_blue, 'phone example gradient 4'],
        [0x33115e, 0x331165, 0x33116c, [0x6a, 0xff, 0xcd], $light_blue, 'toolbar preview gradient 1'],
        [0x3311bb, 0x3311c2, 0x3311c9, [0x23, 0xc8, 0x91], $deep_blue, 'toolbar preview gradient 2'],
        [0x331230, 0x331237, 0x33123e, [0x6a, 0xff, 0x8b], $system_blue, 'toolbar preview gradient 3'],
        [0x331292, 0x331299, 0x3312a0, [0x58, 0xc8, 0x23], $deep_system_blue, 'toolbar preview gradient 4'],
    );
    for my $group (@full_groups) {
        x86_patch_full_group(@$group);
    }

    my @green_groups = (
        [0x28e3ea, 0x28e3f1, 0x28e3f8, [0x23, 0xc8, 0x91], $system_blue, 'input settings accent'],
        [0x292aac, 0x292ab3, 0x292aba, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 1 end'],
        [0x292d17, 0x292d1e, 0x292d25, [0x23, 0xc8, 0x91], $button_end, 'multi-device gradient 2 end'],
        [0x2932d8, 0x2932df, 0x2932e6, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 3'],
        [0x3087bb, 0x3087c2, 0x3087c9, [0x23, 0xc8, 0x91], $system_blue, 'debug accent'],
        [0x31aac6, 0x31aacd, 0x31aad4, [0x23, 0xc8, 0x91], $system_blue, 'hotword operation accent'],
        [0x327291, 0x327298, 0x32729f, [0x23, 0xc8, 0x91], $system_blue, 'multi-device accent 4'],
        [0x32d37e, 0x32d385, 0x32d38c, [0x23, 0xc8, 0x91], $button_end, 'phone download gradient 2'],
    );
    for my $group (@green_groups) {
        x86_patch_full_group(@$group);
    }

    my @cyan_groups = (
        [0x292a5a, 0x292a61, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 1 start'],
        [0x292cc5, 0x292ccc, [0x00, 0xd4, 0x8e], $button_start, 'multi-device gradient 2 start'],
        [0x31aa74, 0x31aa7b, [0x00, 0xd4, 0x8e], $blue_cyan, 'hotword operation gradient 1'],
        [0x32723f, 0x327246, [0x00, 0xd4, 0x8e], $blue_cyan, 'multi-device gradient 3 start'],
        [0x32d32c, 0x32d333, [0x00, 0xd4, 0x8e], $button_start, 'phone download gradient 1'],
    );
    for my $group (@cyan_groups) {
        x86_patch_sparse_group(@$group);
    }
}

seek $fh, 0, 0 or die "$path: seek failed: $!\n";
print {$fh} $data or die "$path: write failed: $!\n";
truncate $fh, length($data) or die "$path: truncate failed: $!\n";
close $fh or die "$path: close failed: $!\n";
print "patched 684 $arch colors: $path\n";
