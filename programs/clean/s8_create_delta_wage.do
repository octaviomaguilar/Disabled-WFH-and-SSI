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
*Create changes in wages using the full definition of disability: 

use "$ipums/clean/cps_regdata.dta", clear

*Pre-pandemic average in SSI:
preserve
	keep if year == 2017
	collapse (mean) incwage_2017=incwage [aw=asecwt] if disability == 1, by(occ2)
	tempfile 2017
	save `2017', replace
restore

preserve
	keep if year == 2018
	collapse (mean) incwage_2018=incwage [aw=asecwt] if disability == 1, by(occ2)
	tempfile 2018
	save `2018', replace
restore


preserve
	keep if year == 2019
	collapse (mean) incwage_2019=incwage [aw=asecwt] if disability == 1, by(occ2)
	tempfile 2019
	save `2019', replace
restore


*Post-pandemic average in SSI:

preserve
	keep if year == 2020
	collapse (mean) incwage_2020=incwage [aw=asecwt] if disability == 1, by(occ2)
	tempfile 2020
	save `2020', replace
restore

preserve
	keep if year == 2021
	collapse (mean) incwage_2021=incwage [aw=asecwt] if disability == 1, by(occ2)
	tempfile 2021
	save `2021', replace
restore

preserve
	keep if year == 2022
	collapse (mean) incwage_2022=incwage [aw=asecwt] if disability == 1, by(occ2)
	tempfile 2022
	save `2022', replace
restore

*assign 2023 as the base and append:
keep if year == 2023
collapse (mean) incwage_2023=incwage [aw=asecwt] if disability == 1, by(occ2)

merge 1:1 occ2 using `2017', keep(3) nogen
merge 1:1 occ2 using `2018', keep(3) nogen
merge 1:1 occ2 using `2019', keep(3) nogen
merge 1:1 occ2 using `2020', keep(3) nogen
merge 1:1 occ2 using `2021', keep(3) nogen
merge 1:1 occ2 using `2022', keep(3) nogen

egen wage_2018_2019 = rowmean(incwage_2018 incwage_2019)
egen wage_2021_2023 = rowmean(incwage_2021 incwage_2022 incwage_2023)

gen delta_wage = (wage_2021_2023/wage_2018_2019) - 1

replace delta_wage = 0 if delta_wage ==.

keep occ2 delta_wage
label variable delta_wage "change in wages from 2018-2019 to 2021-2023"

save "$ipums/clean/delta_wage.dta", replace


*******
**(1)**
*******
*Create changes in wages using the definition of disability that excludes cognitive.

use "$ipums/clean/cps_regdata.dta", clear

*Pre-pandemic average in SSI:
preserve
	keep if year == 2017
	collapse (mean) incwage_2017=incwage [aw=asecwt] if disability_noC == 1, by(occ2)
	tempfile 2017
	save `2017', replace
restore

preserve
	keep if year == 2018
	collapse (mean) incwage_2018=incwage [aw=asecwt] if disability_noC == 1, by(occ2)
	tempfile 2018
	save `2018', replace
restore


preserve
	keep if year == 2019
	collapse (mean) incwage_2019=incwage [aw=asecwt] if disability_noC == 1, by(occ2)
	tempfile 2019
	save `2019', replace
restore


*Post-pandemic average in SSI:

preserve
	keep if year == 2020
	collapse (mean) incwage_2020=incwage [aw=asecwt] if disability_noC == 1, by(occ2)
	tempfile 2020
	save `2020', replace
restore

preserve
	keep if year == 2021
	collapse (mean) incwage_2021=incwage [aw=asecwt] if disability_noC == 1, by(occ2)
	tempfile 2021
	save `2021', replace
restore

preserve
	keep if year == 2022
	collapse (mean) incwage_2022=incwage [aw=asecwt] if disability_noC == 1, by(occ2)
	tempfile 2022
	save `2022', replace
restore

*assign 2023 as the base and append:
keep if year == 2023
collapse (mean) incwage_2023=incwage [aw=asecwt] if disability_noC == 1, by(occ2)

merge 1:1 occ2 using `2017', keep(3) nogen
merge 1:1 occ2 using `2018', keep(3) nogen
merge 1:1 occ2 using `2019', keep(3) nogen
merge 1:1 occ2 using `2020', keep(3) nogen
merge 1:1 occ2 using `2021', keep(3) nogen
merge 1:1 occ2 using `2022', keep(3) nogen

egen wage_2018_2019 = rowmean(incwage_2018 incwage_2019)
egen wage_2021_2023 = rowmean(incwage_2021 incwage_2022 incwage_2023)

gen delta_wage = (wage_2021_2023/wage_2018_2019) - 1

replace delta_wage = 0 if delta_wage ==.

keep occ2 delta_wage
label variable delta_wage "change in wages from 2018-2019 to 2021-2023 using no cognitive difficulties definition"

save "$ipums/clean/delta_wage_noC.dta", replace

