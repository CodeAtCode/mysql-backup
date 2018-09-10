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
my $mysqlUsername = $config->{mysql}->{username};
my $mysqlPassword = $config->{mysql}->{password};
my $blacklist = $config->{blacklist};

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
    $filestoupload .= "cd $folder\n"
  }
}

#connect to mysql
my $connection = DBI->connect("DBI:mysql:information_schema:localhost:", $mysqlUsername, $mysqlPassword);
my $sql = $connection->prepare("show databases");
$sql->execute();

#loop over databases and execute dump command
while ((my $databaseName) = $sql->fetchrow_array()){
    if (not $databaseName ~~ $blacklist) {
        #use smartwatch to exclude items from blacklist
        print $databaseName." backup done!\n";
        #run dump command
        `mysqldump --force --opt --user=$mysqlUsername --password=$mysqlPassword --databases $databaseName > $folder/$databaseName.sql`;
        # gzip
        `gzip -f $folder/$databaseName.sql`;
        `rm -f $folder/$databaseName.sql`;
    }
}

# write to temp file to pipe username/password to mount
open (OUTFILE, '>>/root/.netrc');
print OUTFILE "default\nlogin $webdavUsername\npasswd $webdavPassword";
close (OUTFILE);

find({'wanted'=>\&wanted, 'no_chdir' => 1},   "$folder/");
$pid = open(POUT, "| cadaver $webdavUrl");
sleep('3');
print POUT $filestoupload;
print POUT "bye\n";
unlink('/root/.netrc');

my $year = POSIX::strftime('%Y', localtime);
sleep('100');
`rm -rf $year`;
