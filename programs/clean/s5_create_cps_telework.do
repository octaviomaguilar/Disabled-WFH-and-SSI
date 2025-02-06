cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/disability"
global data "$home/data"
global ipums "$data/ipums"
global crosswalk "$data/crosswalks"
global lcast "$data/lcast"
global acs "$data/acs"

*******
**(1)**
*******
*Create CPS telework measure using the full definition of disability: 
use "$ipums/clean/cps_regdata.dta", clear

gen cps_telework = telwrkpay == 1
collapse (mean) cps_telework [aw=wtfinl] if disability == 0, by(occ2 year)
keep if inlist(year,2022,2023)
*rescale to reflect 1pp
replace cps_telework=cps_telework*100

label variable cps_telework "CPS Telework"
save "$ipums/clean/cps_telework.dta", replace

*******
**(2)**
*******
*Create CPS telework measure using the definition of disability that excludes cognitive.
use "$ipums/clean/cps_regdata.dta", clear

gen cps_telework = telwrkpay == 1
collapse (mean) cps_telework [aw=wtfinl] if disability_noC == 0, by(occ2 year)
keep if inlist(year,2022,2023)
*rescale to reflect 1pp
replace cps_telework=cps_telework*100

label variable cps_telework "CPS Telework using no cognitive difficulties definition"
save "$ipums/clean/cps_telework_noC.dta", replace
