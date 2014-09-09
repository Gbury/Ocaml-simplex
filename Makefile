# copyright (c) 2014, guillaume bury

LOG=build.log
COMP=ocamlbuild -log $(LOG) -classic-display
OCAMLFIND= -use-ocamlfind -tag package\(zarith\)
FLAGS=$(OCAMLFIND)
DIRS=
BIN=main
MAIN=main.d.byte
DOC=lib.docdir/index.html
LIB=simplex.cma simplex.cmxa
GENERATED=$(MAIN) $(BIN) gmon.out

all:$(MAIN)

test:$(MAIN)
	./$(BIN)

profile:$(MAIN) $(test)
	./$(BIN)
	gprof $(BIN) | less

$(MAIN):
	$(COMP) $(FLAGS) $(DIRS) $(MAIN)
	cp $(MAIN) $(BIN) && rm $(MAIN)

doc:
	$(COMP) $(FLAGS) $(DIRS) $(DOC)

lib:
	$(COMP) $(FLAGS) $(DIRS) $(LIB)

clean:
	$(COMP) -clean
	rm -f $(GENERATED)
