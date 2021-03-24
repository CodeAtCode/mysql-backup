# About

This script is based on https://github.com/stevenbraham/mysql-backup and https://github.com/ptillemans/davpush/

## Differences

We cannot use davfs (no fuse available) so this version use cadaver to upload everything.

# How to use

1. Make sure you have all modules installed
2. Rename `config.sample.yaml` to `config.yaml`
3. Fill out `config.yaml` with your information
4. Create a cron or run `backup.pl`

## Required CPAN libraries

* YAML::XS
* DBI
* DBD::mysql

## backup.pl

This one is intended to backup mysql db and the config file include a list of database that will be excluded.

## backup-file.pl

It use `files` parameter in the `config.yaml` where you can define the path where the files need to be backupped every day.  
Instead if you need as example to backup other files `files_others` and run the script with `--others` you can have another subset of files. In this as example you have some files to backup daily and others just weekly, you can use the same script.
