#!/usr/bin/perl
use strict;
use warnings;
use 5.12.0;
use File::Slurp;
use JSON::XS;
use Text::xSV;

my $data = decode_json(read_file('exifgrouped.json'));

my %fields;
foreach my $filename (keys %$data) {
    my $exif = $data->{$filename};
    say "* $filename";
    foreach my $field (keys %$exif) {
      say "    $field";
      $fields{$field}++;
    }
}

my @fields = sort keys %fields;
my $csv = Text::xSV->new(
    filename => 'exifgrouped.csv',
    header   => ['filename', @fields],
);
$csv->print_header();
foreach my $filename (keys %$data) {
    my $exif = $data->{$filename};
    say "* $filename";
    $csv->print_data(%$exif, filename => $filename);
}

