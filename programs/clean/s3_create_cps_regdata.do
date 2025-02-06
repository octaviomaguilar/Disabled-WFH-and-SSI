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
use "$ipums/clean/cps_clean.dta", clear

*1.1: cleaning occupation and industry information
foreach x in occ ind {
	tostring `x', replace
	drop if `x' == "0"
}
*1.2: generate occ2 and NAICS 2 

*1.3: convert 2010 IPUMS occ to 2018 IPUMS occ 
gen occ_1 = occ
merge m:1 occ_1 using "$crosswalk/update_occ1.dta", keepusing(temp)
replace occ_1 = temp if _m == 3
drop _m temp

*1.4: merge in 2018 IPUMS occ to 2018 OCC SOC crosswalk
merge m:1 occ_1 using "$crosswalk/ipums_occsoc_xwalk.dta", keep(3) keepusing(SOC2018) nogen
gen occ2 = substr(SOC2018,1,2)
drop SOC2018 occ_1 occ

*1.5: merge in dingel & nieman (2020) wfh difficulty by 2-digit occupation
merge m:1 occ2 using "$data/telework/onet_dingel_wfhdiff.dta", keep(3) nogen

*1.6: merge in 2017-2023 remote job postings by 2-digit occupation
merge m:1 occ2 year using "$lcast/remote_occ2_2017_2023.dta", nogen

*1.7: merge in 2017-2023 ACS WFH measure by 2-digit occupation
merge m:1 occ2 year using "$ipums/clean/acs_wfh.dta", nogen

*1.7.1: rescale measures to reflect 1pp changes in level regressions: 
foreach x in remote wfh dingel_wfh {
	replace `x' = `x'*100
} 

*1.8: general demographic recode:
gen female = sex == 2
gen married = marst == 1
replace famsize = 6 if famsize >= 7

gen hispanic = . 
replace hispanic = 1 if inlist(hispan,100,200,300,400,500,600,611,612)
replace hispanic = 0 if hispanic == .

rename race race_raw
gen race = . 
replace race = 1 if race_raw == 100
replace race = 2 if race_raw == 200 
replace race = 3 if race_raw == 651
replace race = 4 if race == .

gen child = nchild >= 1

*1.9: fixed effect groupings
egen Imonth = group(month)
egen Istate = group(state)
egen Istate_year = group(state year)
egen Istate_month = group(state tm)

egen Iocc2 = group(occ2)
egen Iocc2_year = group(occ2 year)
egen Iocc2_month = group(occ2 tm)

gen naics2 = substr(ind,1,2)
egen Inaics2 = group(naics2)
egen Inaics2_year = group(naics2 year)
egen Inaics2_month = group(naics2 tm)

label variable remote "Lightcast remote job postings"
label variable wfh "ACS work from home"

*1.10 inflation adjust SSI measure
*A191RD3A086NBEA: Gross domestic product (implicit price deflator), Index 2017=100
*/
*adjust t-1 since the ssi is lagged.
foreach i of varlist incssi {
replace `i' = `i' *  0.98241 if year == 2017
replace `i' = `i' *  1 if year == 2018
replace `i' = `i' *   1.02291 if year == 2019
replace `i' = `i' * 1.03979 if year == 2020
replace `i' = `i' *  1.05361 if year == 2021
replace `i' = `i' *  1.10172 if year == 2022
replace `i' = `i' *  1.18026 if year == 2023
replace `i' = `i' *  1.22273 if year == 2024
}
/*
*fix lagged reponse of incssi
gen ym = ym(year,month)
format ym %tm
xtset cpsidp ym
gen incssi_corrected = .
bysort cpsidp (ym): replace incssi_corrected = F1.incssi
replace incssi = incssi_corrected
drop incssi_corrected

gen weight_corrected = .
bysort cpsidp (ym): replace weight_corrected = F1.asecwt
replace asecwt = weight_corrected
drop weight_corrected

xtset, clear

*/

/*
foreach i of varlist incssi {
replace `i' = `i' *  0.98241 if year == 2016
replace `i' = `i' *  1 if year == 2017
replace `i' = `i' *   1.02291 if year == 2018
replace `i' = `i' * 1.03979 if year == 2019
replace `i' = `i' *  1.05361 if year == 2020
replace `i' = `i' *  1.10172 if year == 2021
replace `i' = `i' *  1.18026 if year == 2022
replace `i' = `i' *  1.22273 if year == 2023
}
*/
*1.11: merge in occ2 titles
merge m:1 occ2 using "$crosswalk/occ_titles.dta", keep(3) nogen

*1.12: save as a reg dataset:
save "$ipums/clean/cps_regdata.dta", replace
