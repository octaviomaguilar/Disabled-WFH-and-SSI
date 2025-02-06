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
*create change in SSI recipients excluding cognitive disability
use "$data/ipums/clean/clean_ssi_recipients.dta", clear

*calculate the change in SSI enrollment pre-post covid:
drop if occ2 == "99" | occ2 == "00"

*Pre-pandemic:
preserve
	keep if year == 2017
	collapse (mean) collects_SSI_2017=collects_SSI [aw=perwt] if disability_noC == 1, by(occ2)
	tempfile 2017
	save `2017', replace
restore

preserve
	keep if year == 2018
	collapse (mean) collects_SSI_2018=collects_SSI [aw=perwt] if disability_noC == 1, by(occ2)
	tempfile 2018
	save `2018', replace
restore


preserve
	keep if year == 2019
	collapse (mean) collects_SSI_2019=collects_SSI [aw=perwt] if disability_noC == 1, by(occ2)
	tempfile 2019
	save `2019', replace
restore


*Post-pandemic average in SSI:

preserve
	keep if year == 2020
	collapse (mean) collects_SSI_2020=collects_SSI [aw=perwt] if disability_noC == 1, by(occ2)
	tempfile 2020
	save `2020', replace
restore

preserve
	keep if year == 2021
	collapse (mean) collects_SSI_2021=collects_SSI [aw=perwt] if disability_noC == 1, by(occ2)
	tempfile 2021
	save `2021', replace
restore

preserve
	keep if year == 2022
	collapse (mean) collects_SSI_2022=collects_SSI [aw=perwt] if disability_noC == 1, by(occ2)
	tempfile 2022
	save `2022', replace
restore

*assign 2023 as the base and append:
keep if year == 2023
collapse (mean) collects_SSI_2023=collects_SSI [aw=perwt] if disability_noC == 1, by(occ2)

merge 1:1 occ2 using `2017', keep(3) nogen
merge 1:1 occ2 using `2018', keep(3) nogen
merge 1:1 occ2 using `2019', keep(3) nogen
merge 1:1 occ2 using `2020', keep(3) nogen
merge 1:1 occ2 using `2021', keep(3) nogen
merge 1:1 occ2 using `2022', keep(3) nogen

egen collects_SSI_2018_2019 = rowmean(collects_SSI_2018 collects_SSI_2019)
egen collects_SSI_2021_2023 = rowmean(collects_SSI_2021 collects_SSI_2022 collects_SSI_2023)

gen delta_collects_SSI = (collects_SSI_2021_2023/collects_SSI_2018_2019)-1

keep occ2 collects_SSI_2018_2019 collects_SSI_2021_2023 delta_collects_SSI
label variable delta_collects_SSI "change in SSI recipients from 2018-2019 to 2021-2023"

*create polynomials of SSI collection: 
gen delta_collects_SSI_sq = delta_collects_SSI^2
gen delta_collects_SSI_cube = delta_collects_SSI^3

save "$ipums/clean/delta_ssi_recipients_noC.dta", replace

*******
**(2)**
*******
*create change in SSI recipients including cognitive disability
use "$data/ipums/clean/clean_ssi_recipients.dta", clear

*calculate the change in SSI enrollment pre-post covid:
drop if occ2 == "99" | occ2 == "00"

*Pre-pandemic:
preserve
	keep if year == 2017
	collapse (mean) collects_SSI_2017=collects_SSI [aw=perwt] if disability == 1, by(occ2)
	tempfile 2017
	save `2017', replace
restore

preserve
	keep if year == 2018
	collapse (mean) collects_SSI_2018=collects_SSI [aw=perwt] if disability == 1, by(occ2)
	tempfile 2018
	save `2018', replace
restore


preserve
	keep if year == 2019
	collapse (mean) collects_SSI_2019=collects_SSI [aw=perwt] if disability == 1, by(occ2)
	tempfile 2019
	save `2019', replace
restore


*Post-pandemic average in SSI:

preserve
	keep if year == 2020
	collapse (mean) collects_SSI_2020=collects_SSI [aw=perwt] if disability == 1, by(occ2)
	tempfile 2020
	save `2020', replace
restore

preserve
	keep if year == 2021
	collapse (mean) collects_SSI_2021=collects_SSI [aw=perwt] if disability == 1, by(occ2)
	tempfile 2021
	save `2021', replace
restore

preserve
	keep if year == 2022
	collapse (mean) collects_SSI_2022=collects_SSI [aw=perwt] if disability == 1, by(occ2)
	tempfile 2022
	save `2022', replace
restore

*assign 2023 as the base and append:
keep if year == 2023
collapse (mean) collects_SSI_2023=collects_SSI [aw=perwt] if disability == 1, by(occ2)

merge 1:1 occ2 using `2017', keep(3) nogen
merge 1:1 occ2 using `2018', keep(3) nogen
merge 1:1 occ2 using `2019', keep(3) nogen
merge 1:1 occ2 using `2020', keep(3) nogen
merge 1:1 occ2 using `2021', keep(3) nogen
merge 1:1 occ2 using `2022', keep(3) nogen

egen collects_SSI_2018_2019 = rowmean(collects_SSI_2018 collects_SSI_2019)
egen collects_SSI_2021_2023 = rowmean(collects_SSI_2021 collects_SSI_2022 collects_SSI_2023)

gen delta_collects_SSI = (collects_SSI_2021_2023/collects_SSI_2018_2019)-1

keep occ2 delta_collects_SSI
label variable delta_collects_SSI "change in SSI recipients from 2018-2019 to 2021-2023"

*create polynomials of SSI collection: 
gen delta_collects_SSI_sq = delta_collects_SSI^2
gen delta_collects_SSI_cube = delta_collects_SSI^3

save "$ipums/clean/delta_ssi_recipients.dta", replace
