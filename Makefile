
date := $(shell date +"%Y%m%d.%H%M%S")
top := $(shell pwd)
xml_dir := $top/xml
best_prefix := /Users/moot/checkout/models

filter = sed \
        -e 's|.+sentence.+ correct .\([0-9]+\.[0-9][0-9]\)|S: \1|g' \
        -e 's|.+word.+ correct .\([0-9]+\.[0-9][0-9, ]\)|W: \1|g'


install: small tt2pos examples split_me merge strip_tags chop add_missing_pos
	chmod a+x tt2pos small examples split_me merge add_missing_pos strip_tags
	chmod a+x chop chop_word chop_all f2pl verify_formulas findword split_treebank integrate_messages
	chmod a+x merged_to_melt merged_to_treetagger merged_to_simple merged_to_melt_unknowns merged_to_tt_unknowns compactify
	-cp -f tt2pos /Users/moot/checkout/Corpus/bin/

compact: cmsg.txt
	/usr/bin/less cmsg.txt
simple: msg_simple.txt
	/usr/bin/less msg_simple.txt
melt: msg_melt.txt
	/usr/bin/less msg_melt.txt
tt: msg_tt.txt
	/usr/bin/less msg_tt.txt
build: msg.txt supertagdiff.txt backup_models
	/usr/bin/less msg.txt

uni: uni.tcl

all: compare big direct_msg.txt integrate_messages
	./integrate_messages > overview.txt
	/usr/bin/less overview.txt

bootstrap: maxentdata.txt
	./bootstrap_cleanup maxentdata.txt > mb.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input mb.txt --model french_bootstrap --solver bfgs --verbose --niterations 10000 --comment "Training and tagging all words for bootstrapping, using the merged POS tag set"

tars: super_tars pos_tars

