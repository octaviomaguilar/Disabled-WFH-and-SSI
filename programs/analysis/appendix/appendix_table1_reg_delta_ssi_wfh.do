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
use "$ipums/clean/delta_wfh.dta", clear

*merge in delta SSI data
merge 1:1 occ2 using "$ipums/clean/delta_ssi.dta", keep(3) nogen

*merge in delta wage data
merge 1:1 occ2 using "$ipums/clean/delta_wage.dta", keep(3) nogen

*merge in delta SSI recipients data
merge 1:1 occ2 using "$ipums/clean/delta_ssi_recipients.dta", keep(3) nogen 

*merge in dingel wfh measure
merge 1:1 occ2 using "$data/telework/onet_dingel_wfhdiff.dta", keep(3) nogen

*merge in compositional data 
merge 1:1 occ2 using "$ipums/clean/polynomial_disability_emp.dta", keep(3) nogen

*******
**(2)**
*******
*No controls
reg delta_ssi delta_wfh, robust
estadd local controls No
estadd local Poly No
estadd local IV No
estimates store m1, title("(1)")

*with controls
reg delta_ssi delta_wfh delta_wage delta_collects_SSI, robust
estadd local controls Yes
estadd local Poly No
estadd local IV No
estimates store m2, title("(2)")

*with controls + polynomial
reg delta_ssi delta_wfh delta_wage delta_collects_SSI delta_collects_SSI_sq delta_collects_SSI_cube pct_change_ndis pct_change_ndis_sq, robust
estadd local controls Yes
estadd local Poly Yes
estadd local IV No
estimates store m3, title("(3)")

*******
**(3)**
*******
/* Instrumental Variables */ 

/* First Stage */ 
*No controls 
reg delta_wfh dingel_wfh, robust
qui predict remote_iv1, xb
estadd local controls No
estadd local Poly No
estimates store m4, title("(1)")
					
*With controls
reg delta_wfh dingel_wfh delta_wage delta_collects_SSI, robust
qui predict remote_iv2, xb
estadd local controls Yes
estadd local Poly No
estimates store m5, title("(2)")

*with controls + polynomial
reg delta_wfh dingel_wfh delta_wage delta_collects_SSI pct_change_ndis delta_collects_SSI pct_change_ndis pct_change_ndis_sq, robust
qui predict remote_iv3, xb
estadd local controls Yes
estadd local Poly Yes
estimates store m6, title("(3)")
	
/* Second Stage */ 
*No controls 
ivregress 2sls delta_ssi (delta_wfh=remote_iv1), robust
estadd local controls No
estadd local Poly No
estadd local IV Yes
estimates store m7, title("(4)")

*With controls
ivregress 2sls delta_ssi (delta_wfh=remote_iv2), robust
estadd local controls Yes
estadd local Poly No
estadd local IV Yes
estimates store m8, title("(5)")

*with controls + polynomial
ivregress 2sls delta_ssi (delta_wfh=remote_iv3), robust
estadd local controls Yes
estadd local Poly Yes
estadd local IV Yes
estimates store m9, title("(6)")

*******
**(4)**
*******
*first stage estimates:
estout m4 m5 m6, cells(b(fmt(%9.3f)) se(par fmt(%9.3f))) keep(dingel_wfh) stats(r2 N controls Poly, fmt(%9.2f %9.0fc ) label(R-sqr N "Controls" "Poly")) legend label

*OLS + second stage estimates:
estout m1 m2 m3 m7 m8 m9, cells(b(fmt(%9.3f)) se(par fmt(%9.3f))) keep(delta_wfh) stats(r2 N controls Poly, fmt(%9.2f %9.0fc ) label(R-sqr N "Controls" "Poly")) legend label
