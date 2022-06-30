/********************************************************************
** Copyright (c) 2018-2020 Guan Wenliang
** This file is part of the Berry default interpreter.
** skiars@qq.com, https://github.com/Skiars/berry
** See Copyright Notice in the LICENSE file or at
** https://github.com/Skiars/berry/blob/master/LICENSE
********************************************************************/
#include "berry.h"
#include "be_repl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* detect operating system name */
#define OS_NAME "Web Browser"

/* detect compiler name and version */
#define COMPILER    "emcc"

#if BE_DEBUG
#define FULL_VERSION "Berry " BERRY_VERSION " (debug)"
#else
#define FULL_VERSION "Berry " BERRY_VERSION
#endif

/* prompt message when REPL is loaded */
#define repl_prelude                                                \
    FULL_VERSION " (build in " __DATE__ ", " __TIME__ ")\n"         \
    "[" COMPILER "] on " OS_NAME " (default)\n\r"                   \

/* portable readline function package */
static char* get_line(const char *prompt)
{
    static char buffer[1000];
    be_writebuffer(prompt, strlen(prompt));
    if (be_readstring(buffer, sizeof(buffer))) {
        buffer[strlen(buffer) - 1] = '\0';
        return buffer;
    }
    return NULL;
}

static void free_line(char *ptr)
{
    (void)ptr;
}

int main(void)
{
    bvm *vm = be_vm_new(); /* create a virtual machine instance */
    be_writestring("\033[32m" repl_prelude "\033[39m");
    if (be_repl(vm, get_line, free_line) == -BE_MALLOC_FAIL) {
        be_writestring("error: memory allocation failed.\n");
    }
    be_vm_delete(vm); /* free all objects and vm */
    return 0;
}
