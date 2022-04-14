#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use YAML::XS 'LoadFile';
use DBI;
use POSIX 'strftime';
use File::Find;
no warnings 'experimental::smartmatch';
use DateTime;

#read values from config.yaml
my $config = LoadFile('config.yaml');
my $webdavUrl = $config->{webdav}->{url};
my $webdavUsername = $config->{webdav}->{username};
my $webdavPassword = $config->{webdav}->{password};
my $backupDir = $config->{webdav}->{backupDir};
my @fileList = $config->{files};
my $filesave = $config->{file_dest}->{save};

my $filestoupload = "";
my $pid = "";
my $folder = POSIX::strftime('%Y/%m/%d', localtime());
#clear ouput folder
`rm -rf $folder && mkdir -p $folder`;

sub wanted() {
  my $f = $File::Find::name;
}

foreach my $backupme ( @{$config->{files}} ) {
    `cp -fr $backupme ./$folder/`;
}

# write to temp file to pipe username/password to mount
open (OUTFILE, '>>/root/.netrc');
print OUTFILE "default\nlogin $webdavUsername\npasswd $webdavPassword";
close (OUTFILE);
`tar -zcvf $filesave ./$folder/`;
`rm -fr ./$folder/*`;
`mv $filesave ./$folder/`;
$filestoupload .= "open $webdavUrl\n";
$filestoupload .= "cd " . $backupDir."\n";
$filestoupload .= "mkdir " . POSIX::strftime('%Y', localtime()) . "\n";
$filestoupload .= "mkdir " . POSIX::strftime('%Y', localtime()) . '/' . POSIX::strftime('%m', localtime()) . "\n";
$filestoupload .= "mkdir " . $folder . "\n";
$filestoupload .= "cd $folder\n";
$filestoupload .= "put $folder/$filesave\n";
$filestoupload .= "bye\n";
$filestoupload .= "quit";
open (OUTFILE, '>>/root/.cadaverrc');
print OUTFILE "$filestoupload\n";
close (OUTFILE);
$pid = open(POUT, '| expect -c "set timeout -1; spawn cadaver --rcfile="/root/.cadaverrc"; sleep 1; send "y\\\n"; expect eof"');
close POUT;

print " Upload done!\n";
my $year = POSIX::strftime('%Y', localtime);
sleep('60');
`rm -rf $year`;

unlink('/root/.netrc');
unlink('/root/.cadaverrc');
