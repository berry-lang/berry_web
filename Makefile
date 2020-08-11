CFLAGS    = -Wall -Wextra -std=c99 -pedantic-errors -O2
LIBS      = -lm -ldl
TARGET    = docs/berry.js
CC        = emcc
MKDIR     = mkdir
LFLAGS    = -s WASM=0 -s ASYNCIFY \
            -s 'ASYNCIFY_IMPORTS=["_js_readbuffer", "_js_writebuffer"]'

INCPATH   = berry/src plantform
SRCPATH   = berry/src plantform
GENERATE  = generate
CONFIG    = plantform/berry_conf.h
COC		  = berry/tools/coc/coc
CONST_TAB = $(GENERATE)/be_const_strtab.h
MAKE_COC  = $(MAKE) -C berry/tools/coc

ifneq ($(V), 1)
    Q=@
    MSG=@echo
    MAKE_COC += -s Q=$(Q)
else
    MSG=@true
endif

SRCS     = $(foreach dir, $(SRCPATH), $(wildcard $(dir)/*.c))
OBJS     = $(patsubst %.c, %.o, $(SRCS))
DEPS     = $(patsubst %.c, %.d, $(SRCS))
INCFLAGS = $(foreach dir, $(INCPATH), -I"$(dir)")

.PHONY : clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(MSG) [Linking...]
	$(Q) $(CC) $(OBJS) $(LFLAGS) $(LIBS) -o $@
	$(MSG) done

$(OBJS): %.o: %.c
	$(MSG) [Compile] $<
	$(Q) $(CC) -c -MM $(CFLAGS) $(INCFLAGS) -MT"$*.d" -MT"$(<:.c=.o)" $< > $*.d
	$(Q) $(CC) $(CFLAGS) $(INCFLAGS) -c $< -o $@

sinclude $(DEPS)

$(OBJS): $(CONST_TAB)

$(CONST_TAB): $(COC) $(GENERATE) $(SRCS) $(CONFIG)
	$(MSG) [Prebuild] generate resources
	$(Q) $(COC) -i $(SRCPATH) -c $(CONFIG) -o $(GENERATE)

$(GENERATE):
	$(Q) $(MKDIR) $(GENERATE)

$(COC):
	$(MSG) [Make] coc
	$(Q) $(MAKE_COC)

install:
	cp $(TARGET) /usr/local/bin

uninstall:
	$(RM) /usr/local/bin/$(TARGET)

prebuild: $(COC) $(GENERATE)
	$(MSG) [Prebuild] generate resources
	$(Q) $(COC) -o $(GENERATE) $(SRCPATH) -c $(CONFIG)
	$(MSG) done

clean:
	$(MSG) [Clean...]
	$(Q) $(RM) $(OBJS) $(DEPS) $(GENERATE)/* berry.lib
	$(Q) $(MAKE_COC) clean
	$(MSG) done
