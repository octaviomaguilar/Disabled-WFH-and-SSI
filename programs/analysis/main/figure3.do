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
*plotting the percent change in recipients and average income of SSI holders by year: using linear trend:
use "$data/social_security/ssi_raw.dta", clear
keep if year > 2015

foreach i of varlist average_income total_SSI_payments {
replace `i' = `i' * 0.9776 if year == 2016
replace `i' = `i' *  1 if year == 2017
replace `i' = `i' *   1.02291 if year == 2018
replace `i' = `i' * 1.03979 if year == 2019
replace `i' = `i' *  1.05361 if year == 2020
replace `i' = `i' *  1.10172 if year == 2021
replace `i' = `i' *  1.18026 if year == 2022
replace `i' = `i' *  1.22273 if year == 2023
}

*Get the trend for all variables of interest
foreach x in number_enrolled total_SSI_payments total_recipients_18_64 average_income number_applications {
    gen log_`x' = log(`x')                  // Create the log value
    reg log_`x' year if year >= 2016 & year < 2019     // Regress log variable on time variable: fitting specified time. 
    predict log_trend, xb                   // Predict the fitted values
    gen trend_`x' = exp(log_trend)          // Transform back to level form
    drop log_trend log_`x'                  
}

*rescale for ease of interpretation for figures:
foreach x in number_enrolled trend_number_enrolled total_recipients_18_64 trend_total_recipients_18_64 number_applications trend_number_applications {
	replace `x' = `x'/1000000
}

*Figure 3 Panel A: total recipients: Trend vs Actual 
twoway ///
    line total_recipients_18_64 year, lcolor(black) lpattern(solid) || ///
    line trend_total_recipients_18_64 year, lcolor(red) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2016-2019") position(6)) ///
    ytitle("Total Recipients, Millions") ///
    ylabel(, format(%9.2f)) ///
    xtitle("") 
    graph export "$figures/figure3a.eps", replace
 
*Figure 3 Panel B: average income: Trend vs Actual 
twoway ///
    line average_income year, lcolor(black) lpattern(solid) || ///
    line trend_average_income year, lcolor(red) lpattern(dash) ///
    legend(order(1 "Actual" 2 "Log Linear Trend 2016-2019") position(6)) ///
    ytitle("Average Labor Income") ///
    xtitle("") 
    graph export "$figures/figure3b.eps", replace

*******
**(2)**
*******
*Create figure that shows percent change in SSI Income in Low vs High WFH occupations: 

use "$ipums/raw/raw_acs.dta", clear
*clean acs the data to get WFH measure by occupation-year:

drop if tranwork == 0
keep if age >= 16
keep if empstat == 1
gen employed =1 if empstat==1
gen wfh = tranwork == 80

*generate disability indicator
gen disability = 1 if diffrem == 2 | diffphys == 2 | diffmob == 2 | diffcare == 2 | diffsens == 2 | diffeye == 2 | diffhear == 2
replace disability = 0 if disability == .

*generate occupation indicator
gen occ2 = substr(occsoc,1,2)

*calculate average wfh for those who do not have a disability: 
collapse (mean) wfh [aw=perwt]  if disability == 0, by(year occ2)
tempfile f 
save `f', replace

*Load SSI data from the ACS:
use "$data/ipums/raw/raw_acs_ssi.dta", clear

drop if age < 18 | age > 64

*Generate disability indicator that excludes cognitive category. 
gen disability_noC = 1 if diffphys == 2 | diffmob == 2  | diffcare == 2 | diffeye == 2 | diffhear == 2
replace disability_noC = 0 if disability_noC == .

/*
*Generate disability indicator that includes cognitive category. 
gen disability = 1 if diffphys == 2 | diffmob == 2  | diffcare == 2 | diffeye == 2 | diffhear == 2 | diffrem == 2
replace disability = 0 if disability == .
*/

*drop missing information on SSI. 
drop if incsupp == 99999

*generate 2-digit occupation code
replace occsoc = subinstr(occsoc, " ", "", .)
replace occsoc = "00" if occsoc == "0"
gen occ2 = substr(occsoc,1,2)

*inflation adjust SSI measure
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

merge m:1 year occ2 using `f', keep(3) nogen

gen above_1SD = 0 
forval i = 2017/2023 {
	sum wfh [aw=perwt] if year == `i'
	replace above_1SD = 1 if year == `i' & wfh > 2*r(sd)
}

*Percent change for individuals with disabilities
preserve
	collapse (mean) incsupp [aw=perwt] if disability_noC == 1 & above_1SD == 0, by(year)
	gen base_incsupp = incsupp if year == 2019
	sum base_incsupp, d
	replace base_incsupp = r(mean) if missing(base_incsupp)
	gen pct_change = ((incsupp/base_incsupp)-1)*100
	gen low_wfh = 1
	tempfile pct_change
	save `pct_change', replace
restore 

*Percent change for individuals with no disabilities
collapse (mean) incsupp [aw=perwt] if disability_noC == 1 & above_1SD == 1, by(year)
gen base_incsupp = incsupp if year == 2019
sum base_incsupp, d
replace base_incsupp = r(mean) if missing(base_incsupp)
gen pct_change = ((incsupp/base_incsupp)-1)*100
gen low_wfh = 0

append using `pct_change'

*Figure 3 Panel C: plot percent change in SSI over time by WFH status
twoway ///
    (line pct_change year if low_wfh == 1, lcolor(black) lwidth(medium)) ///
    (line pct_change year if low_wfh == 0, lcolor(red) lwidth(medium) lpattern(dash)), ///
    legend(order(1 "Low WFH" 2 "High WFH") position(6)) ///
    ylabel(, format(%9.2f)) ///
    ytitle("Percent Change") ///
    xtitle("")
graph export "$figures/figure3c.eps", replace

