.PHONY: all clean
INPUT=./input
ARGFILE=./argfile.ignore

all: tests.cmo graph.cmo main.cmo
	/pub/FISE_PRFO23/ocamlc.sh graph.cmo tests.cmo main.cmo -o main

test: all
	wc -l < $(INPUT) > $(ARGFILE)
	cat $(INPUT) >> $(ARGFILE)
	cat $(ARGFILE) | ./main

%.cmi: %.mli
	/pub/FISE_PRFO23/ocamlc.sh -c $< -o $@

%.cmo: %.ml
	/pub/FISE_PRFO23/ocamlc.sh -c $< -o $@

clean:
	rm -fv *~ *.cm[io] main *.ignore



graph.cmo: graph.cmi
tests.cmo: graph.cmi
main.cmo: graph.cmi