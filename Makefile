MODULES=dogma card player state game authors frontend main ai
OBJECTS=$(MODULES:=.cmo)
MLS=$(MODULES:=.ml)
MLIS=$(MODULES:=.mli)
TEST=test.byte
MAIN=main.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind
PKGS=qcheck 

default: build
	utop 

build:
	$(OCAMLBUILD) $(OBJECTS)

# test:
#  	$(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST)

play:
	$(OCAMLBUILD) $(MAIN) && ./$(MAIN)

#check:
#	bash checkenv.sh && bash checktypes.sh
	

test:
	$(OCAMLBUILD) -tag debug $(TEST) && ./$(TEST)

bisect-test:
	BISECT_COVERAGE=YES $(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST) -runner sequential

check:
	bash checkenv.sh && bash checktypes.sh
	
finalcheck: check
	bash checkzip.sh
	bash finalcheck.sh

bisect: clean bisect-test
	bisect-ppx-report -I _build -html report bisect0001.out

perf: 
	$(OCAMLBUILD) performanceTest.native && ./performanceTest.native
	gnuplot perf.p

zip:
	zip innovation_src.zip *.ml* _tags Makefile mli_files innov.json test1.json test2.json INSTALL.md 
	
docs: docs-public docs-private
	
docs-public: build
	mkdir -p doc.public
	ocamlfind ocamldoc -I _build -package yojson,ANSITerminal,qcheck  \
		-html -stars -d doc.public $(MLIS)

docs-private: build
	mkdir -p doc.private
	ocamlfind ocamldoc -I _build -package yojson,ANSITerminal,qcheck  \
		-html -stars -d doc.private \
		-inv-merge-ml-mli -m A -hide-warnings $(MLIS) $(MLS)

clean:
	ocamlbuild -clean
	rm -rf doc.public doc.private report search_src.zip bisect*.out
