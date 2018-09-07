# About

This script is based on https://github.com/stevenbraham/mysql-backup and https://github.com/ptillemans/davpush/

# Differences

We cannot use davfs (no fuse available) so this version use cadaver to upload everything.

# How to use
*(I take no responsibility if you use my script and something goes wrong)*

1. Make sure you have all modules installed
2. Rename `config.sample.yaml` to `config.yaml`
3. Fill out `config.yaml` with your information
4. Create a cron or run `backup.pl`

# Required CPAN libraries

* YAML::XS
* DBI
* DBD::mysql