
INCLUDES = -I$(top_srcdir)/src
AM_LFLAGS = -olex.yy.c

bin_PROGRAMS = mif2xml
mif2xml_SOURCES =  mif.ll
mif2xml_LDADD = @LEXLIB@

EXTRA_DIST = miftag.h
CLEANFILES = mif.cc
