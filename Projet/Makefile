.PHONY: all clean

all: tests.cmo graph.cmo main.cmo
	ocamlc graph.cmo tests.cmo main.cmo -o main

test: all
	./main

%.cmi: %.mli
	ocamlc -c $< -o $@

%.cmo: %.ml
	ocamlc -c $< -o $@

clean:
	rm -fv *~ *.cm[io] main



graph.cmo: graph.cmi
tests.cmo: graph.cmi
