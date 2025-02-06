cap cls
clear all
set more off

global home = "/mq/scratch/m1oma00/oma_projects/disability"
global data "$home/data"
global ipums "$data/ipums"
global crosswalk "$data/crosswalks"
global lcast "$data/lcast"
global acs "$data/acs"
global figures "$home/figures"

*******
**(1)**
*******
/* Figure B1: changes in work from home pre-post covid */
*Load ACS data
use "$ipums/raw/raw_acs.dta", clear

*clean the data
drop if tranwork == 0
keep if age >= 16
keep if empstat == 1
gen employed =1 if empstat==1
gen wfh = tranwork == 80

*generate disability indicator
gen disability_noC = 1 if /* diffrem == 2 | */ diffphys == 2 | diffmob == 2 | diffcare == 2 | diffsens == 2 | diffeye == 2 | diffhear == 2
replace disability_noC = 0 if disability_noC == .

*generate occupation indicator
gen occ2 = substr(occsoc,1,2)

*compare the wfh shares by year occupation
collapse (mean) wfh [aw=perwt] if disability_noC == 1, by(year occ2)

reshape wide wfh, i(occ2) j(year)
egen wfh_2018_2019 = rowmean(wfh2018 wfh2019)
egen wfh_2021_2023 = rowmean(wfh2021 wfh2022 wfh2023)

*simple difference in 3-year averages pre-post
gen delta = wfh_2021_2023 - wfh_2018_2019
replace delta = delta*100

*merge in occupation titles 
merge m:1 occ2 using "$crosswalk/occ_titles.dta", keep(3) nogen

*bar chart of changes in the 3-year average of disability wfh 
graph hbar delta, over(title, sort(delta) descending) ytitle("Percentage Point Change")
graph export "$figures/appendix_figureB1.eps", replace

*******
**(2)**
*******
/* Figure B2: Bin scatter between SSI income and work from home measures */
use "$ipums/clean/cps_regdata.dta", clear

*focusing on 2019-2023 period: 
keep if year >= 2019
binscatter incssi wfh if disability_noC == 1 [aw=asecwt], control(Inaics2_month Istate_month Imonth) ytitle(SSI in Dollars) xtitle(ACS Work from Home) ylabel(, format(%9.2f)) xlabel(, format(%9.2f))
graph export "$figures/appendix_figureB2.eps", replace

*******
**(3)**
*******
/* Figure B3: disability by age */
use "$ipums/clean/cps_clean.dta", clear

preserve 
	collapse (mean) disability_noC [aw=wtfinl], by(age) 
	twoway line disability age, lcolor(black) xtitle("Age") ytitle("Share With a Disability") ylabel(, format(%9.2f))
	graph export "$figures/appendix_figureB3.eps", replace
restore


*******
**(4)**
*******
/* Figure B4: Population with a Disability */

/* Panel A*/
use "$ipums/clean/cps_clean.dta", clear

*shares
preserve
	collapse (mean) disability disability_noC [aw=wtfinl], by(tm)
	twoway ///
	    (line disability tm, lcolor(black)) ///
	    (line disability_noC tm, lcolor(red)) ///
	    , ylabel(, format(%9.3f)) ///
	      ytitle("Share With a Disability") ///
	      xtitle("") ///
	      legend(label(1 "With cognitive disability") label(2 "No cognitive disability") position(6))
	graph export "$figures/appendix_B4a.eps", replace
restore

/* Panel B*/
preserve
	collapse (sum) disability disability_noC [pw=wtfinl], by(tm)
	replace disability = disability/1000000
	replace disability_noC = disability_noC/1000000
	twoway ///
	    (line disability tm, lcolor(black)) ///
	    (line disability_noC tm, lcolor(red)) ///
	    , ylabel(, format(%9.0f)) ///
	      ytitle("Population, Millions") ///
	      xtitle("") ///
	      legend(label(1 "With cognitive disability") label(2 "No cognitive disability") position(6))
	graph export "$figures/appendix_B4b.eps", replace
restore

/* Panel C*/
use "$ipums/clean/cps_regdata.dta", clear

preserve
	collapse (mean) disability disability_noC [aw=wtfinl], by(tm)
	twoway ///
	    (line disability tm, lcolor(black)) ///
	    (line disability_noC tm, lcolor(red)) ///
	    , ylabel(, format(%9.3f)) ///
	      ytitle("Share With a Disability") ///
	      xtitle("") ///
	      legend(label(1 "With cognitive disability") label(2 "No cognitive disability") position(6))
	graph export "$figures/appendix_B4c.eps", replace
restore

/* Panel D*/
preserve
	collapse (sum) disability disability_noC [pw=wtfinl], by(tm)
	replace disability = disability/1000000
	replace disability_noC = disability_noC/1000000
	twoway ///
	    (line disability tm, lcolor(black)) ///
	    (line disability_noC tm, lcolor(red)) ///
	    , ylabel(, format(%9.0f)) ///
	      ytitle("Population, Millions") ///
	      xtitle("") ///
	      legend(label(1 "With cognitive disability") label(2 "No cognitive disability") position(6))
	graph export "$figures/appendix_B4d.eps", replace
