/*
 * Copyright 2023 alex@staticlibs.net
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define fstat microsoft_native_fstat
#define stat microsoft_native_stat

#include <regex>

// override the global new and delete operators
#include "mimalloc-new-delete.h"

extern "C" {
  #include "src/tsql_win.h"
}

int regexec_win(const char *regex, const char *string, size_t nmatch,
            regmatch_t pmatch[], int eflags) {
  auto rx = std::regex(regex);
  auto cm = std::cmatch();
  std::regex_search(string, cm, rx);
  if (cm.empty()) {
    return 1;
  }
  pmatch[0].rm_so = cm[0].first - string;
  pmatch[0].rm_eo = cm[0].second - string;

  return 0;
}