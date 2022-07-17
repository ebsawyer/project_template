/*
	Project: The growing importance of social skills in the labor market (2017)
	Author: David Deming
	Date Created: May 2017
	
	Description: Master do file that runs all programs for the project,
		including data cleaning and results
*/

****************************************************************************
** Download dependencies
****************************************************************************
ssc install 

****************************************************************************
** Set macros
****************************************************************************
*set path for your local computer
global path = "/Users/ethansawyer/Desktop/video_games_code"
global do = "do"
global raw = "rawdata"
global tables = "tables"
global graphs = "graphs"
global working_data = "working_data"
global log = "log"

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



log using "$log/step1.log", replace
****************************************************************************
** Step 1: 
****************************************************************************
do "$do/step1.do"


log using "$log/step2.log", replace
****************************************************************************
** Step 2: 
****************************************************************************
do "$do/step2.do"


capture log close
log using "$log/step3.log", replace
****************************************************************************
** Step 3: 
****************************************************************************
do "$do/step3.do"


capture log close
