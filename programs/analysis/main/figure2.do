cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/disability"
global data "$home/data"
global ipums "$data/ipums"
global crosswalk "$data/crosswalks"
global lcast "$data/lcast"
global acs "$data/acs"
global figures "$home/figures"

*******
**(1)**
*******
/* Figure: Share of WFH by disability status */
*1.1: Load ACS data
use "$ipums/raw/raw_acs.dta", clear

*1.2: clean the data
drop if tranwork == 0
keep if age >= 16
keep if empstat == 1
gen employed =1 if empstat==1
gen wfh = tranwork == 80

*1.3: generate disability indicator
gen disability_noC = 1 if /* diffrem == 2 | */ diffphys == 2 | diffmob == 2 | diffcare == 2 | diffsens == 2 | diffeye == 2 | diffhear == 2
replace disability_noC = 0 if disability_noC == .

*1.4: generate occupation indicator
gen occ2 = substr(occsoc,1,2)

*1.5: compare the wfh shares of disability vs non-disability
preserve
	collapse (mean) wfh [aw=perwt], by(year disability_noC)
	replace wfh = wfh*100
	twoway ///
	    (line wfh year if disability_noC == 1, lcolor(black) lwidth(medium)) ///
	    (line wfh year if disability_noC == 0, lcolor(red) lwidth(medium) lpattern(dash)), ///
	    legend(order(1 "With disability" 2 "No disability") position(6)) ///
	    ylabel(, format(%9.2f)) ///
	    ytitle("Share Working From Home") ///
	    xtitle("")
	*graph export "$figures/figure2.eps", replace
restore 
