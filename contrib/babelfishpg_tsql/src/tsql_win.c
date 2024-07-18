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

#include "src/tsql_win.h"

#include <dbghelp.h>
#include <pathcch.h>
#include <shlwapi.h>

#define MAX_FRAMES 1024

HANDLE sym_handle = NULL;

List* list_make1_win(void* ptr)
{
  return list_make1(ptr);
}

char *strcasestr(const char *haystack, const char *needle)
{
  return StrStrIA(haystack, needle);
}

void debuginfo_init()
{
  StringInfoData path_buf;
  DWORD path_size;
  DWORD last_err;
  int i;
  HRESULT path_status;
  BOOL sym_status;

  initStringInfo(&path_buf);
  for (i = 0; i < 16; i++)
  {
    path_size = GetModuleFileNameW(NULL, (LPWSTR) path_buf.data, (path_buf.maxlen / 2) - 1);
    last_err = GetLastError();
    if (ERROR_SUCCESS == last_err && (path_size * 2) < path_buf.maxlen)
    {
      path_buf.len = path_size * 2;
      break;
    }
    if (ERROR_INSUFFICIENT_BUFFER == last_err)
      enlargeStringInfo(&path_buf, path_buf.maxlen / 2);
    else
    {
      path_buf.len = 0;
      break;
    }
  }
  if (path_buf.len == 0)
  {
    elog(WARNING, "GetModuleFileName call failed, status: 0x%08x", last_err);
    pfree(path_buf.data);
    return;
  }
    
  path_status = PathCchRemoveFileSpec((PWSTR) path_buf.data, path_buf.len / 2);
  if (path_status != S_OK)
  {
    elog(WARNING, "PathCchRemoveFileSpec call failed, status: 0x%08x", path_status);
    pfree(path_buf.data);
    return;
  }

  path_status = PathCchCombineEx(
    (PWSTR) path_buf.data, // pszPathOut
    (path_buf.maxlen / 2) - 1, // cchPathOut
    (PWSTR) path_buf.data, // pszPathIn
    L"..\\symbols", // pszMore
    PATHCCH_ALLOW_LONG_PATHS // dwFlags
  );
  if (path_status != S_OK)
  {
    elog(WARNING, "PathCchCombine call failed, status: 0x%08x", path_status);
    pfree(path_buf.data);
    return;
  }

  if (PathFileExistsW((LPCWSTR) path_buf.data))
  {
    sym_handle = GetCurrentProcess();
    sym_status = SymInitializeW(sym_handle, (PCWSTR) path_buf.data, TRUE);
    if (!sym_status)
    {
      elog(WARNING, "SymInitialize call failed, status: 0x%08x", GetLastError());
      pfree(path_buf.data);
      return;
    }

    elog(LOG, "DebugInfo initialized successfully using 'symbols' directory");
  }

  pfree(path_buf.data);
}

void debuginfo_shutdown()
{
  if (sym_handle)
    SymCleanup(sym_handle);
}

char* debuginfo_get_current_call_stack()
{
  USHORT frames_count;
  StringInfoData trace_buf;
  size_t i;
  DWORD64 *stack_buf,
        address;
  IMAGEHLP_MODULE64 module;
  char *symbol_buf,
        *module_name,
        *symbol_name,
        *file_name,
        *slash_pos;
  SYMBOL_INFO *symbol;
  IMAGEHLP_LINE64 line;
  DWORD line_number,
        line_displacement;
  BOOL sym_status;

  if (!sym_handle)
    return NULL;

  stack_buf = palloc(MAX_FRAMES * sizeof(DWORD64));
  frames_count = CaptureStackBackTrace(0, MAX_FRAMES, (void**) stack_buf, NULL);

  initStringInfo(&trace_buf);
  symbol_buf = palloc(sizeof(SYMBOL_INFO) + MAX_SYM_NAME);

  for (i = 2; i < frames_count; i++) {
    address = stack_buf[i];

    memset(&module, '\0', sizeof(IMAGEHLP_MODULE64));
    module.SizeOfStruct = sizeof(IMAGEHLP_MODULE64);
    sym_status = SymGetModuleInfo64(sym_handle, address, &module);
    module_name = sym_status ? module.ModuleName : "unknown_module";

    symbol = (SYMBOL_INFO*) symbol_buf;
    memset(symbol, '\0', sizeof(SYMBOL_INFO));
    symbol->SizeOfStruct = sizeof(SYMBOL_INFO);
    symbol->MaxNameLen = MAX_SYM_NAME;
    sym_status = SymFromAddr(sym_handle, address, NULL, symbol);
    symbol_name = sym_status ? symbol->Name : "unknown_symbol";

    memset(&line, '\0', sizeof(IMAGEHLP_LINE64));
    line.SizeOfStruct = sizeof(IMAGEHLP_LINE64);
    line_displacement = 0;
    sym_status = SymGetLineFromAddr64(sym_handle, address, &line_displacement, &line);
    line_number = sym_status ? line.LineNumber : 0;
    file_name = sym_status ? line.FileName : "unknown_file";
    slash_pos = strrchr(file_name, '\\');
    if (slash_pos)
      file_name = slash_pos + 1;

    appendStringInfo(&trace_buf, "\nat %s!%s (%s:%d:%d) [0x%08x]",
        module_name, symbol_name, file_name, line_number, line_displacement, address);
  }
  pfree(symbol_buf);
  pfree(stack_buf);

  return trace_buf.data;
}