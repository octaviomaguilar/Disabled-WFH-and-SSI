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
use "$ipums/clean/cps_clean.dta", clear

/* Changes in disability pre-post covid: non-cognitive vs with cognitive */
preserve
	collapse (mean) disability [aw=hwtfinl], by(tm)
	gen base_disability = disability if tm == ym(2019, 1)
	sum base_disability, d
	replace base_disability = r(mean) if missing(base_disability)
	gen pct_change = ((disability/base_disability)-1)*100
	gen first = 1
	tempfile pct_change
	save `pct_change', replace
restore 

*1.2: Percent change for individuals with no disabilities
collapse (mean) disability_noC [aw=hwtfinl], by(tm)
gen base_disability_noC = disability_noC if tm == ym(2019, 1)
sum base_disability_noC, d
replace base_disability_noC = r(mean) if missing(base_disability_noC)
gen pct_change = ((disability_noC/base_disability_noC)-1)*100
gen first = 0
append using `pct_change'

*1.3: plot percent change in employment over time by disability status
twoway ///
    (line pct_change tm if first == 1, lcolor(black) lwidth(medium)) ///
    (line pct_change tm if first == 0, lcolor(red) lwidth(medium) lpattern(dash)), ///
    legend(order(1 "With cognitive difficulty" 2 "Not including cognitive difficulty") position(6)) ///
    ylabel(, format(%9.2f)) ///
    ytitle("Percent Change") ///
    xtitle("")
*graph export "$figures/slides_compositional_changes.eps", replace

*******
**(2)**
*******
*Create changes in SSI using ACS data: 
use "$data/ipums/raw/raw_acs_ssi.dta", clear

drop if age < 18 | age > 64

*Generate disability indicator that excludes cognitive category. 
gen disability_noC = 1 if diffphys == 2 | diffmob == 2  | diffcare == 2 | diffeye == 2 | diffhear == 2
replace disability_noC = 0 if disability_noC == .

*Generate disability indicator that includes cognitive category. 
gen disability = 1 if diffphys == 2 | diffmob == 2  | diffcare == 2 | diffeye == 2 | diffhear == 2 | diffrem == 2
replace disability = 0 if disability == .

*drop missing information on SSI. 
drop if incsupp == 99999

*generate 2-digit occupation code
replace occsoc = subinstr(occsoc, " ", "", .)
replace occsoc = "00" if occsoc == "0"
gen occ2 = substr(occsoc,1,2)

*1.10 inflation adjust SSI measure
*A191RD3A086NBEA: Gross domestic product (implicit price deflator), Index 2017=100
*/
foreach i of varlist incsupp {
replace `i' = `i' *  1 if year == 2017
replace `i' = `i' *   1.02291 if year == 2018
replace `i' = `i' * 1.03979 if year == 2019
replace `i' = `i' *  1.05361 if year == 2020
replace `i' = `i' *  1.10172 if year == 2021
replace `i' = `i' *  1.18026 if year == 2022
replace `i' = `i' *  1.22273 if year == 2023
}

merge m:1 occ2 year using "$lcast/remote_occ2_2017_2023.dta", nogen

*Percent change for individuals with disabilities
collapse (mean) incsupp [aw=perwt] if disability_noC == 1 & empstat==1, by(year)
gen base_incssi = incsupp if year == 2019
sum base_incssi, d
replace base_incssi = r(mean) if missing(base_incssi)
gen pct_change = ((incsupp/base_incssi)-1)*100

twoway line pct_change year, lcolor(black)  ylabel(, format(%9.0f)) ytitle("Percent Change") xtitle("")
*graph export "$figures/slides_SSI_trend_ACS.eps", replace

*******
**(3)**
*******
*plotting the trend who collect SSI by year if they are disabled: this matches social security reported trend. 
use "$data/ipums/clean/clean_ssi_recipients.dta", clear

preserve
	collapse (mean) collects_SSI [aw=perwt] if disability_noC == 1, by(year)
	twoway line collects_SSI year, ytitle("Share of SSI Recipients") lcolor(black) xtitle("") ylabel(, format(%9.2f))
	*graph export "$figures/misc_share_SSI_recipients.eps", replace
restore
