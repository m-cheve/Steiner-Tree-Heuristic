.PHONY: all clean
INPUT=./test_input

all: tests.cmo graph.cmo main.cmo
	/pub/FISE_PRFO23/ocamlc.sh graph.cmo tests.cmo main.cmo -o main

test: all
	cat $(INPUT) | ./main

%.cmi: %.mli
	/pub/FISE_PRFO23/ocamlc.sh -c $< -o $@

%.cmo: %.ml
	/pub/FISE_PRFO23/ocamlc.sh -c $< -o $@

clean:
	rm -fv *~ *.cm[io] main



graph.cmo: graph.cmi
tests.cmo: graph.cmi
main.cmo: graph.cmi