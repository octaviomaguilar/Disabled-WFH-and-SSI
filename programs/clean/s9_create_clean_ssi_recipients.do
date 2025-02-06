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
*Create changes in SSI using the full definition of disability: 
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

*generate an indicator if the individual collectes SSI 
gen collects_SSI = 1 if incsupp >=100
replace collects_SSI = 0 if collects_SSI == .

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

save "$data/ipums/clean/clean_ssi_recipients.dta", replace
