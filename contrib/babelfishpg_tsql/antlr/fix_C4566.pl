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
use File::Slurp qw(edit_file write_file);

my $stamp_file = "C4566_fix_applied.txt";

if ( -f $stamp_file ) {
  exit(0);
}

# https://stackoverflow.com/a/12040593
edit_file(sub { s/[^8]("'\\u200B'"|"'\\u202F'"|"'\\u3000'")/u8$1/g }, "TSqlLexer/TSqlLexer.cpp");
edit_file(sub { s/[^8]("'\\u200B'"|"'\\u202F'"|"'\\u3000'")/u8$1/g }, "TSqlParser/TSqlParser.cpp");

write_file($stamp_file, "stamp");