
all: ZZjj-QCD_Skim.root ZZjj-EWK_Skim.root
.PHONY: all

Makefile:;
%.root:;
%.py:;

%_Skim.root: %.root runLocal.py prod/pyFragments/VBS_probs.py
	./runLocal.py MELA_VBS_$*
