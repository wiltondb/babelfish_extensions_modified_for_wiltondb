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
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
use File::Copy::Recursive qw(fcopy);
use File::Path qw(make_path remove_tree);
use File::Spec::Functions qw(catfile);

my $root_dir = dirname(abs_path(__FILE__));
my $cmake_gen_name = "Visual Studio 17 2022";
my $cmake_build_type = "RelWithDebInfo";
if (defined($ARGV[0]) && (uc($ARGV[0]) eq 'DEBUG')) {
  $cmake_build_type = "Debug";
}

sub ensure_dir_empty {
  my $dir = shift;
  if (-d $dir) {
    remove_tree($dir) or die("$!");
  }
  make_path($dir) or die("$!");
}

sub build_cmake_project {
  my $src_dir = shift;
  my $src_dir_name = basename($src_dir);
  print("\nBuilding project: [$src_dir_name]\n");
  my $build_dir = catfile($src_dir, "build");
  ensure_dir_empty($build_dir);
  chdir($build_dir);
  my $conf_cmd = "cmake ..";
  $conf_cmd .= " -G \"$cmake_gen_name\"";
  print("$conf_cmd\n");
  0 == system($conf_cmd) or die("$!");
  my $build_cmd = "cmake --build .";
  $build_cmd .= " --config $cmake_build_type";
  print("$build_cmd\n");
  0 == system($build_cmd) or die("$!");
  my $install_cmd = "$build_cmd --target install";
  print("$install_cmd\n");
  0 == system($install_cmd) or die("$!");
}

sub build_system_stats {
  my $src_dir = shift;
  my $src_dir_name = basename($src_dir);
  print("\nBuilding project: [$src_dir_name]\n");
  $ENV{PG_INCLUDE_DIR} = catfile($ENV{PGWIN_INSTALL_DIR}, "include");
  $ENV{PG_LIB_DIR} = catfile($ENV{PGWIN_INSTALL_DIR}, "lib");
  my $conf = "Debug" eq $cmake_build_type ? "Debug" : "Release"; 
  my $build_cmd = "msbuild system_stats.vcxproj";
  $build_cmd .= " /p:Configuration=$conf";
  $build_cmd .= " /p:Platform=x64";
  $build_cmd .= " /p:PlatformToolset=v143";
  print("$build_cmd\n");
  0 == system($build_cmd) or die("$!");
  my $dist_dir = $ENV{PGWIN_INSTALL_DIR};
  my $ext_dir = catfile($dist_dir, "share", "extension");
  fcopy(catfile($src_dir, "x64", $conf, "system_stats.dll"), catfile($dist_dir, "lib", "system_stats.dll")) or die("$!");
  fcopy(catfile($src_dir, "x64", $conf, "system_stats.pdb"), catfile($dist_dir, "symbols", "system_stats.pdb")) or die("$!");
  fcopy(catfile($src_dir, "system_stats.control"), catfile($ext_dir, "system_stats.control")) or die("$!");
  fcopy(catfile($src_dir, "system_stats--1.0.sql"), catfile($ext_dir, "system_stats--1.0.sql")) or die("$!");
  fcopy(catfile($src_dir, "system_stats--1.0--2.0.sql"), catfile($ext_dir, "system_stats--1.0--2.0.sql")) or die("$!");
  fcopy(catfile($src_dir, "system_stats--2.0.sql"), catfile($ext_dir, "system_stats--2.0.sql")) or die("$!");
}

my $parent_dir = dirname($root_dir);
my $contrib_dir = catfile($root_dir, "contrib");
my $pg_hint_plan_dir = catfile($parent_dir, "pg_hint_plan");
my $tds_fdw_dir = catfile($parent_dir, "tds_fdw");
my $system_stats_dir = catfile($parent_dir, "system_stats");
print("Cleaning up repos\n");
chdir($contrib_dir);
0 == system("git clean -dxf") or die("$!");
0 == system("git status") or die("$!");

build_cmake_project(catfile($contrib_dir, "babelfishpg_money"));
build_cmake_project(catfile($contrib_dir, "babelfishpg_common"));
build_cmake_project(catfile($contrib_dir, "babelfishpg_tds"));
build_cmake_project(catfile($contrib_dir, "babelfishpg_tsql"));

chdir($pg_hint_plan_dir);
0 == system("git clean -dxf") or die("$!");
0 == system("git status") or die("$!");
build_cmake_project($pg_hint_plan_dir);

chdir($tds_fdw_dir);
0 == system("git clean -dxf") or die("$!");
0 == system("git status") or die("$!");
build_cmake_project($tds_fdw_dir);

chdir($system_stats_dir);
0 == system("git clean -dxf") or die("$!");
0 == system("git status") or die("$!");
build_system_stats($system_stats_dir);

chdir($root_dir);
print("Build complete successfully\n");