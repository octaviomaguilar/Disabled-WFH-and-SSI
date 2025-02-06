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
*create polynomials for disability excluding cognitive:
use "$ipums/clean/cps_regdata.dta", clear

/* Pre-COVID Averages */
*disability
preserve
keep if tm >= tm(2018m1) & tm <= tm(2019m12)
collapse (mean) emp_dis_pre=employed if disability_noC==1 [aw=hwtfinl], by(occ2)
tempfile pre_covid_dis
save `pre_covid_dis', replace
restore

*no disability
preserve
keep if tm >= tm(2018m1) & tm <= tm(2019m12)
collapse (mean) emp_ndis_pre=employed if disability_noC==0 [aw=hwtfinl], by(occ2)
tempfile pre_covid_ndis
save `pre_covid_ndis', replace
restore

/* Post-COVID Averages */
*disability
preserve
keep if tm >= tm(2021m1) & tm <= tm(2023m12)
collapse (mean) emp_dis_post=employed if disability_noC==1 [aw=hwtfinl], by(occ2)
tempfile post_covid_dis
save `post_covid_dis', replace
restore

*no disability
keep if tm >= tm(2021m1) & tm <= tm(2023m12)
collapse (mean) emp_ndis_post=employed if disability_noC==0 [aw=hwtfinl], by(occ2)

*Merge Pre- and Post-COVID Data
merge 1:1 occ2 using `pre_covid_dis', nogen
merge 1:1 occ2 using `pre_covid_ndis', nogen
merge 1:1 occ2 using `post_covid_dis', nogen

* Calculate Percent Changes
gen pct_change_dis = (emp_dis_post - emp_dis_pre) / emp_dis_pre * 100
gen pct_change_ndis = (emp_ndis_post - emp_ndis_pre) / emp_ndis_pre * 100

* Create Polynomial Terms
gen pct_change_ndis_sq = pct_change_ndis^2
gen pct_change_ndis_cube = pct_change_ndis^3

label variable pct_change_dis "Percent change in disability employment"
label variable pct_change_ndis "Percent change in non-disability employment"
label variable pct_change_ndis_sq "Percent change squared in non-disability employment"
label variable pct_change_ndis_cube "Percent change in cubed in non-disability employment"

keep occ2 pct_change_dis pct_change_ndis pct_change_ndis_sq pct_change_ndis_cube

save "$ipums/clean/polynomial_disability_noC_emp.dta", replace

*******
**(2)**
*******
*create polynomials for disability including cognitive:
use "$ipums/clean/cps_regdata.dta", clear

/* Pre-COVID Averages */
*disability
preserve
keep if tm >= tm(2018m1) & tm <= tm(2019m12)
collapse (mean) emp_dis_pre=employed if disability==1 [aw=hwtfinl], by(occ2)
tempfile pre_covid_dis
save `pre_covid_dis', replace
restore

*no disability
preserve
keep if tm >= tm(2018m1) & tm <= tm(2019m12)
collapse (mean) emp_ndis_pre=employed if disability==0 [aw=hwtfinl], by(occ2)
tempfile pre_covid_ndis
save `pre_covid_ndis', replace
restore

/* Post-COVID Averages */
*disability
preserve
keep if tm >= tm(2021m1) & tm <= tm(2023m12)
collapse (mean) emp_dis_post=employed if disability==1 [aw=hwtfinl], by(occ2)
tempfile post_covid_dis
save `post_covid_dis', replace
restore

*no disability
keep if tm >= tm(2021m1) & tm <= tm(2023m12)
collapse (mean) emp_ndis_post=employed if disability==0 [aw=hwtfinl], by(occ2)

*Merge Pre- and Post-COVID Data
merge 1:1 occ2 using `pre_covid_dis', nogen
merge 1:1 occ2 using `pre_covid_ndis', nogen
merge 1:1 occ2 using `post_covid_dis', nogen

* Calculate Percent Changes
gen pct_change_dis = (emp_dis_post - emp_dis_pre) / emp_dis_pre * 100
gen pct_change_ndis = (emp_ndis_post - emp_ndis_pre) / emp_ndis_pre * 100

* Create Polynomial Terms
gen pct_change_ndis_sq = pct_change_ndis^2
gen pct_change_ndis_cube = pct_change_ndis^3

label variable pct_change_dis "Percent change in disability employment"
label variable pct_change_ndis "Percent change in non-disability employment"
label variable pct_change_ndis_sq "Percent change squared in non-disability employment"
label variable pct_change_ndis_cube "Percent change in cubed in non-disability employment"

keep occ2 pct_change_dis pct_change_ndis pct_change_ndis_sq pct_change_ndis_cube

save "$ipums/clean/polynomial_disability_emp.dta", replace

