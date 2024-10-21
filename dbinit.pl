# Copyright 2023 alex@staticlibs.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use Cwd qw(abs_path cwd);
use File::Basename qw(dirname);
use File::Path qw(make_path remove_tree);
use File::Slurp qw(append_file edit_file);
use File::Spec::Functions qw(catfile);

sub runcmd {
  my $cmd = shift;
  my $best_effort = shift;
  print("$cmd\n");
  if (!$best_effort) {
    0 == system($cmd) or die("$!");
  } else {
    system($cmd);
  }
}

if (!(defined $ENV{PGWIN_INSTALL_DIR})) {
  die("Environment variable 'PGWIN_INSTALL_DIR' (pointing to the postgresql_modified_for_babelfish installation directory) must be specified");
}

my $pg_ctl = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "pg_ctl.exe");
my $initdb = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "initdb.exe");
my $postgres = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "postgres.exe");
my $psql = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "psql.exe");
my $pg_data = catfile($ENV{PGWIN_INSTALL_DIR}, "data");
my $pg_hba_conf = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "pg_hba.conf");
my $pg_log_dir = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "log");
my $pg_log = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "log", "postgresql.log");
my $postmaster_pid = catfile($ENV{PGWIN_INSTALL_DIR}, "data", "postmaster.pid");
my $openssl = catfile($ENV{PGWIN_INSTALL_DIR}, "bin", "openssl.exe");
my $openssl_cnf = catfile($ENV{PGWIN_INSTALL_DIR}, "share", "openssl.cnf");

runcmd("$pg_ctl stop -D $pg_data", "best effort");
remove_tree($pg_data);
runcmd("$initdb -D $pg_data -E UTF8 --locale C");

my $cwd_dir = cwd();
chdir($pg_data);
runcmd("$openssl req -config $openssl_cnf -new -x509 -days 3650 -nodes -text -out server.crt -keyout server.key -subj \"/CN=localhost\"");
chdir($cwd_dir);

make_path($pg_log_dir);
runcmd("$pg_ctl start -D $pg_data -l $pg_log");

runcmd("$psql -U $ENV{USERNAME} -d postgres -c \"ALTER SYSTEM SET max_connections = 256;\"");
runcmd("$psql -U $ENV{USERNAME} -d postgres -c \"ALTER SYSTEM SET ssl = ON;\"");
runcmd("$psql -U $ENV{USERNAME} -d postgres -c \"ALTER SYSTEM SET shared_preload_libraries = 'babelfishpg_tds','pg_stat_statements','system_stats';\"");
runcmd("$psql -U $ENV{USERNAME} -d postgres -c \"ALTER SYSTEM SET listen_addresses = '*';\"");
runcmd("$psql -U $ENV{USERNAME} -d postgres -c \"CREATE USER wilton WITH SUPERUSER CREATEDB CREATEROLE PASSWORD 'wilton' INHERIT;\"");
runcmd("$psql -U $ENV{USERNAME} -d postgres -c \"CREATE DATABASE wilton OWNER wilton;\"");

edit_file(sub { s/trust/md5/g }, $pg_hba_conf);
edit_file(sub { s/127.0.0.1\/32/0.0.0.0\/0/g }, $pg_hba_conf);
edit_file(sub { s/::1\/128/::0\/0/g }, $pg_hba_conf);
runcmd("$pg_ctl restart -D $pg_data -l $pg_log");

$ENV{PGPASSWORD} = "wilton";
runcmd("$psql -U wilton -c \"CREATE EXTENSION IF NOT EXISTS babelfishpg_tds CASCADE;\"");
runcmd("$psql -U wilton -c \"GRANT ALL ON SCHEMA sys to wilton;\"");
runcmd("$psql -U wilton -c \"ALTER SYSTEM SET babelfishpg_tsql.database_name = 'wilton';\"");
runcmd("$psql -U wilton -c \"ALTER DATABASE wilton SET babelfishpg_tsql.migration_mode = 'multi-db';\"");
runcmd("$psql -U wilton -c \"SELECT pg_reload_conf();\"");
runcmd("$psql -U wilton -c \"CALL sys.initialize_babelfish('wilton');\"");

runcmd("$pg_ctl stop -D $pg_data -l $pg_log");

print("\nDB cluster initialized, to start the server run:\n$postgres -D $pg_data\nor\n$pg_ctl start -D $pg_data -l $pg_log\n");
