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
keep if age >= 16
keep if empstat == 1
gen employed =1 if empstat==1
gen wfh = tranwork == 80

*1.3: generate disability indicator: excluding cognitive disability
gen disability = 1 if /* diffrem == 2 |*/ diffphys == 2 | diffmob == 2 | diffcare == 2 | diffsens == 2 | diffeye == 2 | diffhear == 2
replace disability = 0 if disability == .

*1.4: generate occupation indicator
gen occ2 = substr(occsoc,1,2)

*******
**(2)**
*******
*Pre-pandemic average in SSI:
preserve
	keep if year == 2017
	collapse (mean) wfh_2017=wfh if disability == 0 [aw=perwt], by(occ2)
	tempfile 2017
	save `2017', replace
restore

preserve
	keep if year == 2018
	collapse (mean) wfh_2018=wfh if disability == 0 [aw=perwt], by(occ2)
	tempfile 2018
	save `2018', replace
restore


preserve
	keep if year == 2019
	collapse (mean) wfh_2019=wfh if disability == 0 [aw=perwt], by(occ2)
	tempfile 2019
	save `2019', replace
restore


*Post-pandemic average in SSI:

preserve
	keep if year == 2020
	collapse (mean) wfh_2020=wfh if disability == 0 [aw=perwt], by(occ2)
	tempfile 2020
	save `2020', replace
restore

preserve
	keep if year == 2021
	collapse (mean) wfh_2021=wfh if disability == 0 [aw=perwt], by(occ2)
	tempfile 2021
	save `2021', replace
restore

preserve
	keep if year == 2022
	collapse (mean) wfh_2022=wfh if disability == 0 [aw=perwt], by(occ2)
	tempfile 2022
	save `2022', replace
restore

*assign 2023 as the base and append:
keep if year == 2023
collapse (mean) wfh_2023=wfh if disability == 0 [aw=perwt], by(occ2)

merge 1:1 occ2 using `2017', keep(3) nogen
merge 1:1 occ2 using `2018', keep(3) nogen
merge 1:1 occ2 using `2019', keep(3) nogen
merge 1:1 occ2 using `2020', keep(3) nogen
merge 1:1 occ2 using `2021', keep(3) nogen
merge 1:1 occ2 using `2022', keep(3) nogen

egen wfh_2018_2019 = rowmean(wfh_2018 wfh_2019)
egen wfh_2021_2023 = rowmean(wfh_2021 wfh_2022 wfh_2023)

gen delta_wfh = (wfh_2021_2023/wfh_2018_2019) - 1

keep occ2 delta_wfh
label variable delta_wfh "percent change in WFH from 2018-2019 to 2021-2023"

save "$ipums/clean/delta_wfh.dta", replace
