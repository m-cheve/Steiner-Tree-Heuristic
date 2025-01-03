.PHONY: all clean
INPUT=./input
ARGFILE=./argfile.ignore
OCAMLC=ocamlfind ocamlc
OCAMLFLAGS=-package graphics -linkpkg
# OCAMLC=/pub/FISE_PRFO23/ocamlc.sh

all: graph.cmo main.cmo
	$(OCAMLC) $(OCAMLFLAGS) graph.cmo main.cmo -o main

exec: all
	wc -l < $(INPUT) > $(ARGFILE)
	cat $(INPUT) >> $(ARGFILE)
	cat $(ARGFILE) | ./main

%.cmi: %.mli
	$(OCAMLC) $(OCAMLFLAGS) -c $< -o $@

%.cmo: %.ml
	$(OCAMLC) $(OCAMLFLAGS) -c $< -o $@

clean:
	rm -fv *~ *.cm[io] main *.ignore

graph.cmo: graph.cmi
main.cmo: graph.cmi
