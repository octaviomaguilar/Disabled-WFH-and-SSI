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
*Pre-period: 2018-2019
use "$ipums/clean/cps_regdata.dta", clear

*merge in delta wage data: including cognitive disability
merge m:1 occ2 using "$ipums/clean/delta_wage.dta", keep(3) nogen

*merge in delta SSI recipients data: including cognitive disability
merge m:1 occ2 using "$ipums/clean/delta_ssi_recipients.dta", keep(3) nogen 

*merge in compositional data 
merge m:1 occ2 using "$ipums/clean/polynomial_disability_emp.dta", keep(3) nogen

*******
**(2)**
*******
*No controls
reg incssi dingel_wfh if year >= 2018 & year <= 2019 & disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estimates store m1, title("(1)")

*adding controls
reg incssi dingel_wfh i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI if year >= 2018 & year <= 2019 & disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estimates store m2, title("(2)")

*adding FEs
reghdfe incssi dingel_wfh i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI if year >= 2018 & year <= 2019 & disability == 1 [aw=wtfinl], absorb(Istate_month Inaics2_month Imonth)
estadd local fe Yes
estadd local controls Yes
estimates store m3, title("(3)")

*******
**(3)**
*******
*post-period: 2021-2023

*No controls
reg incssi dingel_wfh if year >= 2021 & year <= 2023 & disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estimates store m4, title("(1)")

*adding controls
reg incssi dingel_wfh i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI if year >= 2021 & year <= 2023 & disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estimates store m5, title("(2)")

*adding FEs
reghdfe incssi dingel_wfh i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI if year >= 2021 & year <= 2023 & disability == 1 [aw=wtfinl], absorb(Istate_month Inaics2_month Imonth)
estadd local fe Yes
estadd local controls Yes
estimates store m6, title("(3)")

*******
**(4)**
*******
/* Pre-period results 2018-2019 */
estout m1 m2 m3, cells(b(fmt(%9.3f)) se(par fmt(%9.3f))) keep(dingel_wfh) stats(r2 N fe controls, fmt(%9.2f %9.0fc ) label(R-sqr N "Fixed Effects" "Controls")) legend label

/* Post-period results 2021-2023 */
estout m4 m5 m6, cells(b(fmt(%9.3f)) se(par fmt(%9.3f))) keep(dingel_wfh) stats(r2 N fe controls, fmt(%9.2f %9.0fc ) label(R-sqr N "Fixed Effects" "Controls")) legend label
