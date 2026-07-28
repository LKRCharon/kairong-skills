#!/usr/bin/env perl
use strict;
use warnings;
use File::Find qw(find);

my ($root) = @ARGV;
die "usage: patch_wetype_637_svg.pl FLUTTER_ASSETS_ROOT\n" unless $root;

my %replacements = (
    '#2AE59F' => '#64D2FF',
    '#23C891' => '#007AFF',
    '#00B176' => '#007AFF',
);
my %seen;
my %changed;

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
        return if $data eq $original;

        seek $fh, 0, 0 or die "$path: seek failed: $!\n";
        print {$fh} $data or die "$path: write failed: $!\n";
        truncate $fh, length($data) or die "$path: truncate failed: $!\n";
        close $fh or die "$path: close failed: $!\n";
        print "patched SVG colors: $path\n";
    },
}, $root);

for my $old (sort keys %replacements) {
    die "$root: expected at least one $old SVG color\n"
        unless ($seen{$old} // 0) > 0;
    print "$old -> $replacements{$old}: $seen{$old} occurrence(s)\n";
}
