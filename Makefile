# MicroC by Stephen Edwards Columbia University
# Make sure ocamlbuild can find opam-managed packages: first run
#
# eval `opam config env`

# Easiest way to build: using ocamlbuild, which in turn uses ocamlfind


democritus.native : bindings.c scanner.mll parser.mly ast.ml semant.ml
	clang -c -pthread -emit-llvm bindings.c
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis,llvm.bitwriter,llvm.bitreader,llvm.linker -cflags -w,+a-4 \
		democritus.native

.PHONY : all
all : clean democritus.native

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf testall.log *.diff democritus scanner.ml parser.ml parser.mli *.tar.gz
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o *.ll *.err *.bc *.out tests/*.txt *.html *.gif

# More detailed: build using ocamlc/ocamlopt + ocamlfind to locate LLVM

OBJS = ast.cmx codegen.cmx parser.cmx scanner.cmx semant.cmx democritus.cmx

democritus : $(OBJS)
	ocamlfind ocamlopt -linkpkg -package llvm -package llvm.analysis $(OBJS) -o democritus

scanner.ml : scanner.mll
	ocamllex scanner.mll

parser.ml parser.mli : parser.mly
	ocamlyacc parser.mly

%.cmo : %.ml
	ocamlc -c $<

%.cmi : %.mli
	ocamlc -c $<

%.cmx : %.ml
	ocamlfind ocamlopt -c -package llvm $<

### Generated by "ocamldep *.ml *.mli" after building scanner.ml and parser.ml
ast.cmo :
ast.cmx :
codegen.cmo : ast.cmo
codegen.cmx : ast.cmx
democritus.cmo : semant.cmo scanner.cmo parser.cmi codegen.cmo ast.cmo
democritus.cmx : semant.cmx scanner.cmx parser.cmx codegen.cmx ast.cmx
parser.cmo : ast.cmo parser.cmi
parser.cmx : ast.cmx parser.cmi
scanner.cmo : parser.cmi
scanner.cmx : parser.cmx
semant.cmo : ast.cmo
semant.cmx : ast.cmx
parser.cmi : ast.cmo

# Building the tarball

TESTS = arith1 arith2 arith3 fib for1 for2 func1 func2 func3 func4	\
    func5 gcd2 gcd global1 global2 hello if1 if2 if3 if4 ops1 ops2	\
    var1 for-as-while1 local1 helloworld helloworld-assign

FAILS = assign1 assign2 assign3 dead1 dead2 expr1 expr2 for1 for2	\
    for3 for4 for5 func1 func2 func3 func4 func5 func6 func7 func8	\
    func9 global1 global2 if1 if2 if3 nomain return1 return2		 \
    for-all-while1 for-all-while2

TESTFILES = $(TESTS:%=test-%.mc) $(TESTS:%=test-%.out) \
	    $(FAILS:%=fail-%.mc) $(FAILS:%=fail-%.err)

TARFILES = ast.ml codegen.ml Makefile democritus.ml parser.mly README.md scanner.mll \
	semant.ml testall.sh demo/ tests/ bindings.c

tar : $(TARFILES)
	cd .. && tar czf Democritus/DEMO.tar.gz \
		$(TARFILES:%=Democritus/%)
