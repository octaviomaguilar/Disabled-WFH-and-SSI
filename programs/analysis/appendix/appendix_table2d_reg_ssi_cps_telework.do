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
use "$ipums/clean/cps_regdata.dta", clear

*merge in cps telework data: including cognitive disability
merge m:1 occ2 year using "$ipums/clean/cps_telework.dta", keep(3) nogen

*merge in delta wage data: including cognitive disability
merge m:1 occ2 using "$ipums/clean/delta_wage.dta", keep(3) nogen

*merge in delta SSI recipients data: including cognitive disability
merge m:1 occ2 using "$ipums/clean/delta_ssi_recipients.dta", keep(3) nogen 

*merge in compositional data 
merge m:1 occ2 using "$ipums/clean/polynomial_disability_emp.dta", keep(3) nogen

*******
**(2)**
*******
*2.1: OLS regressions: 
reg incssi cps_telework if disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estadd local IV No
estimates store m1, title("(1)")

*2.2: adding controls
reg incssi cps_telework i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI if disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estadd local IV No
estimates store m2, title("(2)")

*2.3: adding FE 
reghdfe incssi cps_telework i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI if disability == 1 [aw=wtfinl], absorb(Istate_month Inaics2_month Imonth)
estadd local fe Yes
estadd local controls Yes
estadd local IV No
estimates store m3, title("(3)")

*********
**(3.1)**
*********
/* First Stage */ 
*No controls 
reg cps_telework dingel_wfh [aw=wtfinl], robust				
qui predict remote_iv1, xb

*With controls 
reg cps_telework dingel_wfh i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI [aw=wtfinl], robust				
qui predict remote_iv2, xb

*With controls + FE
reghdfe cps_telework dingel_wfh i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI [aw=wtfinl], absorb(Imonth Inaics2_month Istate_month)
qui predict remote_iv3, xb

*With controls + FE + labor market tightness
reghdfe cps_telework dingel_wfh i.female i.married i.hispanic i.race i.famsize age child incdivid incrent incasist employed incvet incsurv delta_wage delta_collects_SSI pct_change_ndis pct_change_ndis_sq [aw=wtfinl], absorb(Imonth Inaics2_month Istate_month)
qui predict remote_iv4, xb

/* Second Stage */ 
*IV No controls 
ivregress 2sls incssi (cps_telework=remote_iv1) if disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estadd local IV Yes
estimates store m4, title("(4)")

*IV with controls
ivregress 2sls incssi (cps_telework=remote_iv2) if disability == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estadd local IV Yes
estimates store m5, title("(5)")

*IV with FE: controlling for labor market tightness
ivregress 2sls incssi (cps_telework=remote_iv3) if disability == 1 [aw=wtfinl], robust
estadd local fe Yes
estadd local controls Yes
estadd local IV Yes
estimates store m6, title("(6)")

*With controls + FE + labor market tightne
ivregress 2sls incssi (cps_telework=remote_iv4) if disability_noC == 1 [aw=wtfinl], robust
estadd local fe Yes
estadd local controls Yes
estadd local IV Yes
estimates store m7, title("(7)")


*******
**(2)**
*******
/* Results */
estout m1 m2 m3 m4 m5 m6 /*m7*/, cells(b(fmt(%9.3f)) se(par fmt(%9.3f))) keep(cps_telework) stats(r2 N fe controls IV, fmt(%9.2f %9.0fc ) label(R-sqr N "Fixed Effects" "Controls" "IV")) legend label
