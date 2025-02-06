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
*Percent change in employment by disability status
use "$ipums/clean/cps_clean.dta", clear

*1.1: Percent change for individuals with disabilities
preserve
	collapse (mean) employed [aw=hwtfinl] if disability_noC == 1, by(tm)
	gen base_employment = employed if tm == ym(2019, 1)
	sum base_employment, d
	replace base_employment = r(mean) if missing(base_employment)
	gen pct_change = ((employed/base_employment)-1)*100
	gen disability_noC = 1
	tempfile pct_change
	save `pct_change', replace
restore 

*1.2: Percent change for individuals with no disabilities
collapse (mean) employed [aw=hwtfinl] if disability_noC == 0, by(tm)
gen base_employment = employed if tm == ym(2019, 1)
sum base_employment, d
replace base_employment = r(mean) if missing(base_employment)
gen pct_change = ((employed/base_employment)-1)*100
gen disability_noC = 0

append using `pct_change'

*1.3: plot percent change in employment over time by disability status
twoway ///
    (line pct_change tm if disability_noC == 1, lcolor(black) lwidth(medium)) ///
    (line pct_change tm if disability_noC == 0, lcolor(red) lwidth(medium) lpattern(dash)), ///
    legend(order(1 "With disability" 2 "No disability") position(6)) ///
    ylabel(, format(%9.2f)) ///
    ytitle("Percent Change") ///
    xtitle("")
graph export "$figures/figure1a.eps", replace

*******
**(2)**
*******
*Population with disability decomposed into employment status
use "$ipums/clean/cps_clean.dta", clear

keep if disability_noC == 1

*2.1: Create dummy variables for each employment status
gen emp = (emp_status == 1)
gen unemp = (emp_status == 2)
gen nlf = (emp_status == 3)

*2.2: Collapse data to calculate mean for each status by time
collapse (mean) emp unemp nlf [aw=hwtfinl], by(tm)

*2.3: Calculate base levels for January 2019
gen base_emp = emp if tm == ym(2019,1)
sum base_emp, d
replace base_emp = r(mean) if base_emp == .

gen base_unemp = unemp if tm == ym(2019,1)
sum base_unemp, d
replace base_unemp = r(mean) if base_unemp == .

gen base_nlf = nlf if tm == ym(2019, 1)
sum base_nlf, d
replace base_nlf = r(mean) if base_nlf == .

*2.4: Calculate percentage point changes relative to January 2019
gen pct_change_emp = (emp - base_emp)*100
gen pct_change_unemp = (unemp - base_unemp)*100
gen pct_change_nlf = (nlf - base_nlf)*100

*2.5: Plot the pp change in disability employment by LF status
twoway ///
    (line pct_change_emp tm, lcolor(black) lwidth(medium)) ///
    (line pct_change_unemp tm, lcolor(green) lwidth(medium) lpattern(dash)) ///
    (line pct_change_nlf tm, lcolor(red) lwidth(medium) lpattern(dash)), ///
    legend(order(1 "Employed" 2 "Unemployed" 3 "Not in the labor force")position(6)) ///
    ylabel(, format(%9.2f)) ///
    ytitle("Percentage Point Change") ///
    xtitle("")
graph export "$figures/figure1b.eps", replace
