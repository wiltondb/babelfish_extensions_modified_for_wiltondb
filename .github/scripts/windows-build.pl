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
use Archive::Extract;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Copy::Recursive qw(dircopy);
use File::Path qw(make_path remove_tree);
use File::Spec::Functions qw(catfile);
use LWP::Simple qw(getstore);

my $pg_tag = "WILTON_3_LTS-13";
my $pg_hint_plan_tag = "REL15_1_5_1_WILTON";
my $tds_fdw_tag = "v2.0.3-wilton";
my $system_stats_tag = "v2.1";
my $pgagent_tag = "wilton";
my $pgwin_deps_version = "2024_09_26-1";
my $flexbison_version = "flex-2.6.4_bison-3.8.2-1";
my $diff_version = "v3.6-1";

my $parent_dir = dirname(dirname(dirname(dirname(abs_path(__FILE__)))));

sub ensure_dir_empty {
  my $dir = shift;
  if (-d $dir) {
    remove_tree($dir) or die("$!");
  }
  make_path($dir) or die("$!");
}

sub download_pgwin_deps {
  my $url = "https://github.com/wiltondb/pgwin_deps/releases/download/$pgwin_deps_version/pgwin_deps-$pgwin_deps_version.zip";
  my $zip = catfile($parent_dir, "pgwin_deps-$pgwin_deps_version.zip");
  print("Downloading file, url: [$url]\n");
  getstore($url, $zip) or die("$!");
  print("Unpacking file: [$zip]\n");
  my $ae = Archive::Extract->new(archive => $zip);
  $ae->extract(to => $parent_dir) or die("$!");
  my $dir_name = $ae->files->[0];
  return catfile($parent_dir, $dir_name);
}

sub download_flexbison {
  my $tools_dir = shift;
  chdir($tools_dir);
  my $url = "https://github.com/wiltondb/winflexbison/releases/download/$flexbison_version/$flexbison_version.zip";
  my $zip = catfile($tools_dir, "$flexbison_version.zip");
  print("Downloading file, url: [$url]\n");
  getstore($url, $zip) or die("$!");
  print("Unpacking file: [$zip]\n");
  my $ae = Archive::Extract->new(archive => $zip);
  $ae->extract(to => $tools_dir) or die("$!");
  my $dir_name = $ae->files->[0];
  return catfile($tools_dir, $dir_name);
}

sub download_diff {
  my $tools_dir = shift;
  chdir($tools_dir);
  my $url = "https://github.com/wiltondb/diffutils_win/releases/download/$diff_version/diff.exe";
  my $dir = catfile($tools_dir, "diff");
  ensure_dir_empty($dir);
  my $dest = catfile($dir, "diff.exe");
  print("Downloading file, url: [$url]\n");
  getstore($url, $dest) or die("$!");
  return $dir;
}

sub download_pg_hint_plan {
  my $extension_dir = shift;
  chdir($extension_dir);
  my $url = "https://github.com/wiltondb/pg_hint_plan.git";
  0 == system("git clone --quiet --branch $pg_hint_plan_tag $url") or die("$!");
}

sub download_tds_fdw {
  my $extension_dir = shift;
  chdir($extension_dir);
  my $url = "https://github.com/wiltondb/tds_fdw.git";
  0 == system("git clone --quiet --branch $tds_fdw_tag $url") or die("$!");
}

sub download_system_stats {
  my $extension_dir = shift;
  chdir($extension_dir);
  my $url = "https://github.com/EnterpriseDB/system_stats.git";
  0 == system("git clone --quiet --branch $system_stats_tag $url") or die("$!");
}

sub download_pgagent {
  my $extension_dir = shift;
  chdir($extension_dir);
  my $url = "https://github.com/wiltondb/pgagent.git";
  0 == system("git clone --quiet --branch $pgagent_tag $url") or die("$!");
}

sub download_and_build_pg {
  chdir($parent_dir);
  my $url = "https://github.com/wiltondb/postgresql_modified_for_babelfish.git";
  0 == system("git clone --quiet --branch $pg_tag $url") or die("$!");
  my $pg_src_dir = catfile($parent_dir, "postgresql_modified_for_babelfish");
  chdir(catfile($pg_src_dir, "src", "tools", "msvc")) or die("$!");
  0 == system("build.bat") or die("$!");
  0 == system("vcregress.bat check") or die("$!");
  my $dist_dir = catfile($parent_dir, "dist");
  0 == system("install.bat $dist_dir") or die("$!");
  return ($pg_src_dir, $dist_dir);
}

sub build_extensions {
  my $bbf_dir = catfile($parent_dir, "babelfish_extensions");
  chdir($bbf_dir);
  0 == system("perl build.pl") or die("$!");
  return $bbf_dir;
}

sub run_jdbc_tests {
  chdir(catfile($parent_dir, "babelfish_extensions", "test", "JDBC"));
  delete $ENV{PGBIN};
  delete $ENV{PGROOT};
  delete $ENV{PGDATA};
  $ENV{JAVA_HOME} = $ENV{JAVA_HOME_11_X64};
  system("perl run_tests.pl");
}

my $pgwin_deps_dir = download_pgwin_deps();
$ENV{PGWIN_DEPS_DIR} = "$pgwin_deps_dir/release-icu73";

my $tools_dir = catfile($parent_dir, "tools");
ensure_dir_empty($tools_dir);
my $flexbison_dir = download_flexbison($tools_dir);
$ENV{PATH} = "$flexbison_dir;$ENV{PATH}";
my $diff_dir = download_diff($tools_dir);
$ENV{PATH} = "$diff_dir;$ENV{PATH}";

my $extensions_dir = catfile($parent_dir, "extensions");
ensure_dir_empty($extensions_dir);
download_pg_hint_plan($extensions_dir);
download_tds_fdw($extensions_dir);
download_system_stats($extensions_dir);
download_pgagent($extensions_dir);

my ($pg_src_dir, $dist_dir) = download_and_build_pg();
$ENV{PGWIN_SRC_DIR} = $pg_src_dir;
$ENV{PGWIN_INSTALL_DIR} = $dist_dir;
$ENV{ANTLR4_JAVA_BIN} = "$ENV{JAVA_HOME_11_X64}/bin/java.exe";
my $bbf_dir = build_extensions();
dircopy($dist_dir, catfile($bbf_dir, "dist"));
run_jdbc_tests();
