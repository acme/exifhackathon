#!/usr/bin/perl
use strict;
use warnings;
use 5.12.0;
use ElasticSearch;
use File::Slurp;
use JSON::XS;

my $data = decode_json(read_file('exifgrouped.json'));

my $es = ElasticSearch->new();

$es->delete_index(index => 'hackathon', ignore_missing => 1);

foreach my $filename (keys %$data) {
    next if $filename =~ /private/;
    my $exif = $data->{$filename};
    say "* $filename";
    $exif->{Canon_CameraISO} = 0 if $exif->{Canon_CameraISO} eq 'Auto';
    $exif->{Canon_AFPointsInFocus} = 0 if $exif->{Canon_AFPointsInFocus} eq '(none)';
    foreach my $field ('ExifIFD_ExposureCompensation', 'Canon_ExposureCompensation', 'Canon_ExposureTime') {
        $exif->{$field} = eval $exif->{$field};
    }
    if (defined $exif->{Canon_CameraTemperature}) {
      $exif->{Canon_CameraTemperature} =~ s/ C$//;
      my $temperature;
      if ($exif->{Canon_CameraTemperature} <= 24) {
        $temperature = '19to24';
      } elsif ($exif->{Canon_CameraTemperature} <= 28) {
        $temperature = '25to28';
      } else {
        $temperature = '29to34';
      }
      $exif->{temperature} = $temperature;
    }
    if (defined $exif->{Canon_FocusDistanceUpper}) {
      $exif->{Canon_FocusDistanceUpper} =~ s/ m$//;
      my $distance;
      if ($exif->{Canon_FocusDistanceUpper} <= 0.3) {
        $distance = '0to0d3';
      } elsif ($exif->{Canon_FocusDistanceUpper} <= 9) {
        $distance = '0d3to9';
      } else {
        $distance = '10to100';
      }
      $exif->{distance} = $distance;
    }
    if (defined $exif->{Canon_ExposureTime}) {
      my $exposuretime;
      if ($exif->{Canon_ExposureTime} <= 0.01) {
        $exposuretime = 'low';
      } elsif ($exif->{Canon_ExposureTime} <= 0.1) {
        $exposuretime = 'medium';
      } else {
        $exposuretime = 'high';
      }
      $exif->{exposuretime} = $exposuretime;
    }
    if (defined $exif->{GPS_GPSAltitude}) {
      $exif->{GPS_GPSAltitude} =~ s/ m$//;
      my $altitude;
      if ($exif->{GPS_GPSAltitude} <= 10) {
        $altitude = 'low';
      } elsif ($exif->{GPS_GPSAltitude} <= 100) {
        $altitude = 'medium';
      } else {
        $altitude = 'high';
      }
      $exif->{altitude} = $altitude;
    }
    if (defined $exif->{Canon_OpticalZoomCode}) {
      my $zoom;
      if ($exif->{Canon_OpticalZoomCode} <= 0) {
        $zoom = 'low';
      } elsif ($exif->{Canon_OpticalZoomCode} < 120) {
        $zoom = 'medium';
      } else {
        $zoom = 'high';
      }
      $exif->{zoom} = $zoom;
    }
    if (defined $exif->{Canon_SequenceNumber}) {
      my $sequence;
      if ($exif->{Canon_SequenceNumber} <= 1) {
        $sequence = 'low';
      } elsif ($exif->{Canon_SequenceNumber} <= 5) {
        $sequence = 'medium',
      } else {
        $sequence = 'high',
      }
      $exif->{sequence} = $sequence;
    }
    foreach my $field ('Canon_AFPointsInFocus') {
        delete $exif->{$field};
    }
    $es->index(
        index => 'hackathon',
        type  => 'exif',
        id    => $filename,
        data  => $exif,
    );
}

