LOG=build.log
COMP=ocamlbuild -log $(LOG) -classic-display
OCAMLFIND= -use-ocamlfind -tag package\(zarith\)
FLAGS=$(OCAMLFIND)
DIRS=
MAIN=main.p.native
BIN=main
DOC=lib.docdir/index.html
GENERATED=$(MAIN) $(BIN) gmon.out

all:$(MAIN)

test:$(MAIN)
	./$(BIN)

profile:$(MAIN) $(test)
	./$(BIN)
	gprof $(BIN) | less

rand:$(MAIN)
	for i in `seq 1000`; do ./$(BIN) > /dev/null; echo OK;	done;

$(MAIN):
	$(COMP) $(FLAGS) $(DIRS) $(MAIN)
	cp $(MAIN) $(BIN) && rm $(MAIN)

log:
	cat _build/$(LOG)

doc:
	$(COMP) $(FLAGS) $(DIRS) $(DOC)

clean:
	$(COMP) -clean
	rm -f $(GENERATED)
