unzipfile "M:\Abortion Stuff\Local_Authority_Districts_(December_2019)_Boundaries_UK_BUC.zip", replace
shp2dta using "Local_Authority_Districts_(December_2019)_Boundaries_UK_BUC", database(usdb) coordinates(gbcoord) genid(id)

use usdb, clear
describe 

use "M:\Abortion Stuff\abortion data.dta"

merge 1:1 lad19cd using usdb 
keep if _merge==3

spmap Gper10000women using gbcoord, id(id) fcolor(Blues)

*generating a variable for areas with no clinics
gen noclinic=1 if Gper10000women==0
replace noclinic=0 if Gper10000women>0
tab noclinic

*Now trying for those that are equal to zero
spmap noclinic using gbcoord, id(id) fcolor(Greens)

// generate adjacency matrix
use gbcoord
spset _ID, modify replace
spmatrix create contiguity W, rook
spmatrix create idistance W2

*Think about this

twoway area _Y _X if ALAND>0, nodropbase cmiss(n) fi(25) col(gray)||area _Y _X if COUNTYFP=="001" &
ALAND>0, nodropbase cmiss(n) fi(25) col(blue) leg(off) ysc(off) yla(,nogrid) xsc(off) graphr(fc(white)) xsize(4)
ysize(8)


// Linear regression model
regress Gper10000women IMDAveragescore
predict regres, residuals
spmap regres using gbcoord, id(id) fcolor(Reds)

*Now just trying a logit to see what we get
logit noclinic IMDAveragescore 


*Now we open up the data with the abortion clinics
merge 1:1 lad19cd using "Local_Authority_Districts_(December_2019)_Boundaries_UK_BUC.dta"
keep if _merge==3
drop _merge
spmap Gper10000women, clnumber(9) fcolor(PuRd) name(dommap, replace) title("Total Clinics per 10,000 women")