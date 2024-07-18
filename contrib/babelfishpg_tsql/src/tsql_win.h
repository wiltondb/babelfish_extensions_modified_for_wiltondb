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

#ifndef TSQL_WIN_H
#define TSQL_WIN_H

#include "pltsql.h"
#include "pltsql-2.h"
#include "pl_explain.h"
#include "session.h"

#include "catalog/namespace.h"
#include "catalog/pg_proc.h"
#include "parser/scansup.h"

#include "guc.h"

#include "regex/regex.h"

#define strncasecmp _strnicmp

List* list_make1_win(void* ptr);

char *strcasestr(const char *haystack, const char *needle);

int regexec_win(const char *regex, const char *string, size_t nmatch,
            regmatch_t pmatch[], int eflags);

void debuginfo_init();

void debuginfo_shutdown();

char* debuginfo_get_current_call_stack();

#endif // TSQL_WIN_H 