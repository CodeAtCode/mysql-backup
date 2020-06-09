#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use YAML::XS 'LoadFile';
use DBI;
use POSIX 'strftime';
use File::Find;
no warnings 'experimental::smartmatch';

#read values from config.yaml
my $config = LoadFile('config.yaml');
my $webdavUrl = $config->{webdav}->{url};
my $webdavUsername = $config->{webdav}->{username};
my $webdavPassword = $config->{webdav}->{password};
my $backupDir = $config->{webdav}->{backupDir};
my @fileList = $config->{files};

my $filestoupload = "";
my $pid = "";
my $folder = POSIX::strftime('%Y/%m/%d', localtime);
#clear ouput folder
`rm -rf $folder && mkdir -p $folder`;

sub wanted() {
  my $f = $File::Find::name;
  if (-f $f) {
    $filestoupload .= "put $f\n";
  } else {
    $filestoupload .= "cd " . $backupDir."\n";
    $filestoupload .= "mkdir " . POSIX::strftime('%Y', localtime) . "\n";
    $filestoupload .= "mkdir " . POSIX::strftime('%Y', localtime) . '/' . POSIX::strftime('%m', localtime) . "\n";
    $filestoupload .= "mkdir " . $folder . "\n";
    $filestoupload .= "cd $folder\n";
  }
}

foreach my $backupme ( @{$config->{files}} ) {
    `cp $backupme $folder`;
}

# write to temp file to pipe username/password to mount
open (OUTFILE, '>>/root/.netrc');
print OUTFILE "default\nlogin $webdavUsername\npasswd $webdavPassword";
close (OUTFILE);
find({'wanted'=>\&wanted, 'no_chdir' => 1},   "$folder/");
$pid = open(POUT, "| cadaver $webdavUrl");
sleep('2');
print POUT $filestoupload;
print POUT "bye\n";
close POUT;
unlink('/root/.netrc');

my $year = POSIX::strftime('%Y', localtime);
sleep('100');
`rm -rf $year`;
