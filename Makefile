
LIBRARY_SOURCES = $(wildcard *.vala)

TEST_SOURCES = $(wildcard test/*.vala)

TEST_EXECUTABLE_NAME = diva_test
LIBRARY_NAME = diva

VALAC=valac-0.26

all: $(LIBRARY_NAME).so $(TEST_EXECUTABLE_NAME)
	./$(TEST_EXECUTABLE_NAME)

$(LIBRARY_NAME).so: $(LIBRARY_SOURCES)
	$(VALAC) --pkg=gee-0.8 --library=$(LIBRARY_NAME) -H $(LIBRARY_NAME).h $(LIBRARY_SOURCES) -X -fpic -X -shared -g -o $(LIBRARY_NAME).so -X -w

$(TEST_EXECUTABLE_NAME): $(LIBRARY_NAME).so $(TEST_SOURCES)
	$(VALAC) --pkg=gee-0.8 --pkg=$(LIBRARY_NAME) --vapidir=. -X ./$(LIBRARY_NAME).so -X -I. -g $(TEST_SOURCES) -X -w -o $(TEST_EXECUTABLE_NAME)
