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
*1.1: Load ACS data
use "$ipums/raw/raw_acs.dta", clear

*1.2: clean the data
drop if tranwork == 0
keep if age >= 18
keep if empstat == 1
gen employed = empstat ==1
gen wfh = tranwork == 80

*1.3: generate disability indicator: excluding cognitive disability
gen disability = 1 if /* diffrem == 2 |*/ diffphys == 2 | diffmob == 2 | diffcare == 2 | diffsens == 2 | diffeye == 2 | diffhear == 2
replace disability = 0 if disability == .

*1.4: generate occupation indicator
gen occ2 = substr(occsoc,1,2)

*1.6: share of wfh by occupation-year for those who are not disabled. 
collapse (mean) wfh if disability == 0 [aw=perwt], by(occ2 year)

*1.7: save as a clean dataset
save "$ipums/clean/acs_wfh.dta", replace



