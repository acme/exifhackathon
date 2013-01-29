#!/usr/bin/perl
use strict;
use warnings;
use 5.12.0;
use File::Slurp;
use JSON::XS;
use Text::xSV;

my $exif = decode_json(read_file('exif.json'));

my %exifgroupeds;
foreach my $exifbit (@$exif) {
  my $exifgrouped;
  my $filename;
  foreach my $group (keys %$exifbit) {
    #say $field;
    my $groupvalue = $exifbit->{$group};
    if (ref($groupvalue)) {
      say "> $group";
      foreach my $field (keys %$groupvalue) {
        my $fieldvalue = $groupvalue->{$field};
        say "    $field";
        $exifgrouped->{"${group}_$field"} = $fieldvalue;
      }
    } else {
      say "* $group $groupvalue";
      $groupvalue =~ s{^.+/}{};
      $filename = $groupvalue;
      $exifgrouped->{$group} = $groupvalue;
    }
  }
  $exifgroupeds{$filename} = $exifgrouped;
}

write_file('exifgrouped.json', encode_json(\%exifgroupeds));

