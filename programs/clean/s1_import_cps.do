cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/disability"
global data "$home/data"
global ipums "$data/ipums"
global crosswalk "$data/crosswalks"

*******
**(1)**
*******
*1.1: Load CPS-ASEC data
use "$ipums/raw/raw_cps_asec.dta", clear

*1.2: only keep valid CPS-IDs
drop if cpsidp == 0

*1.3: only keep ASEC obs (asecflag = 0 means it is apart of the oversample)
keep if asecflag == 1

*1.4: check for duplicates. We want zero for the merging process. 
*duplicates report year month cpsidp pernum

*1.5: save as a temp file to merge with CPS monthly files
tempfile asec 
save `asec', replace 

*******
**(2)**
*******
*2.1: Load CPS monthly data
use "$ipums/raw/raw_cps.dta", clear

*2.2: check for duplicates. We want zero for the merging process. 
*duplicates report year month cpsidp pernum

*2.3: merge CPS-ASEC data from block 1. 
merge 1:1 year month cpsidp pernum using `asec', nogen 
*out of all obs roughly 6.6% are matched to asec.

*1.4: save as raw dataset
save "$ipums/raw/raw_cps_matched.dta", replace
