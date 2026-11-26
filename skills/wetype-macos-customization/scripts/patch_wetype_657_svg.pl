#!/usr/bin/env perl
use strict;
use warnings;
use File::Find qw(find);

my ($root) = @ARGV;
die "usage: patch_wetype_657_svg.pl FLUTTER_ASSETS_ROOT\n" unless $root;

my %replacements = (
    '#2AE59F' => '#FFA9CA',
    '#23C891' => '#D92D70',
    '#00B176' => '#D92D70',
    '#1AC785' => '#F46D9C',
);
my %expected = (
    '#2AE59F' => 4,
    '#23C891' => 11,
    '#00B176' => 2,
    '#1AC785' => 2,
);
my %target_expected;
for my $old (keys %replacements) {
    $target_expected{$replacements{$old}} += $expected{$old};
}
my %seen;
my %changed;
my %target_seen;

find({
    no_chdir => 1,
    wanted => sub {
        return unless -f $_ && /\.svg\z/;
        my $path = $File::Find::name;
        open my $fh, '+<:raw', $path or die "$path: $!\n";
        local $/;
        my $data = <$fh>;
        my $original = $data;

        for my $old (sort keys %replacements) {
            my $count = () = $data =~ /\Q$old\E/g;
            next unless $count;
            $seen{$old} += $count;
            my $new = $replacements{$old};
            $data =~ s/\Q$old\E/$new/g;
            $changed{$old} += $count;
        }
        for my $target (sort keys %target_expected) {
            my $count = () = $data =~ /\Q$target\E/g;
            $target_seen{$target} += $count;
        }
        return if $data eq $original;

        seek $fh, 0, 0 or die "$path: seek failed: $!\n";
        print {$fh} $data or die "$path: write failed: $!\n";
        truncate $fh, length($data) or die "$path: truncate failed: $!\n";
        close $fh or die "$path: close failed: $!\n";
        print "patched SVG colors: $path\n";
    },
}, $root);

for my $old (sort keys %replacements) {
    my $old_count = $seen{$old} // 0;
    my $target = $replacements{$old};
    if ($old_count == $expected{$old}) {
        print "$old -> $target: $old_count occurrence(s)\n";
        next;
    }
    next if $old_count == 0;
    die "$root: expected $expected{$old} $old SVG color(s), found $old_count\n";
}

for my $target (sort keys %target_expected) {
    my $actual = $target_seen{$target} // 0;
    my $expected_count = $target_expected{$target};
    die "$root: expected $expected_count $target SVG color(s), found $actual\n"
        unless $actual == $expected_count;
    print "$target target: $actual occurrence(s)\n";
}