super_tars:
	cd /Users/moot/checkout/models ; tar cvfz super_merged.tgz french_merged/*
	cd /Users/moot/checkout/models ; tar cvfz super_melt.tgz french_melt/*
	cd /Users/moot/checkout/models ; tar cvfz super_tt.tgz french_tt/*
	cd /Users/moot/checkout/models ; tar cvfz super_simple.tgz french_simple/*
	cd /Users/moot/checkout/models ; tar cvfz super_all.tgz french_merged/* french_melt/* french_tt/* french_simple/*

pos_tars:
	cd /Users/moot/checkout/models ; tar cvfz pos_merged.tgz french_pos_merged/*
	cd /Users/moot/checkout/models ; tar cvfz pos_melt.tgz french_pos_melt/*
	cd /Users/moot/checkout/models ; tar cvfz pos_tt.tgz french_pos_tt/*
	cd /Users/moot/checkout/models ; tar cvfz pos_simple.tgz french_pos_simple/*
	cd /Users/moot/checkout/models ; tar cvfz pos_all.tgz french_pos_merged/* french_pos_melt/* french_pos_tt/* french_pos_simple/*


ner.train: maxentdata.txt ner_more.txt
	./split_ner maxentdata.txt
	mv ner.train ner1.tmp
	./split_ner ner_more.txt
	mv ner.train ner2.tmp
	cat ner1.tmp ner2.tmp > ner.train

ner: ner.train
	train_ner --input ner.train --ifmt "%w|%p|%s|%n \n" --model ner --solver bfgs --comment "Training NER" --verbose


itipy: itipy/treebank/ParisVII_complete.txt

itipy/treebank/ParisVII_complete.txt: maxentdata.txt
	./chop_all maxentdata.txt
	-/bin/cp -f maxentdata.txt itipy/treebank/ParisVII_complete.txt

compare: compare_pos.txt compare_super.txt compare_pos_super.txt

big: big_super big_pos

big_super: tag_m2 tag_m2_tt tag_m2_melt tag_m2_simple

big_pos: poserr.tagged poserr_simple.tagged poserr_tt.tagged poserr_melt.tagged

best: all_best_pos all_best_super

all_best_pos: best_pos best_pos_melt best_pos_tt best_pos_simple

all_best_super: best_super best_super_melt best_super_tt best_super_simple

extra: all_xbest_pos

all_xbest_pos: xbest_pos xbest_pos_melt xbest_pos_tt xbest_pos_simple

diff: supertagdiff.txt

# different targets for training the POS tagger with the four different tagsets

pos: eval_pos.txt backup_pos
	/usr/bin/less eval_pos.txt
pos_tt: eval_pos_tt.txt backup_pos_tt
	/usr/bin/less eval_pos_tt.txt
pos_melt: eval_pos_melt.txt backup_pos_melt
	/usr/bin/less eval_pos_melt.txt
pos_simple: eval_pos_simple.txt backup_pos_simple
	/usr/bin/less eval_pos_simple.txt

compare_pos: compare_pos.txt
	/usr/bin/less compare_pos.txt
compare_pos.txt: eval_pos.txt eval_pos_tt.txt eval_pos_melt.txt eval_pos_simple.txt
	echo "  = Merged =" > compare_pos.txt
	tail -3 eval_pos.txt | ($filter) >> compare_pos.txt
	echo "\n  = Treetagger =" >> compare_pos.txt
	tail -3 eval_pos_tt.txt >> compare_pos.txt
	echo "\n  = MElt =" >> compare_pos.txt
	tail -3 eval_pos_melt.txt >> compare_pos.txt
	echo "\n  = Simple =" >> compare_pos.txt
	tail -3 eval_pos_simple.txt >> compare_pos.txt

compare_super: compare_super.txt
	/usr/bin/less compare_super.txt
compare_super.txt: msg.txt msg_tt.txt msg_melt.txt msg_simple.txt
	echo "  = Merged =\n" > compare_super.txt
	cat msg.txt >> compare_super.txt
	echo "\n  = Treetagger =\n" >> compare_super.txt
	cat msg_tt.txt >> compare_super.txt
	echo "\n  = MElt =\n" >> compare_super.txt
	cat msg_melt.txt >> compare_super.txt
	echo "\n  = Simple =\n" >> compare_super.txt
	cat msg_simple.txt >> compare_super.txt

compare_pos_super: compare_pos_super.txt
	/usr/bin/less compare_pos_super.txt
compare_pos_super.txt: msg_p_s.txt msg_tt_p_s.txt msg_melt_p_s.txt msg_simple_p_s.txt
	echo "  = Merged =\n" > compare_pos_super.txt
	cat msg_p_s.txt >> compare_pos_super.txt
	echo "\n  = Treetagger =\n" >> compare_pos_super.txt
	cat msg_tt_p_s.txt >> compare_pos_super.txt
	echo "\n  = MElt =\n" >> compare_pos_super.txt
	cat msg_melt_p_s.txt >> compare_pos_super.txt
	echo "\n  = Simple =\n" >> compare_pos_super.txt
	cat msg_simple_p_s.txt >> compare_pos_super.txt

# evaluation of the direct (without POS tagging) supertagger

direct: direct_msg.txt
	/usr/bin/less direct_msg.txt

direct_msg.txt: direct.eval direct10.eval direct50.eval direct100.eval direct500.eval direct1000.eval
	/usr/bin/tail -6 direct.eval > direct_msg.txt
	/usr/bin/tail -6 direct10.eval >> direct_msg.txt
	/usr/bin/tail -6 direct50.eval >> direct_msg.txt
	/usr/bin/tail -6 direct100.eval >> direct_msg.txt
	/usr/bin/tail -6 direct500.eval >> direct_msg.txt
	/usr/bin/tail -6 direct1000.eval >> direct_msg.txt

direct.eval: direct.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test direct.tagged > direct.eval
direct10.eval: direct10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test direct10.tagged > direct10.eval
direct50.eval: direct50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test direct50.tagged > direct50.eval
direct100.eval: direct100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test direct100.tagged > direct100.eval
direct500.eval: direct500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test direct500.tagged > direct500.eval
direct1000.eval: direct1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test direct1000.tagged > direct1000.eval

direct.tagged: direct_super/weights direct_super/unknowns direct_super/number_unknowns maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input maxent.test --model direct_super --ifmt "%w|%1|%p \n" --ofmt "%w|%1|%p \n" > direct.tagged
direct10.tagged: direct_super/weights direct_super/unknowns direct_super/number_unknowns maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/mpos --input maxent.test --model direct_super --beta 0.1 --ifmt "%w|%1|%p \n" --ofmt "%w|%1|%P \n" > direct10.tagged
direct50.tagged: direct_super/weights direct_super/unknowns direct_super/number_unknowns maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/mpos --input maxent.test --model direct_super --beta 0.05 --ifmt "%w|%1|%p \n" --ofmt "%w|%1|%P \n" > direct50.tagged
direct100.tagged: direct_super/weights direct_super/unknowns direct_super/number_unknowns maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/mpos --input maxent.test --model direct_super --beta 0.01 --ifmt "%w|%1|%p \n" --ofmt "%w|%1|%P \n" > direct100.tagged
direct500.tagged: direct_super/weights direct_super/unknowns direct_super/number_unknowns maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/mpos --input maxent.test --model direct_super --beta 0.005 --ifmt "%w|%1|%p \n" --ofmt "%w|%1|%P \n" > direct500.tagged
direct1000.tagged: direct_super/weights direct_super/unknowns direct_super/number_unknowns maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/mpos --input maxent.test --model direct_super --beta 0.001 --ifmt "%w|%1|%p \n" --ofmt "%w|%1|%P \n" > direct1000.tagged

direct_super/weights: maxent.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input maxent.train --ifmt "%w|%1|%p \n" --model direct_super --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the supertagger directly (without using POS tags)"
direct_super/unknowns: direct_super/weights
	head -3 direct_super/config > direct_super/unknowns
	cat unknown_formulas/unknowns >> direct_super/unknowns 
direct_super/number_unknowns: direct_super/weights
	head -3 direct_super/config > direct_super/number_unknowns
	cat unknown_formulas/number_unknowns >> direct_super/number_unknowns 


pos_err: eval_pos_err.txt

# saves the data from the last run in my MobileMe acount
# note that this is never done automatically (as part of "all")
# but has to be done manually after evaluating the model has
# actually improved over the previous version.

best: best_pos best_super

best_super: french/weights bootstrap_formulas.txt
	/bin/cp -f french/* $(best_prefix)/french_merged
	/bin/cp -f msg.txt $(best_prefix)/msg_merged.txt
	-/bin/cp -f french/* /Applications/TreebankAnnotator.app/Contents/Resources/Super
	-/bin/cp -f bootstrap_formulas.txt ~/Library/TreebankAnnotator/
best_super_melt: french_melt/weights
	/bin/cp -f french_melt/* $(best_prefix)/french_melt
	/bin/cp -f msg_melt.txt $(best_prefix)/msg_melt.txt
best_super_tt: french_tt/weights
	/bin/cp -f french_tt/* $(best_prefix)/french_tt
	/bin/cp -f msg_tt.txt $(best_prefix)/msg_tt.txt
best_super_simple: french_simple/weights
	/bin/cp -f french_simple/* $(best_prefix)/french_simple
	/bin/cp -f msg_simple.txt $(best_prefix)/msg_simple.txt

best_pos: eval_pos_err.txt all_pos/weights
	/bin/cp -f all_pos/* $(best_prefix)/french_pos_merged
	-/bin/cp -f all_pos/* /Applications/TreebankAnnotator.app/Contents/Resources/POS
best_pos_melt: eval_pos_melt_err.txt all_pos_melt/weights
	/bin/cp -f all_pos_melt/* $(best_prefix)/french_pos_melt
best_pos_tt: eval_pos_tt_err.txt all_pos_tt/weights
	/bin/cp -f all_pos_tt/* $(best_prefix)/french_pos_tt
best_pos_simple: eval_pos_simple_err.txt all_pos_simple/weights
	/bin/cp -f all_pos_simple/* $(best_prefix)/french_pos_simple

backup_pos: eval_pos.txt
	-/bin/cp pos.tgz pos.tgz.$(date)
	/usr/bin/tar cvfz pos.tgz eval_pos.txt maxentdata.txt m2.txt pos/*
backup_pos_tt: eval_pos_tt.txt m2_tt.txt
	-/bin/cp pos_tt.tgz pos_tt.tgz.$(date)
	/usr/bin/tar cvfz pos_tt.tgz eval_pos_tt.txt maxentdata.txt m2_tt.txt pos_tt/*
backup_pos_melt: eval_pos_melt.txt m2_melt.txt
	-/bin/cp pos_melt.tgz pos_melt.tgz.$(date)
	/usr/bin/tar cvfz pos_melt.tgz eval_pos_melt.txt maxentdata.txt m2_melt.txt pos_melt/*
backup_pos_simple: eval_pos_simple.txt m2_simple.txt
	-/bin/cp pos_simple.tgz pos_simple.tgz.$(date)
	/usr/bin/tar cvfz pos_simple.tgz eval_pos_simple.txt maxentdata.txt m2_simple.txt pos_simple/*
backup_models: msg.txt
	-/bin/cp models.tgz models.tgz.$(date)
	/usr/bin/tar cvfz models.tgz msg.txt eval.txt eval10.txt eval50.txt eval100.txt eval500.txt eval1000.txt maxentdata.txt m2.txt maxent_cleanup french_eval/* french_tt_eval/* melt_french_eval/* simple_french_eval/* french/* french_tt/* french_melt/* french_simple/*
backup_all:
	-/bin/cp backup.tgz backup.tgz.$(date)
	/usr/bin/tar cvfz backup.tgz configure.ac configure Makefile *.txt *.chop *.in french_eval/* french_tt_eval/* melt_french_eval/* simple_french_eval/* french/* french_tt/* french_melt/* french_simple/* unknowns/* unknown_formulas/* xml/*

uni.tcl: m2.txt
	maxent2unigram m2.txt >  uni.tcl
cu.tcl: mc.txt
	maxent2unigram mc.txt > cu.tcl

eval.txt: maxent.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent.tagged > eval.txt
	/usr/bin/tail -28 eval.txt
eval10.txt: maxent10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent10.tagged > eval10.txt
	/usr/bin/tail -28 eval10.txt
eval50.txt: maxent50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent50.tagged > eval50.txt
	/usr/bin/tail -28 eval50.txt
eval100.txt: maxent100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent100.tagged > eval100.txt
	/usr/bin/tail -28 eval100.txt
eval500.txt: maxent500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent500.tagged > eval500.txt
	/usr/bin/tail -28 eval500.txt
eval1000.txt: maxent1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent1000.tagged > eval1000.txt
	/usr/bin/tail -28 eval1000.txt

tt_eval.txt: maxent_tt.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt.tagged > tt_eval.txt
	/usr/bin/tail -28 tt_eval.txt
tt_eval10.txt: maxent_tt10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt10.tagged > tt_eval10.txt
	/usr/bin/tail -28 tt_eval10.txt
tt_eval50.txt: maxent_tt50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt50.tagged > tt_eval50.txt
	/usr/bin/tail -28 tt_eval50.txt
tt_eval100.txt: maxent_tt100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt100.tagged > tt_eval100.txt
	/usr/bin/tail -28 tt_eval100.txt
tt_eval500.txt: maxent_tt500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt500.tagged > tt_eval500.txt
	/usr/bin/tail -28 tt_eval500.txt
tt_eval1000.txt: maxent_tt1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt1000.tagged > tt_eval1000.txt
	/usr/bin/tail -28 tt_eval1000.txt
melt_eval.txt: maxent_melt.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt.tagged > melt_eval.txt
	/usr/bin/tail -28 melt_eval.txt
melt_eval10.txt: maxent_melt10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt10.tagged > melt_eval10.txt
	/usr/bin/tail -28 melt_eval10.txt
melt_eval50.txt: maxent_melt50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt50.tagged > melt_eval50.txt
	/usr/bin/tail -28 melt_eval50.txt
melt_eval100.txt: maxent_melt100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt100.tagged > melt_eval100.txt
	/usr/bin/tail -28 melt_eval100.txt
melt_eval500.txt: maxent_melt500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt500.tagged > melt_eval500.txt
	/usr/bin/tail -28 melt_eval500.txt
melt_eval1000.txt: maxent_melt1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt1000.tagged > melt_eval1000.txt
	/usr/bin/tail -28 melt_eval1000.txt
simple_eval.txt: maxent_simple.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple.tagged > simple_eval.txt
	/usr/bin/tail -28 simple_eval.txt
simple_eval10.txt: maxent_simple10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple10.tagged > simple_eval10.txt
	/usr/bin/tail -28 simple_eval10.txt
simple_eval50.txt: maxent_simple50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple50.tagged > simple_eval50.txt
	/usr/bin/tail -28 simple_eval50.txt
simple_eval100.txt: maxent_simple100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple100.tagged > simple_eval100.txt
	/usr/bin/tail -28 simple_eval100.txt
simple_eval500.txt: maxent_simple500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple500.tagged > simple_eval500.txt
	/usr/bin/tail -28 simple_eval500.txt
simple_eval1000.txt: maxent_simple1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple1000.tagged > simple_eval1000.txt
	/usr/bin/tail -28 simple_eval1000.txt

eval_p_s.txt: maxent_p_s.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent_p_s.tagged > eval_p_s.txt
	/usr/bin/tail -28 eval_p_s.txt
eval_p_s10.txt: maxent_p_s10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent_p_s10.tagged > eval_p_s10.txt
	/usr/bin/tail -28 eval_p_s10.txt
eval_p_s50.txt: maxent_p_s50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent_p_s50.tagged > eval_p_s50.txt
	/usr/bin/tail -28 eval_p_s50.txt
eval_p_s100.txt: maxent_p_s100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent_p_s100.tagged > eval_p_s100.txt
	/usr/bin/tail -28 eval_p_s100.txt
eval_p_s500.txt: maxent_p_s500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent_p_s500.tagged > eval_p_s500.txt
	/usr/bin/tail -28 eval_p_s500.txt
eval_p_s1000.txt: maxent_p_s1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent.test maxent_p_s1000.tagged > eval_p_s1000.txt
	/usr/bin/tail -28 eval_p_s1000.txt
tt_eval_p_s.txt: maxent_tt_p_s.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt_p_s.tagged > tt_eval_p_s.txt
	/usr/bin/tail -28 tt_eval_p_s.txt
tt_eval_p_s10.txt: maxent_tt_p_s10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt_p_s10.tagged > tt_eval_p_s10.txt
	/usr/bin/tail -28 tt_eval_p_s10.txt
tt_eval_p_s50.txt: maxent_tt_p_s50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt_p_s50.tagged > tt_eval_p_s50.txt
	/usr/bin/tail -28 tt_eval_p_s50.txt
tt_eval_p_s100.txt: maxent_tt_p_s100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt_p_s100.tagged > tt_eval_p_s100.txt
	/usr/bin/tail -28 tt_eval_p_s100.txt
tt_eval_p_s500.txt: maxent_tt_p_s500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt_p_s500.tagged > tt_eval_p_s500.txt
	/usr/bin/tail -28 tt_eval_p_s500.txt
tt_eval_p_s1000.txt: maxent_tt_p_s1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_tt.test maxent_tt_p_s1000.tagged > tt_eval_p_s1000.txt
	/usr/bin/tail -28 tt_eval_p_s1000.txt
melt_eval_p_s.txt: maxent_melt_p_s.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt_p_s.tagged > melt_eval_p_s.txt
	/usr/bin/tail -28 melt_eval_p_s.txt
melt_eval_p_s10.txt: maxent_melt_p_s10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt_p_s10.tagged > melt_eval_p_s10.txt
	/usr/bin/tail -28 melt_eval_p_s10.txt
melt_eval_p_s50.txt: maxent_melt_p_s50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt_p_s50.tagged > melt_eval_p_s50.txt
	/usr/bin/tail -28 melt_eval_p_s50.txt
melt_eval_p_s100.txt: maxent_melt_p_s100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt_p_s100.tagged > melt_eval_p_s100.txt
	/usr/bin/tail -28 melt_eval_p_s100.txt
melt_eval_p_s500.txt: maxent_melt_p_s500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt_p_s500.tagged > melt_eval_p_s500.txt
	/usr/bin/tail -28 melt_eval_p_s500.txt
melt_eval_p_s1000.txt: maxent_melt_p_s1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_melt.test maxent_melt_p_s1000.tagged > melt_eval_p_s1000.txt
	/usr/bin/tail -28 melt_eval_p_s1000.txt
simple_eval_p_s.txt: maxent_simple_p_s.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple_p_s.tagged > simple_eval_p_s.txt
	/usr/bin/tail -28 simple_eval_p_s.txt
simple_eval_p_s10.txt: maxent_simple_p_s10.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple_p_s10.tagged > simple_eval_p_s10.txt
	/usr/bin/tail -28 simple_eval_p_s10.txt
simple_eval_p_s50.txt: maxent_simple_p_s50.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple_p_s50.tagged > simple_eval_p_s50.txt
	/usr/bin/tail -28 simple_eval_p_s50.txt
simple_eval_p_s100.txt: maxent_simple_p_s100.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple_p_s100.tagged > simple_eval_p_s100.txt
	/usr/bin/tail -28 simple_eval_p_s100.txt
simple_eval_p_s500.txt: maxent_simple_p_s500.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple_p_s500.tagged > simple_eval_p_s500.txt
	/usr/bin/tail -28 simple_eval_p_s500.txt
simple_eval_p_s1000.txt: maxent_simple_p_s1000.tagged
	/Users/moot/checkout/Corpus/bin/evalkmaxent maxent_simple.test maxent_simple_p_s1000.tagged > simple_eval_p_s1000.txt
	/usr/bin/tail -28 simple_eval_p_s1000.txt

eval_pos_err.txt: poserr.tagged
	/Users/moot/checkout/Corpus/bin/evalpos m3.txt poserr.tagged > eval_pos_err.txt
eval_pos_tt_err.txt: poserr_tt.tagged
	/Users/moot/checkout/Corpus/bin/evalpos m3_tt.txt poserr_tt.tagged > eval_pos_tt_err.txt
eval_pos_melt_err.txt: poserr_melt.tagged
	/Users/moot/checkout/Corpus/bin/evalpos m3_melt.txt poserr_melt.tagged > eval_pos_melt_err.txt
eval_pos_simple_err.txt: poserr_simple.tagged
	/Users/moot/checkout/Corpus/bin/evalpos m3_simple.txt poserr_simple.tagged > eval_pos_simple_err.txt
eval_pos.txt: pos.tagged
	/Users/moot/checkout/Corpus/bin/evalpos maxent.test pos.tagged > eval_pos.txt
eval_pos_tt.txt: pos_tt.tagged
	/Users/moot/checkout/Corpus/bin/evalpos maxent_tt.test pos_tt.tagged > eval_pos_tt.txt
eval_pos_melt.txt: pos_melt.tagged
	/Users/moot/checkout/Corpus/bin/evalpos maxent_melt.test pos_melt.tagged > eval_pos_melt.txt
eval_pos_simple.txt: pos_simple.tagged
	/Users/moot/checkout/Corpus/bin/evalpos maxent_simple.test pos_simple.tagged > eval_pos_simple.txt

msg.txt: eval.txt eval10.txt eval50.txt eval100.txt eval500.txt eval1000.txt
	/usr/bin/tail -6 eval.txt > msg.txt
	/usr/bin/tail -6 eval10.txt >> msg.txt
	/usr/bin/tail -6 eval50.txt >> msg.txt
	/usr/bin/tail -6 eval100.txt >> msg.txt
	/usr/bin/tail -6 eval500.txt >> msg.txt
	/usr/bin/tail -6 eval1000.txt >> msg.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg.txt
msg_simple.txt: simple_eval.txt simple_eval10.txt simple_eval50.txt simple_eval100.txt simple_eval500.txt simple_eval1000.txt
	/usr/bin/tail -6 simple_eval.txt > msg_simple.txt
	/usr/bin/tail -6 simple_eval10.txt >> msg_simple.txt
	/usr/bin/tail -6 simple_eval50.txt >> msg_simple.txt
	/usr/bin/tail -6 simple_eval100.txt >> msg_simple.txt
	/usr/bin/tail -6 simple_eval500.txt >> msg_simple.txt
	/usr/bin/tail -6 simple_eval1000.txt >> msg_simple.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg_simple.txt
msg_melt.txt: melt_eval.txt melt_eval10.txt melt_eval50.txt melt_eval100.txt melt_eval500.txt melt_eval1000.txt
	/usr/bin/tail -6 melt_eval.txt > msg_melt.txt
	/usr/bin/tail -6 melt_eval10.txt >> msg_melt.txt
	/usr/bin/tail -6 melt_eval50.txt >> msg_melt.txt
	/usr/bin/tail -6 melt_eval100.txt >> msg_melt.txt
	/usr/bin/tail -6 melt_eval500.txt >> msg_melt.txt
	/usr/bin/tail -6 melt_eval1000.txt >> msg_melt.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg_melt.txt
msg_tt.txt: tt_eval.txt tt_eval10.txt tt_eval50.txt tt_eval100.txt tt_eval500.txt tt_eval1000.txt
	/usr/bin/tail -6 tt_eval.txt > msg_tt.txt
	/usr/bin/tail -6 tt_eval10.txt >> msg_tt.txt
	/usr/bin/tail -6 tt_eval50.txt >> msg_tt.txt
	/usr/bin/tail -6 tt_eval100.txt >> msg_tt.txt
	/usr/bin/tail -6 tt_eval500.txt >> msg_tt.txt
	/usr/bin/tail -6 tt_eval1000.txt >> msg_tt.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg_tt.txt

msg_p_s.txt: eval_p_s.txt eval_p_s10.txt eval_p_s50.txt eval_p_s100.txt eval_p_s500.txt eval_p_s1000.txt
	/usr/bin/tail -6 eval_p_s.txt > msg_p_s.txt
	/usr/bin/tail -6 eval_p_s10.txt >> msg_p_s.txt
	/usr/bin/tail -6 eval_p_s50.txt >> msg_p_s.txt
	/usr/bin/tail -6 eval_p_s100.txt >> msg_p_s.txt
	/usr/bin/tail -6 eval_p_s500.txt >> msg_p_s.txt
	/usr/bin/tail -6 eval_p_s1000.txt >> msg_p_s.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg_p_s.txt
msg_simple_p_s.txt: simple_eval_p_s.txt simple_eval_p_s10.txt simple_eval_p_s50.txt simple_eval_p_s100.txt simple_eval_p_s500.txt simple_eval_p_s1000.txt
	/usr/bin/tail -6 simple_eval_p_s.txt > msg_simple_p_s.txt
	/usr/bin/tail -6 simple_eval_p_s10.txt >> msg_simple_p_s.txt
	/usr/bin/tail -6 simple_eval_p_s50.txt >> msg_simple_p_s.txt
	/usr/bin/tail -6 simple_eval_p_s100.txt >> msg_simple_p_s.txt
	/usr/bin/tail -6 simple_eval_p_s500.txt >> msg_simple_p_s.txt
	/usr/bin/tail -6 simple_eval_p_s1000.txt >> msg_simple_p_s.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg_simple_p_s.txt
msg_melt_p_s.txt: melt_eval_p_s.txt melt_eval_p_s10.txt melt_eval_p_s50.txt melt_eval_p_s100.txt melt_eval_p_s500.txt melt_eval_p_s1000.txt
	/usr/bin/tail -6 melt_eval_p_s.txt > msg_melt_p_s.txt
	/usr/bin/tail -6 melt_eval_p_s10.txt >> msg_melt_p_s.txt
	/usr/bin/tail -6 melt_eval_p_s50.txt >> msg_melt_p_s.txt
	/usr/bin/tail -6 melt_eval_p_s100.txt >> msg_melt_p_s.txt
	/usr/bin/tail -6 melt_eval_p_s500.txt >> msg_melt_p_s.txt
	/usr/bin/tail -6 melt_eval_p_s1000.txt >> msg_melt_p_s.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg_melt_p_s.txt
msg_tt_p_s.txt: tt_eval_p_s.txt tt_eval_p_s10.txt tt_eval_p_s50.txt tt_eval_p_s100.txt tt_eval_p_s500.txt tt_eval_p_s1000.txt
	/usr/bin/tail -6 tt_eval_p_s.txt > msg_tt_p_s.txt
	/usr/bin/tail -6 tt_eval_p_s10.txt >> msg_tt_p_s.txt
	/usr/bin/tail -6 tt_eval_p_s50.txt >> msg_tt_p_s.txt
	/usr/bin/tail -6 tt_eval_p_s100.txt >> msg_tt_p_s.txt
	/usr/bin/tail -6 tt_eval_p_s500.txt >> msg_tt_p_s.txt
	/usr/bin/tail -6 tt_eval_p_s1000.txt >> msg_tt_p_s.txt
	/usr/bin/mail -s "Supertagger Results" richard.moot@me.com < msg_tt_p_s.txt


# The targets in this section test the supertagger performance for the different POS tagsets (that is
# the supertagger results given the correct POS tag)

maxent.tagged: french_eval/weights maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input maxent.test --model french_eval --ifmt "%w|%p|%s \n" > maxent.tagged
maxent10.tagged: french_eval/weights maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input maxent.test --model french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent10.tagged
maxent50.tagged: french_eval/weights maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input maxent.test --model french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent50.tagged
maxent100.tagged: french_eval/weights maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input maxent.test --model french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent100.tagged
maxent500.tagged: french_eval/weights maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input maxent.test --model french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent500.tagged
maxent1000.tagged: french_eval/weights maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input maxent.test --model french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent1000.tagged

maxent_tt.tagged: french_tt_eval/weights maxent_tt.test maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input maxent_tt.test --model french_tt_eval --ifmt "%w|%p|%s \n" > maxent_tt.tagged
maxent_tt10.tagged: french_tt_eval/weights maxent_tt.test maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input maxent_tt.test --model french_tt_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_tt10.tagged
maxent_tt50.tagged: french_tt_eval/weights maxent_tt.test maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input maxent_tt.test --model french_tt_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_tt50.tagged
maxent_tt100.tagged: french_tt_eval/weights maxent_tt.test maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input maxent_tt.test --model french_tt_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_tt100.tagged
maxent_tt500.tagged: french_tt_eval/weights maxent_tt.test maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input maxent_tt.test --model french_tt_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_tt500.tagged
maxent_tt1000.tagged: french_tt_eval/weights maxent_tt.test maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input maxent_tt.test --model french_tt_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_tt1000.tagged

maxent_melt.tagged: melt_french_eval/weights maxent_melt.test maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input maxent_melt.test --model melt_french_eval --ifmt "%w|%p|%s \n" > maxent_melt.tagged
maxent_melt10.tagged: melt_french_eval/weights maxent_melt.test maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input maxent_melt.test --model melt_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_melt10.tagged
maxent_melt50.tagged: melt_french_eval/weights maxent_melt.test maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input maxent_melt.test --model melt_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_melt50.tagged
maxent_melt100.tagged: melt_french_eval/weights maxent_melt.test maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input maxent_melt.test --model melt_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_melt100.tagged
maxent_melt500.tagged: melt_french_eval/weights maxent_melt.test maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input maxent_melt.test --model melt_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_melt500.tagged
maxent_melt1000.tagged: melt_french_eval/weights maxent_melt.test maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input maxent_melt.test --model melt_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_melt1000.tagged

maxent_simple.tagged: simple_french_eval/weights maxent_simple.test maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input maxent_simple.test --model simple_french_eval --ifmt "%w|%p|%s \n" > maxent_simple.tagged
maxent_simple10.tagged: simple_french_eval/weights maxent_simple.test maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input maxent_simple.test --model simple_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_simple10.tagged
maxent_simple50.tagged: simple_french_eval/weights maxent_simple.test maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input maxent_simple.test --model simple_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_simple50.tagged
maxent_simple100.tagged: simple_french_eval/weights maxent_simple.test maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input maxent_simple.test --model simple_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_simple100.tagged
maxent_simple500.tagged: simple_french_eval/weights maxent_simple.test maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input maxent_simple.test --model simple_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_simple500.tagged
maxent_simple1000.tagged: simple_french_eval/weights maxent_simple.test maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input maxent_simple.test --model simple_french_eval --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > maxent_simple1000.tagged

# The targets in the section test the combination of the part-of-speech tagger and the supertagger for evaluation their combined performance

maxent_p_s.tagged: french_eval/weights pos.tagged
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input pos.tagged --model french_eval --ifmt "%w|%p \n" > maxent_p_s.tagged
maxent_p_s10.tagged: french_eval/weights pos.tagged
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input pos.tagged --model french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_p_s10.tagged
maxent_p_s50.tagged: french_eval/weights pos.tagged
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input pos.tagged --model french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_p_s50.tagged
maxent_p_s100.tagged: french_eval/weights pos.tagged
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input pos.tagged --model french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_p_s100.tagged
maxent_p_s500.tagged: french_eval/weights pos.tagged
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input pos.tagged --model french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_p_s500.tagged
maxent_p_s1000.tagged: french_eval/weights pos.tagged
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input pos.tagged --model french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_p_s1000.tagged

maxent_tt_p_s.tagged: french_tt_eval/weights pos_tt.tagged maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input pos_tt.tagged --model french_tt_eval --ifmt "%w|%p \n" > maxent_tt_p_s.tagged
maxent_tt_p_s10.tagged: french_tt_eval/weights pos_tt.tagged maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input pos_tt.tagged --model french_tt_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_tt_p_s10.tagged
maxent_tt_p_s50.tagged: french_tt_eval/weights pos_tt.tagged maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input pos_tt.tagged --model french_tt_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_tt_p_s50.tagged
maxent_tt_p_s100.tagged: french_tt_eval/weights pos_tt.tagged maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input pos_tt.tagged --model french_tt_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_tt_p_s100.tagged
maxent_tt_p_s500.tagged: french_tt_eval/weights pos_tt.tagged maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input pos_tt.tagged --model french_tt_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_tt_p_s500.tagged
maxent_tt_p_s1000.tagged: french_tt_eval/weights pos_tt.tagged maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input pos_tt.tagged --model french_tt_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_tt_p_s1000.tagged

maxent_melt_p_s.tagged: melt_french_eval/weights pos_melt.tagged maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input pos_melt.tagged --model melt_french_eval --ifmt "%w|%p \n" > maxent_melt_p_s.tagged
maxent_melt_p_s10.tagged: melt_french_eval/weights pos_melt.tagged maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input pos_melt.tagged --model melt_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_melt_p_s10.tagged
maxent_melt_p_s50.tagged: melt_french_eval/weights pos_melt.tagged maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input pos_melt.tagged --model melt_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_melt_p_s50.tagged
maxent_melt_p_s100.tagged: melt_french_eval/weights pos_melt.tagged maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input pos_melt.tagged --model melt_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_melt_p_s100.tagged
maxent_melt_p_s500.tagged: melt_french_eval/weights pos_melt.tagged maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input pos_melt.tagged --model melt_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_melt_p_s500.tagged
maxent_melt_p_s1000.tagged: melt_french_eval/weights pos_melt.tagged maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input pos_melt.tagged --model melt_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_melt_p_s1000.tagged

maxent_simple_p_s.tagged: simple_french_eval/weights pos_simple.tagged maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input pos_simple.tagged --model simple_french_eval --ifmt "%w|%p \n" > maxent_simple_p_s.tagged
maxent_simple_p_s10.tagged: simple_french_eval/weights pos_simple.tagged maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input pos_simple.tagged --model simple_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_simple_p_s10.tagged
maxent_simple_p_s50.tagged: simple_french_eval/weights pos_simple.tagged maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --input pos_simple.tagged --model simple_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_simple_p_s50.tagged
maxent_simple_p_s100.tagged: simple_french_eval/weights pos_simple.tagged maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input pos_simple.tagged --model simple_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_simple_p_s100.tagged
maxent_simple_p_s500.tagged: simple_french_eval/weights pos_simple.tagged maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --input pos_simple.tagged --model simple_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_simple_p_s500.tagged
maxent_simple_p_s1000.tagged: simple_french_eval/weights pos_simple.tagged maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input pos_simple.tagged --model simple_french_eval --ifmt "%w|%p \n" --ofmt "%w|%p|%S \n" > maxent_simple_p_s1000.tagged

# Targets for training the POS tagger on the entire corpus, plus the bootstrapped additional files


xbest_pos: extra_pos/weights extra_pos/unknowns extra_pos/number_unknowns
	/bin/cp -f extra_pos/* $(best_prefix)/ext_french_pos_merged
	/bin/cp -f extra_pos/* /Applications/TreebankAnnotator.app/Contents/Resources/POS
xbest_pos_melt: extra_pos_melt/weights extra_pos_melt/unknowns extra_pos_melt/number_unknowns
	/bin/cp -f extra_pos_melt/* $(best_prefix)/ext_french_pos_melt
xbest_pos_tt: extra_pos_tt/weights extra_pos_tt/unknowns extra_pos_tt/number_unknowns
	/bin/cp -f extra_pos_tt/* $(best_prefix)/ext_french_pos_tt
xbest_pos_simple: extra_pos_simple/weights extra_pos_simple/unknowns extra_pos_simple/number_unknowns
	/bin/cp -f extra_pos_simple/* $(best_prefix)/ext_french_pos_simple


extra_pos/weights: mx.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input mx.txt --ifmt "%w|%p|%s \n" --model extra_pos --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete set of data, plus additional bootstrapped data, using the merged POS tag set"
extra_pos_tt/weights: mx_tt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input mx_tt.txt --ifmt "%w|%p|%s \n" --model extra_pos_tt --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete set of data, plus additional bootstrapped data, using the Treetagger POS tag set"
extra_pos_melt/weights: mx_melt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input mx_melt.txt --ifmt "%w|%p|%s \n" --model extra_pos_melt --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete set of data, plus additional bootstrapped data, using the MElt POS tag set"
extra_pos_simple/weights: mx_simple.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input mx_simple.txt --ifmt "%w|%p|%s \n" --model extra_pos_simple --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete set of data, plus additional bootstrapped data, using the simple POS tag set"


# The targets in this section train the supertagger models

french_tt_eval/weights: maxent_tt.test maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input maxent_tt.train --model french_tt_eval --solver bfgs --verbose --niterations 10000 --comment "Training and tagging a test and evaluation corpus respectivly to evaluate performance, using the Treetagger POS tag set"
melt_french_eval/weights: maxent_melt.test maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input maxent_melt.train --model melt_french_eval --solver bfgs --verbose --niterations 10000 --comment "Training and tagging a test and evaluation corpus respectivly to evaluate performance, using the MElt POS tag set"
simple_french_eval/weights: maxent_simple.test maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input maxent_simple.train --model simple_french_eval --solver bfgs --verbose --niterations 10000 --comment "Training and tagging a test and evaluation corpus respectivly to evaluate performance, using the simple POS tag set"
french_eval/weights: maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input maxent.train --model french_eval --solver bfgs --verbose --niterations 10000 --comment "Training and tagging a test and evaluation corpus respectivly to evaluate performance, using the merged POS tag set"

maxent_melt.test: maxent.test
	./merged_to_melt maxent.test > maxent_melt.test
maxent_melt.train: maxent.train
	./merged_to_melt maxent.train > maxent_melt.train
maxent_simple.test: maxent.test
	./merged_to_simple maxent.test > maxent_simple.test
maxent_simple.train: maxent.train
	./merged_to_simple maxent.train > maxent_simple.train
maxent_tt.test: maxent.test
	./merged_to_treetagger maxent.test > maxent_tt.test
maxent_tt.train: maxent.train
	./merged_to_treetagger maxent.train > maxent_tt.train
cmaxent.test: maxent.test
	./compactify maxent.test > cmaxent.test
cmaxent.train: maxent.train
	./compactify maxent.train > cmaxent.train
maxent.test: m2.txt
	/Users/moot/checkout/Corpus/bin/partition m2.txt
maxent.train: m2.txt
	/Users/moot/checkout/Corpus/bin/partition m2.txt

m2_simple.txt: m2.txt
	./merged_to_simple m2.txt > m2_simple.txt
m2_melt.txt: m2.txt
	./merged_to_melt m2.txt > m2_melt.txt
m2_tt.txt: m2.txt
	./merged_to_treetagger m2.txt > m2_tt.txt
m3_simple.txt: m3.txt
	./merged_to_simple m3.txt > m3_simple.txt
m3_melt.txt: m3.txt
	./merged_to_melt m3.txt > m3_melt.txt
m3_tt.txt: m3.txt
	./merged_to_treetagger m3.txt > m3_tt.txt

supertagdiff.txt: m2_10.tagged m2_100.tagged m2_1000.tagged me.chop tagged.chop
	-/usr/bin/diff -y me.chop tagged.chop > supertagdiff.txt
	/Users/moot/checkout/Corpus/bin/evalkmaxent m3.txt m2_1000.tagged > supertagdiff1000.eval
	-/bin/mv supertag_errors.txt supertag_errors1000.txt
	/Users/moot/checkout/Corpus/bin/evalkmaxent m3.txt m2_100.tagged > supertagdiff100.eval
	-/bin/mv supertag_errors.txt supertag_errors100.txt
	/Users/moot/checkout/Corpus/bin/evalkmaxent m3.txt m2_10.tagged > supertagdiff10.eval
	-/bin/cp supertag_errors.txt supertag_errors10.txt

# The targets in this section train the supertagger on the entire corpus, with no data held back for evaluation

french/weights: m2.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input m2.txt --model french --solver bfgs --verbose --niterations 10000 --comment "Training and tagging all words in order to find errors in assigned supertags, using the merged POS tag set"
french_tt/weights: m2_tt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input m2_tt.txt --model french_tt --solver bfgs --verbose --niterations 10000 --comment "Training and tagging all words in order to find errors in assigned supertags, using the Treetagger POS tag set"
french_melt/weights: m2_melt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input m2_melt.txt --model french_melt --solver bfgs --verbose --niterations 10000 --comment "Training and tagging all words in order to find errors in assigned supertags, using the MElt POS tag set"
french_simple/weights: m2_simple.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_super --input m2_simple.txt --model french_simple --solver bfgs --verbose --niterations 10000 --comment "Training and tagging all words in order to find errors in assigned supertags, using the simple POS tag set"

# Targets for training the POS tagger on the training corpus

pos/weights: maxent.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input maxent.train --ifmt "%w|%p|%s \n" --model pos --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger using the merged POS tag set"
pos_tt/weights: maxent_tt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input maxent_tt.train --ifmt "%w|%p|%s \n" --model pos_tt --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger using the Treetagger POS tag set"
pos_melt/weights: maxent_melt.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input maxent_melt.train --ifmt "%w|%p|%s \n" --model pos_melt --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger using the MElt POS tag set"
pos_simple/weights: maxent_simple.train
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input maxent_simple.train --ifmt "%w|%p|%s \n" --model pos_simple --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger using the simple POS tag set"

# Targets for training the POS tagger on the entire corpus

all_pos/weights: m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input m3.txt --ifmt "%w|%p|%s \n" --model all_pos --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete data using the merged POS tag set"
all_pos_tt/weights: m3_tt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input m3_tt.txt --ifmt "%w|%p|%s \n" --model all_pos_tt --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete set of data using the Treetagger POS tag set"
all_pos_melt/weights: m3_melt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input m3_melt.txt --ifmt "%w|%p|%s \n" --model all_pos_melt --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete set of data using the MElt POS tag set"
all_pos_simple/weights: m3_simple.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/train_pos --input m3_simple.txt --ifmt "%w|%p|%s \n" --model all_pos_simple --solver bfgs --niterations 10000 --verbose --comment "Training and tagging the POS tagger on the complete set of data using the simple POS tag set"


# The targets in this section self-tags the corpus to find inconsistencies (not for evaluation, of course!)

poserr.tagged: all_pos/weights all_pos/unknowns all_pos/number_unknowns m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input m3.txt --model all_pos --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > poserr.tagged
poserr_simple.tagged: all_pos_simple/weights all_pos_simple/unknowns all_pos_simple/number_unknowns m3_simple.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input m3_simple.txt --model all_pos_simple --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > poserr_simple.tagged
poserr_melt.tagged: all_pos_melt/weights all_pos_melt/unknowns all_pos_melt/number_unknowns m3_melt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input m3_melt.txt --model all_pos_melt --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > poserr_melt.tagged
poserr_tt.tagged: all_pos_tt/weights all_pos_tt/unknowns all_pos_tt/number_unknowns m3_tt.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input m3_tt.txt --model all_pos_tt --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > poserr_tt.tagged

# The targers in this section tag the held-back data for evaluation purposes.

pos.tagged: pos/weights pos/unknowns pos/number_unknowns maxent.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input maxent.test --model pos --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > pos.tagged
pos_melt.tagged: pos_melt/weights pos_melt/unknowns pos_melt/number_unknowns maxent_melt.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input maxent_melt.test --model pos_melt --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > pos_melt.tagged
pos_simple.tagged: pos_simple/weights maxent_simple.test pos_simple/unknowns pos_simple/number_unknowns
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input maxent_simple.test --model pos_simple --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > pos_simple.tagged
pos_tt.tagged: pos_tt/weights pos_tt/unknowns pos_tt/number_unknowns maxent_tt.test
	/Users/moot/Corpus/WSJ/candc-1.00/bin/pos --input maxent_tt.test --model pos_tt --ifmt "%w|%p|%s \n" --ofmt "%w|%p \n" > pos_tt.tagged

# generate the unknowns files (both overwritten at the end of a training cycle by the train_pos
# script, so need to be updated any times the weights file changes) 

pos/unknowns: pos/weights
	head -3 pos/config > pos/unknowns
	cat unknowns/unknowns >> pos/unknowns
pos/number_unknowns: pos/weights
	head -3 pos/config > pos/number_unknowns
	cat unknowns/number_unknowns >> pos/number_unknowns
pos_melt/unknowns: pos_melt/weights merged_to_melt_unknowns
	head -3 pos_melt/config > pos_melt/unknowns
	cat unknowns/unknowns | ./merged_to_melt_unknowns | sort | uniq >> pos_melt/unknowns
pos_melt/number_unknowns: pos_melt/weights merged_to_melt_unknowns
	head -3 pos_melt/config > pos_melt/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_melt_unknowns | sort | uniq >> pos_melt/number_unknowns
pos_tt/unknowns: pos_tt/weights merged_to_tt_unknowns
	head -3 pos_tt/config > pos_tt/unknowns
	cat unknowns/unknowns | ./merged_to_tt_unknowns | sort | uniq >> pos_tt/unknowns
pos_tt/number_unknowns: pos_tt/weights merged_to_tt_unknowns
	head -3 pos_tt/config > pos_tt/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_tt_unknowns | sort | uniq >> pos_tt/number_unknowns
pos_simple/unknowns: pos_simple/weights merged_to_simple_unknowns
	head -3 pos_simple/config > pos_simple/unknowns
	cat unknowns/unknowns | ./merged_to_simple_unknowns | sort | uniq >> pos_simple/unknowns
pos_simple/number_unknowns: pos_simple/weights merged_to_simple_unknowns
	head -3 pos_simple/config > pos_simple/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_simple_unknowns | sort | uniq >> pos_simple/number_unknowns

all_pos/unknowns: all_pos/weights
	head -3 all_pos/config > all_pos/unknowns
	cat unknowns/unknowns >> all_pos/unknowns
all_pos/number_unknowns: all_pos/weights
	head -3 all_pos/config > all_pos/number_unknowns
	cat unknowns/number_unknowns >> all_pos/number_unknowns
all_pos_melt/unknowns: all_pos_melt/weights merged_to_melt_unknowns
	head -3 all_pos_melt/config > all_pos_melt/unknowns
	cat unknowns/unknowns | ./merged_to_melt_unknowns | sort | uniq >> all_pos_melt/unknowns
all_pos_melt/number_unknowns: all_pos_melt/weights merged_to_melt_unknowns
	head -3 all_pos_melt/config > all_pos_melt/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_melt_unknowns | sort | uniq >> all_pos_melt/number_unknowns
all_pos_tt/unknowns: all_pos_tt/weights merged_to_tt_unknowns
	head -3 all_pos_tt/config > all_pos_tt/unknowns
	cat unknowns/unknowns | ./merged_to_tt_unknowns | sort | uniq >> all_pos_tt/unknowns
all_pos_tt/number_unknowns: all_pos_tt/weights merged_to_tt_unknowns
	head -3 all_pos_tt/config > all_pos_tt/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_tt_unknowns | sort | uniq >> all_pos_tt/number_unknowns
all_pos_simple/unknowns: all_pos_simple/weights merged_to_simple_unknowns
	head -3 all_pos_simple/config > all_pos_simple/unknowns
	cat unknowns/unknowns | ./merged_to_simple_unknowns | sort | uniq >> all_pos_simple/unknowns
all_pos_simple/number_unknowns: all_pos_simple/weights merged_to_simple_unknowns
	head -3 all_pos_simple/config > all_pos_simple/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_simple_unknowns | sort | uniq >> all_pos_simple/number_unknowns

extra_pos/unknowns: extra_pos/weights
	head -3 extra_pos/config > extra_pos/unknowns
	cat unknowns/unknowns >> extra_pos/unknowns
extra_pos/number_unknowns: extra_pos/weights
	head -3 extra_pos/config > extra_pos/number_unknowns
	cat unknowns/number_unknowns >> extra_pos/number_unknowns
extra_pos_melt/unknowns: extra_pos_melt/weights merged_to_melt_unknowns
	head -3 extra_pos_melt/config > extra_pos_melt/unknowns
	cat unknowns/unknowns | ./merged_to_melt_unknowns | sort | uniq >> extra_pos_melt/unknowns
extra_pos_melt/number_unknowns: extra_pos_melt/weights merged_to_melt_unknowns
	head -3 extra_pos_melt/config > extra_pos_melt/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_melt_unknowns | sort | uniq >> extra_pos_melt/number_unknowns
extra_pos_tt/unknowns: extra_pos_tt/weights merged_to_tt_unknowns
	head -3 extra_pos_tt/config > extra_pos_tt/unknowns
	cat unknowns/unknowns | ./merged_to_tt_unknowns | sort | uniq >> extra_pos_tt/unknowns
extra_pos_tt/number_unknowns: extra_pos_tt/weights merged_to_tt_unknowns
	head -3 extra_pos_tt/config > extra_pos_tt/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_tt_unknowns | sort | uniq >> extra_pos_tt/number_unknowns
extra_pos_simple/unknowns: extra_pos_simple/weights merged_to_simple_unknowns
	head -3 extra_pos_simple/config > extra_pos_simple/unknowns
	cat unknowns/unknowns | ./merged_to_simple_unknowns | sort | uniq >> extra_pos_simple/unknowns
extra_pos_simple/number_unknowns: extra_pos_simple/weights merged_to_simple_unknowns
	head -3 extra_pos_simple/config > extra_pos_simple/number_unknowns
	cat unknowns/number_unknowns | ./merged_to_simple_unknowns | sort | uniq >> extra_pos_simple/number_unknowns

merged_to_simple_unknowns: merged_to_simple convert_sed
	./convert_sed merged_to_simple > merged_to_simple_unknowns
	chmod a+x merged_to_simple_unknowns

# tag the corpus on the training data in order to spot inconsistencies

tag_m2: m2.tagged m2_10.tagged m2_100.tagged m2_1000.tagged

m2.tagged: french/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input m3.txt --model french --ifmt "%w|%p|%s \n" > m2.tagged

m2_10.tagged: french/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input m3.txt --model french --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_10.tagged
m2_100.tagged: french/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input m3.txt --model french --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_100.tagged
m2_1000.tagged: french/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input m3.txt --model french --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_1000.tagged

tag_m2_tt: m2_tt.tagged m2_tt_10.tagged m2_tt_100.tagged m2_tt_1000.tagged

m2_tt.tagged: french_tt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input m3_tt.txt --model french_tt --ifmt "%w|%p|%s \n" > m2_tt.tagged

m2_tt_10.tagged: french_tt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input m3_tt.txt --model french_tt --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_tt_10.tagged
m2_tt_100.tagged: french_tt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input m3_tt.txt --model french_tt --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_tt_100.tagged
m2_tt_1000.tagged: french_tt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input m3_tt.txt --model french_tt --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_tt_1000.tagged

tag_m2_melt: m2_melt.tagged m2_melt_10.tagged m2_melt_100.tagged m2_melt_1000.tagged

m2_melt.tagged: french_melt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input m3_melt.txt --model french_melt --ifmt "%w|%p|%s \n" > m2_melt.tagged

m2_melt_10.tagged: french_melt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input m3_melt.txt --model french_melt --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_melt_10.tagged
m2_melt_100.tagged: french_melt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input m3_melt.txt --model french_melt --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_melt_100.tagged
m2_melt_1000.tagged: french_melt/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input m3_melt.txt --model french_melt --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_melt_1000.tagged

tag_m2_simple: m2_simple.tagged m2_simple_10.tagged m2_simple_100.tagged m2_simple_1000.tagged

m2_simple.tagged: french_simple/weights m3.txt
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --input m3_simple.txt --model french_simple --ifmt "%w|%p|%s \n" > m2_simple.tagged

m2_simple_10.tagged: french_simple/weights
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --input m3_simple.txt --model french_simple --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_simple_10.tagged
m2_simple_100.tagged: french_simple/weights
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --input m3_simple.txt --model french_simple --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_simple_100.tagged
m2_simple_1000.tagged: french_simple/weights
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --input m3_simple.txt --model french_simple --ifmt "%w|%p|%s \n" --ofmt "%w|%p|%S \n" > m2_simple_1000.tagged


me.chop: m2.txt
	./chop m2.txt > me.chop

tagged.chop: m2_10.tagged
	./chop m2_10.tagged > tagged.chop

mc.txt: m2.txt compactify
	./compactify m2.txt > mc.txt
m2.txt: maxentdata.txt maxent_cleanup
	./maxent_cleanup maxentdata.txt > m2.txt
m3.txt: m2.txt
	/Users/moot/checkout/Corpus/bin/delete_long m2.txt > m3.txt
mx.txt: m3.txt au_pays_des_Isards.super voyage_aux_Pyrenees.super
	cat m3.txt > mx.txt
	# skip the syntactically annotated part
	tail -3996 au_pays_des_Isards.super >> mx.txt
	cat voyage_aux_Pyrenees.super >> mx.txt
mx_simple.txt: mx.txt
	./merged_to_simple mx.txt > mx_simple.txt
mx_melt.txt: mx.txt
	./merged_to_melt mx.txt > mx_melt.txt
mx_tt.txt: mx.txt
	./merged_to_treetagger mx.txt > mx_tt.txt

# parser files me.pl (unlemmatized) and ml.pl (lemmatized)

me.pl: m2.txt
	./supertag2pl m2.txt > me.pl
ml.pl: me.pl
	./lefff.pl me.pl

# Au pays des Isards (Itipy)

apdi_unparsed1: apdi1_lem.pl
	./grail_light.pl apdi1_lem.pl
	cp unparsed apdi_unparsed1
apdi_unparsed5: apdi5_lem.pl
	./grail_light.pl apdi5_lem.pl
	cp unparsed apdi_unparsed5
apdi_unparsed10: apdi10_lem.pl
	./grail_light.pl apdi10_lem.pl
	cp unparsed apdi_unparsed10
apdi_unparsed50: apdi50_lem.pl
	./grail_light.pl apdi50_lem.pl
	cp unparsed apdi_unparsed50
apdi_unparsed100: apdi100_lem.pl
	./grail_light.pl apdi100_lem.pl
	cp unparsed apdi_unparsed100

apdi_fail1.txt: apdi_unparsed1 apdi1_lem.pl
	-egrep fail apdi_unparsed1 | egrep -v ", 0, " > apdi_fail1.txt
	-egrep limit apdi_unparsed1 > apdi_limit1.txt
apdi_fail5.txt: apdi_unparsed5
	-egrep fail apdi_unparsed5 > apdi_fail5.txt
	-egrep limit apdi_unparsed5 > apdi_limit5.txt
apdi_fail10.txt: apdi_unparsed10
	-egrep fail apdi_unparsed10 > apdi_fail10.txt
	-egrep limit apdi_unparsed10 > apdi_limit10.txt
apdi_fail50.txt: apdi_unparsed50
	-egrep fail apdi_unparsed50 > apdi_fail50.txt
	-egrep limit apdi_unparsed50 > apdi_limit50.txt
apdi_fail100.txt: apdi_unparsed100
	-egrep fail apdi_unparsed100 > apdi_fail100.txt
	-egrep limit apdi_unparsed100 > apdi_limit100.txt
apdi_fail500.txt: apdi_unparsed500
	-egrep fail apdi_unparsed500 > apdi_fail500.txt
	-egrep limit apdi_unparsed500 > apdi_limit500.txt

apdi1_lem.pl: apdi1.pl
	./lefff.pl apdi1.pl
apdi5_lem.pl: apdi5.pl
	./lefff.pl apdi5.pl
apdi10_lem.pl: apdi10.pl
	./lefff.pl apdi10.pl
apdi50_lem.pl: apdi50.pl
	./lefff.pl apdi50.pl
apdi100_lem.pl: apdi100.pl
	./lefff.pl apdi100.pl


au_pays_des_Isards.unparsed1: apdi_fail1.txt
	./get_unparsed.tcl apdi_fail1.txt au_pays_des_Isards.pos > au_pays_des_Isards.unparsed1
au_pays_des_Isards.unparsed5: apdi_fail5.txt
	# include only sentences unparsed at beta=0.5 (those parsed at beta=1 minus those parsed at beta=0.5)
	./get_unparsed.tcl apdi_fail5.txt au_pays_des_Isards.unparsed1 > au_pays_des_Isards.unparsed5
au_pays_des_Isards.unparsed10: apdi_fail10.txt
	# include only sentences unparsed at beta=0.1 (those parsed at beta=0.5 minus those parsed at beta=0.1)
	./get_unparsed.tcl apdi_fail10.txt au_pays_des_Isards.unparsed5 > au_pays_des_Isards.unparsed10
au_pays_des_Isards.unparsed50: apdi_fail50.txt
	# include only sentences unparsed at beta=0.05 (those parsed at beta=0.1 minus those parsed at beta=0.05)
	./get_unparsed.tcl apdi_fail50.txt au_pays_des_Isards.unparsed10 > au_pays_des_Isards.unparsed50
au_pays_des_Isards.unparsed100: apdi_fail100.txt
	# include only sentences unparsed at beta=0.01 (those parsed at beta=0.05 minus those parsed at beta=0.01)
	./get_unparsed.tcl apdi_fail100.txt au_pays_des_Isards.unparsed50 > au_pays_des_Isards.unparsed100
au_pays_des_Isards.unparsed500: apdi_fail500.txt
	# include only sentences unparsed at beta=0.005 (those parsed at beta=0.01 minus those parsed at beta=0.005)
	./get_unparsed.tcl apdi_fail500.txt au_pays_des_Isards.unparsed100 > au_pays_des_Isards.unparsed500

apdi1.pl: au_pays_des_Isards.super
	./supertag2pl au_pays_des_Isards.super > apdi1.pl

apdi5.pl: au_pays_des_Isards.unparsed1
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.5 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.unparsed1 --output au_pays_des_Isards.super5
	./supertag2pl au_pays_des_Isards.super5 > apdi5.pl

apdi10.pl: au_pays_des_Isards.unparsed5
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.unparsed5 --output au_pays_des_Isards.super10
	./supertag2pl au_pays_des_Isards.super10 > apdi10.pl

apdi50.pl: au_pays_des_Isards.unparsed10
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.unparsed10 --output au_pays_des_Isards.super50
	./supertag2pl au_pays_des_Isards.super50 > apdi50.pl

apdi100.pl: au_pays_des_Isards.unparsed50
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.unparsed50 --output au_pays_des_Isards.super100
	./supertag2pl au_pays_des_Isards.super100 > apdi100.pl

apdi500.pl: au_pays_des_Isards.unparsed100
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.unparsed100 --output au_pays_des_Isards.super500
	./supertag2pl au_pays_des_Isards.super500 > apdi500.pl

apdi1000.pl: au_pays_des_Isards.unparsed500
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.unparsed500 --output au_pays_des_Isards.super1000
	./supertag2pl au_pays_des_Isards.super1000 > apdi1000.pl

au_pays_des_Isards.super: au_pays_des_Isards.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --model french --input au_pays_des_Isards.pos --output au_pays_des_Isards.super
au_pays_des_Isards.super10: au_pays_des_Isards.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.pos --output au_pays_des_Isards.super10
au_pays_des_Isards.super50: au_pays_des_Isards.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.pos --output au_pays_des_Isards.super50
au_pays_des_Isards.super100: au_pays_des_Isards.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.pos --output au_pays_des_Isards.super100
au_pays_des_Isards.super500: au_pays_des_Isards.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.pos --output au_pays_des_Isards.super500
au_pays_des_Isards.super1000: au_pays_des_Isards.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --ofmt "%w|%p|%S \n" --model french --input au_pays_des_Isards.pos --output au_pays_des_Isards.super1000

# Voyage au Pyrenees (Itipy)

vap_unparsed1: vap1_lem.pl
	./grail_light.pl vap1_lem.pl
	cp unparsed vap_unparsed1
vap_unparsed5: vap5_lem.pl
	./grail_light.pl vap5_lem.pl
	cp unparsed vap_unparsed5
vap_unparsed10: vap10_lem.pl
	./grail_light.pl vap10_lem.pl
	cp unparsed vap_unparsed10
vap_unparsed50: vap50_lem.pl
	./grail_light.pl vap50_lem.pl
	cp unparsed vap_unparsed50
vap_unparsed100: vap100_lem.pl
	./grail_light.pl vap100_lem.pl
	cp unparsed vap_unparsed100

vap_fail1.txt: vap_unparsed1 vap1_lem.pl
	-egrep fail vap_unparsed1 | egrep -v ", 0, " > vap_fail1.txt
	-egrep limit vap_unparsed1 > vap_limit1.txt
vap_fail5.txt: vap_unparsed5
	-egrep fail vap_unparsed5 > vap_fail5.txt
	-egrep limit vap_unparsed5 > vap_limit5.txt
vap_fail10.txt: vap_unparsed10
	-egrep fail vap_unparsed10 > vap_fail10.txt
	-egrep limit vap_unparsed10 > vap_limit10.txt
vap_fail50.txt: vap_unparsed50
	-egrep fail vap_unparsed50 > vap_fail50.txt
	-egrep limit vap_unparsed50 > vap_limit50.txt
vap_fail100.txt: vap_unparsed100
	-egrep fail vap_unparsed100 > vap_fail100.txt
	-egrep limit vap_unparsed100 > vap_limit100.txt
vap_fail500.txt: vap_unparsed500
	-egrep fail vap_unparsed500 > vap_fail500.txt
	-egrep limit vap_unparsed500 > vap_limit500.txt

vap1_lem.pl: vap1.pl
	./lefff.pl vap1.pl
vap5_lem.pl: vap5.pl
	./lefff.pl vap5.pl
vap10_lem.pl: vap10.pl
	./lefff.pl vap10.pl
vap50_lem.pl: vap50.pl
	./lefff.pl vap50.pl
vap100_lem.pl: vap100.pl
	./lefff.pl vap100.pl


voyage_aux_Pyrenees.unparsed1: vap_fail1.txt
	./get_unparsed.tcl vap_fail1.txt voyage_aux_Pyrenees.pos > voyage_aux_Pyrenees.unparsed1
voyage_aux_Pyrenees.unparsed5: vap_fail5.txt
	# include only sentences unparsed at beta=0.5 (those parsed at beta=1 minus those parsed at beta=0.5)
	./get_unparsed.tcl vap_fail5.txt voyage_aux_Pyrenees.unparsed1 > voyage_aux_Pyrenees.unparsed5
voyage_aux_Pyrenees.unparsed10: vap_fail10.txt
	# include only sentences unparsed at beta=0.1 (those parsed at beta=0.5 minus those parsed at beta=0.1)
	./get_unparsed.tcl vap_fail10.txt voyage_aux_Pyrenees.unparsed5 > voyage_aux_Pyrenees.unparsed10
voyage_aux_Pyrenees.unparsed50: vap_fail50.txt
	# include only sentences unparsed at beta=0.05 (those parsed at beta=0.1 minus those parsed at beta=0.05)
	./get_unparsed.tcl vap_fail50.txt voyage_aux_Pyrenees.unparsed10 > voyage_aux_Pyrenees.unparsed50
voyage_aux_Pyrenees.unparsed100: vap_fail100.txt
	# include only sentences unparsed at beta=0.01 (those parsed at beta=0.05 minus those parsed at beta=0.01)
	./get_unparsed.tcl vap_fail100.txt voyage_aux_Pyrenees.unparsed50 > voyage_aux_Pyrenees.unparsed100
voyage_aux_Pyrenees.unparsed500: vap_fail500.txt
	# include only sentences unparsed at beta=0.005 (those parsed at beta=0.01 minus those parsed at beta=0.005)
	./get_unparsed.tcl vap_fail500.txt voyage_aux_Pyrenees.unparsed100 > voyage_aux_Pyrenees.unparsed500


vap1.pl: voyage_aux_Pyrenees.super
	./supertag2pl voyage_aux_Pyrenees.super > vap1.pl

vap5.pl: voyage_aux_Pyrenees.unparsed1
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.5 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.unparsed1 --output voyage_aux_Pyrenees.super5
	./supertag2pl voyage_aux_Pyrenees.super5 > vap5.pl

vap10.pl: voyage_aux_Pyrenees.unparsed5
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.unparsed5 --output voyage_aux_Pyrenees.super10
	./supertag2pl voyage_aux_Pyrenees.super10 > vap10.pl

vap50.pl: voyage_aux_Pyrenees.unparsed10
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.unparsed10 --output voyage_aux_Pyrenees.super50
	./supertag2pl voyage_aux_Pyrenees.super50 > vap50.pl

vap100.pl: voyage_aux_Pyrenees.unparsed50
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.unparsed50 --output voyage_aux_Pyrenees.super100
	./supertag2pl voyage_aux_Pyrenees.super100 > vap100.pl

vap500.pl: voyage_aux_Pyrenees.unparsed100
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.unparsed100 --output voyage_aux_Pyrenees.super500
	./supertag2pl voyage_aux_Pyrenees.super500 > vap500.pl

vap1000.pl: voyage_aux_Pyrenees.unparsed500
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.unparsed500 --output voyage_aux_Pyrenees.super1000
	./supertag2pl voyage_aux_Pyrenees.super1000 > vap1000.pl

todo_vap.pos: todoVoyage_aux_Pyrenees.pos
	egrep '^[^\#]' todoVoyage_aux_Pyrenees.pos > todo_vap.pos

voyage_aux_Pyrenees.super: todo_vap.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/super --model french --input todo_vap.pos --output voyage_aux_Pyrenees.super
voyage_aux_Pyrenees.super5: voyage_aux_Pyrenees.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.5 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.pos --output voyage_aux_Pyrenees.super5
voyage_aux_Pyrenees.super10: voyage_aux_Pyrenees.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.1 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.pos --output voyage_aux_Pyrenees.super10
voyage_aux_Pyrenees.super50: voyage_aux_Pyrenees.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.05 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.pos --output voyage_aux_Pyrenees.super50
voyage_aux_Pyrenees.super100: voyage_aux_Pyrenees.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.01 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.pos --output voyage_aux_Pyrenees.super100
voyage_aux_Pyrenees.super500: voyage_aux_Pyrenees.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.005 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.pos --output voyage_aux_Pyrenees.super500
voyage_aux_Pyrenees.super1000: voyage_aux_Pyrenees.pos
	/Users/moot/Corpus/WSJ/candc-1.00/bin/msuper --beta 0.001 --ofmt "%w|%p|%S \n" --model french --input voyage_aux_Pyrenees.pos --output voyage_aux_Pyrenees.super1000


verify: formulas uni.tcl doubles
	wc m2.txt

formulas: formulas.pl
	./verify_formulas

formulas.txt: m2.txt
	-/bin/cp formulas.dif formulas.dif.$(date)
	-/bin/cp word_form_pos.txt word_form_pos.old
	-/bin/cp all_formulas.txt all_formulas.bak
	./split_me m2.txt
	-/usr/bin/diff all_formulas.txt all_formulas.bak > formulas.dif
	-/usr/bin/diff -C 1 word_form_pos.txt word_form_pos.old > word_form_pos.dif
bootstrap_formulas.txt: mb.txt
	./count_formulas mb.txt

doubles: word_pos_doubles.txt word_form_pos_doubles.txt

word_pos_doubles.txt: word_pos.txt
	./doubles word_pos.txt > word_pos_doubles.txt
word_form_pos_doubles.txt: word_form_pos.txt
	./multipos word_form_pos.txt > word_form_pos_doubles.txt

formulas.pl: formulas.txt
	./f2pl

word_diff.txt: wp_me.chop wp_sep.chop
	-/usr/bin/diff -y wp_me.chop wp_sep.chop > word_diff.txt

wp_sep.chop: wp_xml.chop word_cleanup
	./word_cleanup wp_xml.chop > wp_sep.chop

wp_me.chop: maxentdata.txt
	./chop_word maxentdata.txt > wp_me.chop

maxentdata.clean: maxentdata.txt maxent_cleanup
	./maxent_cleanup maxentdata.txt > maxentdata.clean

clean_diff.txt: maxentdata.clean
	./chop maxentdata.txt > me.chop
	./chop maxentdata.clean > mc.chop
	-/usr/bin/diff -y me.chop mc.chop > clean_diff.txt

#	NULL NULL wrap TreebankAnnotator.kit

TreebankAnnotator: TreebankAnnotator.kit
	NULL NULL wrap TreebankAnnotator.kit -runtime tclkit-darwin-univ-aqua
	cp TreebankAnnotator /Applications/TreebankAnnotator.app/Contents/MacOS/
TreebankAnnotator.kit: TreebankAnnotator.vfs/lib/app-treebank_annotator/treebank_annotator.tcl
	NULL NULL wrap TreebankAnnotator.kit

Supertag.kit: Supertag.tcl


ta: TreebankAnnotator
