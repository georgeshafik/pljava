#-------------------------------------------------------------------------
# Copyright (c) 2004, 2005, 2006 TADA AB - Taby Sweden
# Copyright (c) 2007 - 2011 PostgreSQL Global Development Group
#
# Distributed under the terms shown in the file COPYRIGHT
# found in the root folder of this project or at
# http://wiki.tada.se/index.php?title=PLJava_License
#
# @author Thomas Hallgren
#-------------------------------------------------------------------------
MODULE_big	:= pljava
SRCDIR	:= $(MODULEROOT)/$(MODULE_big)
INCLDIR	:= -I$(MODULEROOT)/include -I$(JNIDIR)

mkobjs	= $(subst $(SRCDIR)/,,$(1:%.c=%.o))
SRCS	= $(shell find $(SRCDIR) -name CVS -prune -o -type f -name \*.c -print)
OBJS	= $(call mkobjs,$(SRCS))

DLLTOOL_DEFFLAGS := --add-stdcall-alias

.PHONY: checkjavahome build pljava-plugin

$(OBJS): %.o : $(SRCDIR)/%.c
	@-mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

# Must include PGXS at this point since it defines PORTNAME and VERSION
#
include $(PGXS)

SS_VERSION := $(subst ., ,$(subst devel,.99,$(subst beta,.99,$(subst alpha,.99,$(subst rc,.99,$(subst RC,.99,$(VERSION)))))))
PGSQL_MAJOR_VER	= $(word 1,$(SS_VERSION))
PGSQL_MINOR_VER	= $(word 2,$(SS_VERSION))
PGSQL_PATCH_VER	= $(word 3,$(SS_VERSION))

PLJAVA_CPPFLAGS = \
	-DPKGLIBDIR=\"$(pkglibdir)\" $(INCLDIR) \
	-DPGSQL_MAJOR_VER=$(PGSQL_MAJOR_VER) \
	-DPGSQL_MINOR_VER=$(PGSQL_MINOR_VER) \
	-DPGSQL_PATCH_VER=$(PGSQL_PATCH_VER)

ifeq ($(PORTNAME), win32)
	DLL_BUILD := 1
else
ifeq ($(PORTNAME), darwin)
	#
	# override with JAVAVM_FWX_ROOT=/... on command line
	# if something else is needed
	#
	JAVAVM_FWX_ROOT := /System/Library/Frameworks
	PLJAVA_CPPFLAGS += -I$(JAVAVM_FWX_ROOT)/JavaVM.framework/Headers/
else
ifeq ($(PORTNAME), ibmos2)
	DLL_BUILD := 1
else
	JRE_INCL := $(PORTNAME)
	ifeq ($(host_cpu), powerpc64)
		JRE_CPU := ppc64
	else
	ifeq ($(host_cpu), i686)
		JRE_CPU := i386
	else
	ifeq ($(host_cpu), i586)
		JRE_CPU := i386
	else
	ifeq ($(host_cpu), i486)
		JRE_CPU := i386
	else
	ifeq ($(host_cpu), x86_64)
		JRE_CPU := amd64
	else
		JRE_CPU := $(host_cpu)
	endif
	endif
	endif
	endif
	endif

	ifeq ($(JRE_CPU), i386)
		ifeq ($(findstring -m64, $(CFLAGS)), -m64)
			JRE_CPU := amd64
		endif
	endif

endif
endif
endif

ifdef USE_GCJ
	PLJAVA_CPPFLAGS += -DGCJ
	SHLIB_LINK = -lgcj $(PLJAVA_LDFLAGS)
	ifdef DLL_BUILD
		SHLIB_LINK += -lws2_32
	endif
	OBJS += pljava_jar.o
else
	pljava-jar = pljava.jar
	ifeq ($(PORTNAME), darwin)
		SHLIB_LINK += -L. -framework JavaVM $(PLJAVA_LDFLAGS)
	else
		ifdef JAVA_HOME
			ifeq ($(PORTNAME), win32)
				JDK_HOME := $(subst \,/,$(JAVA_HOME))
			else
				JDK_HOME := $(JAVA_HOME)
			endif
		else
			ifeq ($(PORTNAME), ibmos2)
				JAVA_HOME_TEST_RESULT := $(echo "You must set JAVA_HOME")
			else
				JAVA_HOME_TEST_RESULT := $(error You must set JAVA_HOME)
			endif
		endif
		ifdef DLL_BUILD
			ifeq ($(PORTNAME),ibmos2)
				JRE_INCL := os2
			else
				JRE_INCL := win32
			endif
			ifeq ($(host_cpu), x86_64)
				JVM_LIB  := $(JDK_HOME)/jre/bin/server
			else
				JVM_LIB  := $(JDK_HOME)/jre/bin/client
			endif
		else
			JRE_LIB := $(JDK_HOME)/jre/lib/$(JRE_CPU)
			JVM_LIB := $(firstword $(shell /bin/ls -d \
				$(JRE_LIB)/client \
				$(JRE_LIB)/server \
				$(JRE_LIB)/jrockit \
				$(JDK_HOME)/jre/bin/j9vm \
				2> /dev/null))
		endif

		PLJAVA_CPPFLAGS += -I"$(JDK_HOME)/include" -I"$(JDK_HOME)/include/$(JRE_INCL)"
		SHLIB_LINK += -L. -L"$(JVM_LIB)" -ljvm $(PLJAVA_LDFLAGS)

		ifdef USE_LD_RPATH
			ifeq (${USE_LD_RPATH},1)
				SHLIB_LINK += -Wl,-rpath,${JVM_LIB}
				ifneq ($(JVM_LIB), $(JVM_LIB:/j9vm=))
					SHLIB_LINK += \
						-Wl,-rpath,$(JVM_LIB:/j9vm=)
				endif
			else
			ifeq (${USE_LD_RPATH},2)
				SHLIB_LINK += -rpath ${JVM_LIB}
				ifneq ($(JVM_LIB), $(JVM_LIB:/j9vm=))
					SHLIB_LINK += \
						-rpath $(JVM_LIB:/j9vm=)
				endif
			else
			ifeq (${USE_LD_RPATH},3)
				SHLIB_LINK += -R${JVM_LIB}
				ifneq ($(JVM_LIB), $(JVM_LIB:/j9vm=))
					SHLIB_LINK += \
						-R$(JVM_LIB:/j9vm=)
				endif
			else
			ifeq (${USE_LD_RPATH},4)
				SHLIB_LINK += -R ${JVM_LIB}
				ifneq ($(JVM_LIB), $(JVM_LIB:/j9vm=))
					SHLIB_LINK += \
						-R $(JVM_LIB:/j9vm=)
				endif
			else
			ifeq (${USE_LD_RPATH},5)
				SHLIB_LINK += -Wl,-R${JVM_LIB}
				ifneq ($(JVM_LIB), $(JVM_LIB:/j9vm=))
					SHLIB_LINK += \
						-Wl,-R$(JVM_LIB:/j9vm=)
				endif
			else
			ifeq (${USE_LD_RPATH},6)
				SHLIB_LINK += -Wl,-R,${JVM_LIB}
				ifneq ($(JVM_LIB), $(JVM_LIB:/j9vm=))
					SHLIB_LINK += \
						-Wl,-R,$(JVM_LIB:/j9vm=)
				endif
			endif
			endif
			endif
			endif
			endif
			endif

		endif
	endif
