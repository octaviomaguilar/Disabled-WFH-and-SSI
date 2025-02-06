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
use "$ipums/raw/raw_cps_matched.dta", clear

*1.1: set age restriction
drop if age < 18 | age > 64

*1.2: time indicator
gen tm = ym(year, month)
format tm %tm

*1.3: drop missing or faulty earnings data
drop if earnweek2 >= 1000000 
drop if incdisab == 9999999
drop if incwage != . & incwage > 500000

*1.4: clean employment status indicator to be only 3 bins: 
gen emp_status = . 
replace emp_status = 1 if inlist(empstat,10,12)
replace emp_status = 2 if inlist(empstat,21)
replace emp_status = 3 if inlist(empstat,32,34,36)

*1.5: Generate disability indicator
gen disability = 1 if diffhear == 2 | diffeye == 2 | diffrem == 2 | diffphys == 2 | diffmob == 2 | diffcare == 2 | diffany == 2 
replace disability = 0 if disability == .

*1.5.1: Generate disability indicator that excludes cognitive category. 
gen disability_noC = 1 if diffhear == 2 | diffeye == 2  /* | diffrem == 2 */ | diffphys == 2 | diffmob == 2 | diffcare == 2
replace disability_noC = 0 if disability_noC == .

*1.6: generate employment indicator
gen employed = empstat == 10 | empstat == 12

*1.7: merge in state crosswalk to get two letter FIPS
gen state = statefip
tostring state, replace
replace state = "0" + state if length(state) == 1
merge m:1 state using "$crosswalk/state_xwalk.dta", keep(3) nogen
rename temp state_str

*1.8: save as a clean dataset:
save "$ipums/clean/cps_clean.dta", replace
