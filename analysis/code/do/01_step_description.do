/*
	Project: The growing importance of social skills in the labor market (2017)
	Author: David Deming
	Date Created: April 2017
	
	Description: Runs the Census and ACS analysis and creates:
		Figures 1, 3, 4, 5, A1, A2, A3, A4
		Tables A1, A5, A6
*/

***********************************************************
*This file prepares the CPS school data
***********************************************************
/*Data Files Used
	dbnd.csv
	elevdis.dbf
	sldist.dbf
	d2_potd.csv
	d2_huand.csv
	dis_xy.dta
	inmita.dbf
	outmita.dbf
	gr_coor.dbf
	e3.dbf
	s3.dbf

*Data Files Created as Final Product	
	gis_dist
	gis_grid

*Data Files Created as Intermediate Product
	temp*/
	
*****************************************************************************
** Set macros
****************************************************************************
*set path for your local computer
global path = "/Users/ethansawyer/Desktop/Stata/"
global do = "do"
global raw = "rawdata"
global graphs = "graphs"
global tables = "tables"
global working_data = "working_data"

cd "$path"

****************************************************************************
** Precursor
****************************************************************************
set excelxlsxlargefile on
clear
capture clear mata
capture clear matrix
capture log close
program drop _all
set matsize 11000
pause on
set more off

**********************************
*Geographic controls by district
**********************************

***----distance to mita boundary
*gives distance from district capitals to the nearest point on the mita boundary, as well as the
*geographic location of that point

clear
insheet using dbnd.csv

gen d_bnd=near_dist/1000
label var d_bnd "distance to  mita boundary (km)"

**4 bfe

gen temp=.
replace temp=1 if (near_y<=8400000)
recode temp (.=0)
tab temp

gen bfe4_1=.
replace bfe4_1=1 if (temp==1 & near_x<=824796.228990515)
recode bfe4_1 (.=0)

gen bfe4_2=.
replace bfe4_2=1 if (temp==1 & bfe4_1 !=1)
recode bfe4_2 (.=0)

gen bfe4_3=.
replace bfe4_3=1 if (temp==0 & near_x<=808697.919841043)
recode bfe4_3 (.=0)

tab bfe4_1 
tab bfe4_2 
tab bfe4_3

keep d_bnd bfe4* ubigeo pothuan_mita border cusco near_x near_y

sort ubigeo
save 	gis_dist, replace


***--------------------------------mean elevation of the district--------------------------------***
clear
odbc load CODIGO_DIS MEAN, table("elevdis.dbf") dsn("dBASE Files") lowercase

rename codigo_dis ubigeo
tab ubigeo
rename mean elv_sh
label var elv_sh "elevation (1000m)"
destring ubigeo, replace
sort ubigeo
save temp, replace

use gis_dist, clear
sort ubigeo
merge ubigeo using temp, unique
tab _merge
keep if _merge==3 /*only keep districts within 100 km of mita boundary*/
drop _merge
sort ubigeo
save gis_dist, replace


***--------------------------------------mean slope of the district------------------------------***
clear
odbc load CODIGO_DIS MEAN, table("sldist.dbf") dsn("dBASE Files") lowercase

rename codigo_dis ubigeo
rename mean slope
label var slope "mean slope"
destring ubigeo, replace
sort ubigeo
save temp, replace

use gis_dist, clear
sort ubigeo
merge ubigeo using temp, unique
tab _merge
keep if _merge==3 /*only keep districts within 100 km of mita boundary*/
drop _merge
sort ubigeo
save gis_dist, replace


***------------------------------------distance to Potosi---------------------------------***

insheet using d2_potd.csv, comma clear
gen dpot=near_dist/1000
label var dpot "distance to  Potosi (km)"
sort ubigeo
save temp, replace

use gis_dist, clear
sort ubigeo
merge ubigeo using temp, unique
tab _merge 
keep if _merge==3 /*only keep districts within 100 km of mita boundary*/
drop _merge
sort ubigeo
save gis_dist, replace


***------------------------------------distance to Huancavelica---------------------------------***

insheet using d2_huand.csv, comma clear

gen dhuan=near_dist/1000
label var dhuan "distance to Huancavelica (km)"
sort ubigeo
save temp, replace

use gis_dist, clear
sort ubigeo
merge ubigeo using temp, unique
tab _merge 
keep if _merge==3 /*only keep districts within 100 km of mita boundary*/
drop _merge
sort ubigeo
save gis_dist, replace

***------------------------------------------Latitude and Longitude

sort ubigeo
merge ubigeo using dis_xy, uniqusing
tab _merge
keep if _merge==3
drop _merge
sort ubigeo
save gis_dist, replace


