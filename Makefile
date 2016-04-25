
LIBRARY_SOURCES = $(wildcard *.vala)

TEST_SOURCES = $(wildcard test/*.vala)

TEST_EXECUTABLE_NAME = diva_test
LIBRARY_NAME = diva
LIBRARY_API_VERSION = 1
LIBRARY_VERSION = 0.1.0

LIBRARY_SONAME = lib$(LIBRARY_NAME).so.$(LIBRARY_API_VERSION)
LIBRARY_FILENAME = lib$(LIBRARY_NAME).so.$(LIBRARY_VERSION)

ifndef VALAC
VALAC := $(shell find $${PATH//:/ } -name valac-* | sort -r | head -n 1)
endif

ifndef VALAC
$(error Could not find Vala compiler)
endif

COMMON_C_OPTIONS= -w
VALA_COMMON_OPTIONS= $(foreach opt, $(COMMON_C_OPTIONS), -X $(opt)) -g

all: $(LIBRARY_FILENAME) $(TEST_EXECUTABLE_NAME) 
	export LD_LIBRARY_PATH=`pwd`; \
	./$(TEST_EXECUTABLE_NAME) --verbose

$(LIBRARY_FILENAME): $(LIBRARY_SOURCES)
	$(VALAC) --pkg=gee-0.8 --library=$(LIBRARY_NAME) -H $(LIBRARY_NAME).h \
	$(LIBRARY_SOURCES) -X -fpic -X -shared -X -Wl,-soname,$(LIBRARY_SONAME) \
	-o $(LIBRARY_FILENAME) $(VALA_COMMON_OPTIONS)
	
$(LIBRARY_SONAME): $(LIBRARY_FILENAME)
	ln -f $(LIBRARY_FILENAME) $(LIBRARY_SONAME)

$(TEST_EXECUTABLE_NAME): $(LIBRARY_SONAME) $(TEST_SOURCES)
	$(VALAC) --pkg=gee-0.8 --pkg=$(LIBRARY_NAME) --vapidir=. \
	-X ./$(LIBRARY_FILENAME) -X -I. $(TEST_SOURCES) $(VALA_COMMON_OPTIONS) \
	-o $(TEST_EXECUTABLE_NAME)

clean:
	rm -f $(TEST_EXECUTABLE_NAME) $(LIBRARY_NAME).{so,vapi,h}

PREFIX ?= /usr/local

install: $(LIBRARY_NAME).so
	