restore


*******
**(5)**
*******
/* Figure B5: changes in occupational employment pre-post covid */
use "$ipums/raw/raw_acs.dta", clear

keep if age >= 16
gen employed = empstat==1

*generate disability indicator
gen disability_noC = 1 if /* diffrem == 2 | */ diffphys == 2 | diffmob == 2 | diffcare == 2 | diffsens == 2 | diffeye == 2 | diffhear == 2
replace disability_noC = 0 if disability_noC == .

*generate occupation indicator
gen occ2 = substr(occsoc,1,2)

collapse (mean) employed [aw=perwt] if disability == 1, by(year occ2)

drop if occ2 == "99"
drop if employed == 0
reshape wide employed, i(occ2) j(year)

egen employment_2018_2019 = rowmean(employed2018 employed2019)
egen employment_2021_2023 = rowmean(employed2021 employed2022 employed2023)

*merge in occ titles: 
merge m:1 occ2 using "$crosswalk/occ_titles.dta", keep(3) nogen
*percent change in 3-year averages pre-post
gen delta = ((employment_2021_2023/employment_2018_2019) - 1) * 100
	
graph hbar delta, over(title, sort(delta) descending) ytitle("Percent Change")
graph export "$figures/appendix_B5.eps", replace

*******
**(6)**
*******
/* Figure B6: SSI recipients in 2018-2019 and 2021-2023 across occupations */

use "$ipums/clean/delta_ssi_recipients_noC.dta", clear
merge m:1 occ2 using "$crosswalk/occ_titles.dta", keep(3) nogen
graph hbar collects_SSI_2018_2019 collects_SSI_2021_2023, over(title, sort(collects_SSI_2018_2019) descending label(labsize(small))) ytitle("Share of SSI Recipients") legend(label(1 "2018-2019") label(2 "2021-2023") position(6)) ylabel(, format(%9.2f))
graph export "$figures/appendix_B6.eps", replace

*******
**(7)**
*******
/* Figure B7: Share WFH pre-post pandemic across occupations */
use "$ipums/clean/acs_wfh.dta", clear

reshape wide wfh, i(occ2) j(year)

egen wfh_2018_2019 = rowmean(wfh2018 wfh2019)
egen wfh_2021_2023 = rowmean(wfh2021 wfh2022 wfh2023)

*merge in occ titles: 
merge m:1 occ2 using "$crosswalk/occ_titles.dta", keep(3) nogen

graph hbar wfh_2018_2019 wfh_2021_2023, over(title, sort(wfh_2018_2019) descending label(labsize(small))) ytitle("Share Working from Home") legend(label(1 "2018-2019") label(2 "2021-2023") position(6)) ylabel(, format(%9.2f))
graph export "$figures/appendix_B7.eps", replace

*******
**(8)**
*******
/* Figure B8: distribution of SSI income */
use "$ipums/clean/cps_regdata.dta", clear

keep if disability_noC == 1
graph twoway kdensity incssi [aw=asecwt] if disability_noC == 1, bw(1e+04) color(gs4) ylabel(, format(%9.6f)) xtitle("SSI in Dollars") ytitle("Density")
graph export "$figures/appendix_B8.eps", replace

*******
**(9)**
*******
/* Figure B9: Bin scatter between SSI income and work from home measures */
use "$ipums/clean/cps_regdata.dta", clear

*focusing on 2019-2023 period: 
keep if year >= 2019

*Lightcast remote job postings
binscatter incssi remote if disability_noC == 1 [aw=asecwt], control(Inaics2_month Istate_month Imonth) ytitle(SSI in Dollars) xtitle(Remote Job Postings) ylabel(, format(%9.2f)) xlabel(, format(%9.2f))
graph export "$figures/appendix_B9a.eps", replace

*Dingel-nieman wfh measure
binscatter incssi dingel_wfh if disability_noC == 1 [aw=asecwt], control(Inaics2_month Istate_month Imonth) ytitle(SSI in Dollars) xtitle(Dingel & Neiman Work From Home) ylabel(, format(%9.2f)) xlabel(, format(%9.2f))
graph export "$figures/appendix_B9b.eps", replace

*CPS telework measure 2022m1-2023m12.
merge m:1 occ2 year using "$ipums/clean/cps_telework.dta", keep(3) nogen
binscatter incssi cps_telework if disability_noC == 1 [aw=asecwt], control(Inaics2_month Istate_month Imonth) ytitle(SSI in Dollars) xtitle(CPS Work from Home) ylabel(, format(%9.2f)) xlabel(, format(%9.2f))
graph export "$figures/appendix_B9c.eps", replace

    
