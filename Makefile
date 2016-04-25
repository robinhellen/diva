
LIBRARY_SOURCES = $(wildcard *.vala)

TEST_SOURCES = $(wildcard test/*.vala)

TEST_EXECUTABLE_NAME = diva_test
LIBRARY_NAME = diva

ifndef VALAC
VALAC := $(shell find $${PATH//:/ } -name valac-* | sort -r | head -n 1)
endif

ifndef VALAC
$(error Could not find Vala compiler)
endif

COMMON_C_OPTIONS= -w
VALA_COMMON_OPTIONS= $(foreach opt, $(COMMON_C_OPTIONS), -X $(opt)) -g

all: $(LIBRARY_NAME).so $(TEST_EXECUTABLE_NAME)
	./$(TEST_EXECUTABLE_NAME) --verbose

$(LIBRARY_NAME).so: $(LIBRARY_SOURCES)
	$(VALAC) --pkg=gee-0.8 --library=$(LIBRARY_NAME) -H $(LIBRARY_NAME).h $(LIBRARY_SOURCES) -X -fpic -X -shared -o $(LIBRARY_NAME).so $(VALA_COMMON_OPTIONS)

$(TEST_EXECUTABLE_NAME): $(LIBRARY_NAME).so $(TEST_SOURCES)
	$(VALAC) --pkg=gee-0.8 --pkg=$(LIBRARY_NAME) --vapidir=. -X ./$(LIBRARY_NAME).so -X -I. $(TEST_SOURCES) $(VALA_COMMON_OPTIONS) -o $(TEST_EXECUTABLE_NAME)

clean:
	rm -f $(TEST_EXECUTABLE_NAME) $(LIBRARY_NAME).{so,vapi,h}
