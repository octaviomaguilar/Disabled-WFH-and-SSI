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
*Pre-period: 2017-2018
use "$ipums/clean/cps_regdata.dta", clear

*merge in delta wage data
merge m:1 occ2 using "$ipums/clean/delta_wage_noC.dta", keep(3) nogen

*merge in delta SSI recipients data
merge m:1 occ2 using "$ipums/clean/delta_ssi_recipients_noC.dta", keep(3) nogen 

*merge in compositional data: results remain unchanged if including polynomials or not
merge m:1 occ2 using "$ipums/clean/polynomial_disability_noC_emp.dta", keep(3) nogen

*******
**(2)**
*******
*No controls
reg incssi remote if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estadd local IV No
estimates store m1, title("(1)")

*adding controls
reg incssi remote i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estadd local IV No
estimates store m2, title("(2)")

*adding FEs
reghdfe incssi remote i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], absorb(Istate_month Inaics2_month Imonth)
estadd local fe Yes
estadd local controls Yes
estadd local IV No
estimates store m3, title("(3)")

*********
**(2.1)**
*********
/* Instrumental Variables */ 

/* First Stage */ 
*No controls 
reg remote dingel_wfh if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust			
qui predict remote_iv1, xb

*With controls
reg remote dingel_wfh incssi i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust				
qui predict remote_iv2, xb

*With controls + FE 
reghdfe remote dingel_wfh incssi i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], absorb(Imonth Inaics2_month Istate_month)			
qui predict remote_iv3, xb

*With controls + FE + labor market tightness
reghdfe remote dingel_wfh incssi i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI pct_change_ndis pct_change_ndis_sq if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], absorb(Imonth Inaics2_month Istate_month)			
qui predict remote_iv4, xb

/* Second Stage */ 
*No controls 
ivregress 2sls incssi (remote=remote_iv1) if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estadd local IV Yes
estimates store m4, title("(4)")

*With controls
ivregress 2sls incssi (remote=remote_iv2) if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estadd local IV Yes
estimates store m5, title("(5)")

*With controls + FE 
ivregress 2sls incssi (remote=remote_iv3) if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe Yes
estadd local controls Yes
estadd local IV Yes
estimates store m6, title("(6)")

*With controls + FE + labor market tightness
ivregress 2sls incssi (remote=remote_iv4) if year >= 2018 & year <= 2019 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe Yes
estadd local controls Yes
estadd local IV Yes
estimates store m7, title("(7)")


drop remote_iv1 remote_iv2 remote_iv3 remote_iv4

*******
**(3)**
*******
*post-period: 2021-2023

*No controls
reg incssi remote if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estadd local IV No
estimates store m7, title("(1)")

*adding controls
reg incssi remote i.female i.married i.hispanic i.race i.famsize age employed child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estadd local IV No
estimates store m8, title("(2)")

*adding FEs
reghdfe incssi remote i.female i.married i.hispanic i.race i.famsize age employed child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], absorb(Istate_month Inaics2_month Imonth)
estadd local fe Yes
estadd local controls Yes
estadd local IV No
estimates store m9, title("(3)")

*********
**(3.1)**
*********
/* First Stage */ 
*No controls 
reg remote dingel_wfh if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust			
qui predict remote_iv1, xb

*With controls
reg remote dingel_wfh incssi i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust				
qui predict remote_iv2, xb

*With controls + FE 
reghdfe remote dingel_wfh incssi i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], absorb(Imonth Inaics2_month Istate_month)			
qui predict remote_iv3, xb


*With controls + FE + labor market tightness
reghdfe remote dingel_wfh incssi i.female i.married i.hispanic i.race i.famsize employed age child incdivid incrent incasist incvet incsurv delta_wage delta_collects_SSI pct_change_ndis pct_change_ndis_sq pct_change_ndis_cube if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], absorb(Imonth Inaics2_month Istate_month)			
qui predict remote_iv4, xb


/* Second Stage */ 
*No controls 
ivregress 2sls incssi (remote=remote_iv1) if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls No
estadd local IV Yes
estimates store m10, title("(4)")

*With controls
ivregress 2sls incssi (remote=remote_iv2) if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe No
estadd local controls Yes
estadd local IV Yes
estimates store m11, title("(5)")

*With controls + FE 
ivregress 2sls incssi (remote=remote_iv3) if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe Yes
estadd local controls Yes
estadd local IV Yes
estimates store m12, title("(6)")

*With controls + FE + labor market tightness
ivregress 2sls incssi (remote=remote_iv4) if year >= 2021 & year <= 2023 & disability_noC == 1 [aw=wtfinl], robust
estadd local fe Yes
estadd local controls Yes
estadd local IV Yes
estimates store m13, title("(7)")


drop remote_iv1 remote_iv2 remote_iv3 remote_iv4

*******
**(3)**
*******
/* Pre-period results 2018-2019 */
estout m1 m2 m3 m4 m5 m6 /*m7*/, cells(b(fmt(%9.3f)) se(par fmt(%9.3f))) keep(remote) stats(r2 N fe controls IV, fmt(%9.2f %9.0fc ) label(R-sqr N "Fixed Effects" "Controls" "IV")) legend label

/* Post-period results 2021-2023 */
estout m7 m8 m9 m10 m11 m12 /*m13*/, cells(b(fmt(%9.3f)) se(par fmt(%9.3f))) keep(remote) stats(r2 N fe controls IV, fmt(%9.2f %9.0fc ) label(R-sqr N "Fixed Effects" "Controls" "IV")) legend label