endif

ifeq ($(JRE_INCL), win32)
#
# Mingw is a bit special in that we use a "normal" windows
# port of the Java Runtime Environment (unless we use gcj
# of course). The headers etc. for the JRE is windows style
# and contains __int64. GNU compiler doesn't know __int64,
# instead it uses long long.
#
ifndef USE_GCJ

PLJAVA_CPPFLAGS += -D__int64='long long'

# Don't use higher standard then c89 since this rules out older compilers. We
# must use 'long long' however, since JNI defines it.
#
PLJAVA_CFLAGS += -Wno-long-long

endif
endif

override CPPFLAGS += $(PLJAVA_CPPFLAGS)
override CFLAGS += $(PLJAVA_CFLAGS)

# shlib naming convention for plugins (no 'lib')
#
plugin = $(NAME)$(DLSUFFIX)
soname = $(plugin)
shlib  = $(plugin)

ifndef USE_GCJ
checkjavahome:
	$(JAVA_HOME_TEST_RESULT)
endif

ifneq ($(PORTNAME), win32)
ifneq ($(PORTNAME), aix)

# Normal case
#
$(plugin): $(OBJS)
	$(LINK.shared) $(LDFLAGS_SL) $(OBJS) $(SHLIB_LINK) -o $(plugin)

else # PORTNAME == aix

# AIX case
#
$(plugin): lib$(NAME).a
	$(MKLDEXPORT) lib$(NAME).a > $(NAME)$(EXPSUFF)
	$(COMPILER) $(LDFLAGS_NO_L) $(LDFLAGS_SL) -o $(plugin) $< -Wl,-bE:$(NAME)$(EXPSUFF) $(SHLIB_LINK)

endif # PORTNAME == aix

else # PORTNAME == win32

# win32 case
#
$(plugin): $(OBJS)
ifndef USE_GCJ
ifneq ($(host_cpu), x86_64)
	$(DLLTOOL) --input-def $(SRCDIR)/jvm.def --kill-at --dllname jvm.dll --output-lib libjvm.dll.a
endif
endif
ifeq ($(host_cpu), x86_64)
	$(DLLTOOL) --export-all --output-def $(NAME).def $(OBJS)
	$(DLLTOOL) --dllname $(plugin) $(DLLTOOL_LIBFLAGS) \
		--def $(NAME).def
	gendef - ${JVM_LIB}/jvm.dll > jvm.def
	${DLLTOOL} --export-all-symbols --input-def jvm.def \
		--output-lib libjvm.dll.a
	${CC} -shared -o ${plugin} ${OBJS} ${BE_DLLLIBS} -L. -ljvm
else
	$(DLLTOOL) --export-all $(DLLTOOL_DEFFLAGS) \
		--output-def $(NAME).def $(OBJS)
	$(DLLWRAP) $(LDFLAGS_SL) -o $(plugin) --dllname $(plugin) \
		$(DLLWRAP_FLAGS) --def $(NAME).def $(OBJS) \
		$(SHLIB_LINK)
	$(DLLTOOL) --dllname $(plugin) $(DLLTOOL_LIBFLAGS) \
		--def $(NAME).def
endif

endif # PORTNAME == win32

build_all: $(plugin)

build_install: build_all installdirs
	$(INSTALL_SHLIB) $(plugin) $(DESTDIR)$(pkglibdir)/$(plugin)
ifndef USE_GCJ
	$(INSTALL_DATA) ../$(pljava-jar) $(DESTDIR)$(pkglibdir)
endif

build_uninstall:
	rm -f $(DESTDIR)$(pkglibdir)/$(plugin)
ifndef USE_GCJ
	rm -f $(DESTDIR)$(pkglibdir)/$(pljava-jar)
endif