***------------------------------------------Generate RD Terms------------------------------------------***
*elevation polynomial terms
generate double elv_sh2= elv_sh^2
generate double elv_sh3= elv_sh^3
generate double elv_sh4= elv_sh^4

*slope polynomial terms
gen slope2=slope^2
gen slope3=slope^3
gen slope4=slope^4

*distance to mita boundary terms
gen dbnd_sh= d_bnd/100
gen dbnd_sh2= dbnd_sh^2
gen dbnd_sh3= dbnd_sh^3
gen dbnd_sh4= dbnd_sh^4

*distance to Potosi polynomial terms
replace dpot=dpot/100
gen dpot2=dpot^2
gen dpot3=dpot^3
gen dpot4=dpot^4

*distance to Huancavelica polynomial terms
replace dhuan=dhuan/100
gen dhuan2=dhuan^2
gen dhuan3=dhuan^3
gen dhuan4=dhuan^4

*gen distance to boundary, relative to cutoff point
gen mita_neg=pothuan_mita
recode mita_neg 0=-1
gen bnd_dist_neg= d_bnd*mita_neg
tab bnd_dist_neg
drop mita_neg

*latitude and longitude

*linear RD terms
g x=lon
g y= lat
egen xbar=mean(x) 
egen ybar=mean(y) 
replace x=x-xbar
replace y=y-ybar
drop xbar ybar

*quadratic RD terms
g x2=x^2
g y2=y^2
g xy=x*y

*cubic RD terms
g x3=x^3
g y3=y^3
g x2y=x^2*y
g xy2=x*y^2

*quadratic RD terms
g x4=x^4
g y4=y^4
g x3y=x^3*y
g x2y2=x^2*y^2
g xy3=x*y^3


summ
save gis_dist, replace


**********************************
*Geographic controls by grid cell
**********************************

***these are used for the means comparison tests (Table 1)

***---------distance to mita boundary-
*gives distance from centroids to the nearest point on the mita boundary, as well as the
*geographic location of that point

*note that the entire grid cell is considered to be in the study region if its centrod is in 
*the study region


clear
odbc load GRID_ID NEAR_FID NEAR_DIST, table("inmita.dbf") dsn("dBASE Files") lowercase

gen d_bnd=near_dist/1000
label var d_bnd "distance to  mita boundary (km)"

drop if near_fid==-1 /*these are grid cells falling partially within the study region but whose 
	centroids are > 100 km from the study boundary. Thus they should be dropped*/

gen pothuan_mita=1

sort grid_id
save gis_grid, replace

clear
odbc load GRID_ID NEAR_FID NEAR_DIST, table("outmita.dbf") dsn("dBASE Files") lowercase

gen d_bnd=near_dist/1000
label var d_bnd "distance to  mita boundary (km)"
summarize d_bnd

drop if near_fid==-1 /*these are grid cells falling partially within the study region but whose 
	centroids are > 100 km from the study boundary. Thus they should be dropped*/

gen pothuan_mita=0

count
sort grid_id
append using gis_grid
save gis_grid, replace



***----------------------------------------grid cell coordinates----------------------------------***
clear
odbc load GRID_ID POINT_X POINT_Y, table("gr_coor.dbf") dsn("dBASE Files") lowercase
rename point_x xcord
rename point_y ycord
sort grid_id
save temp, replace

use gis_grid, clear
sort grid_id
merge grid_id using temp, unique
tab _merge
keep if _merge==3 /*keep only the cells within 100 km of study boundary*/
drop _merge
save gis_grid, replace



***--------------------------------mean elevation of the grid cell--------------------------------***
*includes Cusco

clear
odbc load VALUE MEAN, table("e3.dbf") dsn("dBASE Files") lowercase
rename value grid_id
gen elev=mean
drop mean
label var elev "elevation (m)"
gen elv_sh=elev/1000
sort grid_id
save temp, replace

use gis_grid, clear
sort grid_id
merge grid_id using temp, unique
tab _merge
keep if _merge==3  /*keep only the cells within 100 km of study boundary*/
/*the merge==2's are all outside the study region - there are 276 grid cells inside the study region*/
drop _merge
save gis_grid, replace




***--------------------------------------mean slope of the grid cell------------------------------*** 
clear
odbc load VALUE MEAN, table("s3.dbf") dsn("dBASE Files") lowercase
rename value grid_id
rename mean slope
label var slope "mean slope"
replace slope=. if grid_id==264 /*this grid cell is composed primarily of metropolitan Cusco*/
sort grid_id
save temp, replace

use gis_grid, clear
sort grid_id
merge grid_id using temp, unique
tab _merge
keep if _merge==3  /*keep only the cells within 100 km of study boundary*/
drop _merge
save gis_grid, replace

log close
