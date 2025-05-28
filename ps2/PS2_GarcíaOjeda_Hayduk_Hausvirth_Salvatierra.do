/*******************************************************************************
                          Semana 3: Problem Set 2 

                          Universidad de San Andrés
                              Economía Aplicada
							       2024				
Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth
*******************************************************************************/


* Source: https://www.aeaweb.org/articles?id=10.1257/app.20200204

/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment and globals

1) Regressions (panel A, B, C y D)
2) Correccion de Bonferroni
3) Correccion de Holm
4) Correccion de Benjamini, Krieger, and Yekutieli (2006)

*******************************************************************************/



* 0) Set up environment
*==============================================================================*

*gl main "/Users/gasparhayduk/Desktop/Economía Aplicada/aplicadaps2"
gl main "C:\Users\Usuario\OneDrive\Juanga\OneDrive\JUANGA\Maestria\Udesa\Economia Aplicada\Problem sets\PS2"
gl input "$main/input"
gl output "$main/output"

* Open data set

use "$input/measures.dta", clear 

* Global with control variables

global covs_eva	"male i.eva_fu" 
global covs_ent	"male i.ent_fu"

*-- Agregamos etiquetas a la variable de interes y a los outcomes:

* Outcomes panel A
label var b_tot_cog1_st "Cognitive"        
label var b_tot_lr1_st "Receptive language"
label var b_tot_le1_st "Expressive language"
label var b_tot_mf1_st "Fine motor"
label var mac_words1_st "Words" 
label var mac_phrases1_st "Complex phrases"

*Outcomes panel B
label var bates_difficult1_st  "ICQ: Difficult (-)"        
label var bates_unsociable1_st  "ICQ: Unsociable (-) "
label var bates_unstoppable1_st  "ICQ: Unstoppable (-)"
label var roth_inhibit1_st  "ECBQ: Inhibitory control"
label var roth_attention1_st  "ECBQ: Attention"

*Outcomes panel C
label var fci_play_mat_type1_st  "FCI: Number of types of play materials"        
label var Npaintbooks1_st  "FCI: Number of coloring and drawing books"
label var Nthingsmove1_st  "FCI: Number of toys to learn movement"
label var Ntoysshape1_st  "FCI: Number of toys to learn shapes"
label var Ntoysbought1_st  "FCI: Number of shop-bought toys" 
 
*Outcomes panel D
label var fci_play_act1_st  "FCI: Number of types of play activities in last 3 days"        
label var home_stories1_st  "FCI: Number of times told a story to child in last 3 days"
label var home_read1_st  "FCI: Number of times read to child in last 3 days"
label var home_toys1_st  "FCI: Number of times played with toys in last 3 days"
label var home_name1_st  "FCI: Number of times named things to child in last 3 days" 

*Variable de tratamiento
label var treat "Treatment Effect"



* 1) Regressions
*==============================================================================*



******************************************************************************* 
* PANEL A (Child's cognitive skills at follow up) 
******************************************************************************* 


local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
eststo clear 
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
} 
esttab using "$output/Cuadro1_panelA.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///


local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
} 
esttab using "$output/Cuadro1_panelA.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///


******************************************************************************* 
* PANEL B (Child's socio-emotional skills at follow up) 
******************************************************************************* 

local bates "bates_difficult bates_unsociable bates_unstoppable" 
eststo clear
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
} 
esttab using "$output/Cuadro1_panelB.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
} 
esttab using "$output/Cuadro1_panelB.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///


******************************************************************************* 
* PANEL C (Material investments)  
******************************************************************************* 

local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
eststo clear
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
} 
esttab using "$output/Cuadro1_panelC.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///


******************************************************************************* 
* PANEL D (Time investments)  
******************************************************************************* 
local fcitime "fci_play_act home_stories home_read home_toys home_name"
eststo clear
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
} 
esttab using "$output/Cuadro1_panelD.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) /// 




* 2) Correccion de Bonferroni
*==============================================================================*

* Tenemos 21 outcomes de interes, por lo que hay que testear 21 hipotesis. Guardamos ese numero en un escalar:
scalar hyp = 21 

* si tengo m hipotesis uso alpha/m como nivel de significancia. 
* por lo que debemos ver si los p-valores < alpha/m
* por comodidad, veremos si m*p-valores < alpha (el codigo hace esto). 

* Hay que correr las regresiones otra vez, almacenar el p-valor y generar el nuevo p-valor corregido. Hacemos esto para cada panel.

******************************************************************************* 
* PANEL A (Child's cognitive skills at follow up) 
******************************************************************************* 


local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
eststo clear 
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
} 
esttab using "$output/Cuadro2_panelA.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value blank N, fmt(3 3 0) labels("P_value" "Bonferroni Corrected P_value" " " "Number of Observations"))


local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
} 
esttab using "$output/Cuadro2_panelA.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value blank N, fmt(3 3 0) labels("P_value" "Bonferroni Corrected P_value" " " "Number of Observations"))

******************************************************************************* 
* PANEL B (Child's socio-emotional skills at follow up) 
******************************************************************************* 

local bates "bates_difficult bates_unsociable bates_unstoppable" 
eststo clear
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
} 
esttab using "$output/Cuadro2_panelB.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value blank N, fmt(3 3 0) labels("P_value" "Bonferroni Corrected P_value" " " "Number of Observations"))

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
} 
esttab using "$output/Cuadro2_panelB.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value blank N, fmt(3 3 0) labels("P_value" "Bonferroni Corrected P_value" " " "Number of Observations"))

******************************************************************************* 
* PANEL C (Material investments)  
******************************************************************************* 

local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
eststo clear
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
} 
esttab using "$output/Cuadro2_panelC.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value blank N, fmt(3 3 0) labels("P_value" "Bonferroni Corrected P_value" " " "Number of Observations"))

******************************************************************************* 
* PANEL D (Time investments)  
******************************************************************************* 
local fcitime "fci_play_act home_stories home_read home_toys home_name"
eststo clear
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
} 
esttab using "$output/Cuadro2_panelD.tex", se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) /// 
stats(p_value corr_p_value blank N, fmt(3 3 0) labels("P_value" "Bonferroni Corrected P_value" " " "Number of Observations"))




* 3) Correccion de Holm
*==============================================================================*

* Defino el nivel de significancia:
scalar signif = 0.05 
* Defino la cantidad de hipotesis:
scalar hyp = 21

* Creo una matriz de 21 filas y 1 columna donde almaceno los p-valores:
mat p_values = J(21,1,.) 

* Creo la variable para iterar:
scalar i = 1 

*---------Ahora debo rellenar la matriz de p-valores. Debo correr todas las regresiones:

*--- PANEL A (Child's cognitive skills at follow up) 
local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf" 
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1] = r(p)
	scalar i = i +1
} 

local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1] = r(p)
	scalar i = i +1
} 

*--- PANEL B (Child's socio-emotional skills at follow up)
local bates "bates_difficult bates_unsociable bates_unstoppable" 
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1] = r(p)
	scalar i = i +1	
} 

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1] = r(p)
	scalar i = i +1
} 

*--- PANEL C (Material investments)
local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1] = r(p)
	scalar i = i +1	
} 

*--- PANEL D (Time investments)
local fcitime "fci_play_act home_stories home_read home_toys home_name"
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	mat p_values[i,1] = r(p)
	scalar i = i +1	
} 


*--- Ahora trabajo con la matriz.

preserve 
clear // borro la base que tengo abierta
svmat p_values // abro la matriz que guarde antes
gen var = _n // identificador de a qué outcome corresponde el pvalor. 
sort p_values1 // ordeno los p-valores de menor a mayor. 

gen alpha_corr = signif/(hyp+1-_n) // genero el nivel de significancia ajustado segun formula 

gen significant = (p_values1<alpha_corr) // marco con 1 a aquellos p-valores que son menor que el nivel de significancia ajustado. 

replace significant = 0 if significant[_n-1]==0 // le doy un cero a los que no son significativos. 


*odeno:
sort var 
 

*restauro
restore


* Almacenos los niveles de significatividad corregidos. 
* Rechazamos la hipotesis nula de treat = 0 si el p-valor original es menor que el nivel de significancia ajustado
mat alpha_corr_h = [0.0027778, 0.0035714, 0.016667, 0.00625, 0.055556, 0.0071429, 0.0045455, 0.01, 0.0125, 0.05, 0.005, 0.0029412, 0.0041667, 0.0083333, 0.0026316, 0.025, 0.0025, 0.0038462, 0.002381, 0.003125, 0.0033333] 


*---Queda agregar los niveles de significancia ajustados a la tabla. Hay que hacerlo para cada panel. 

*definimos un iterados para poder ir accediendo a los elementos de la matriz con los niveles de significancia ajustados.
scalar i = 1 

*--- PANEL A (Child's cognitive skills at follow up) 

local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
eststo clear 
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	scalar i = i + 1 	
} 
esttab using "$output/Cuadro2_panelA.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr blank N, fmt(3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" " " "Number of Observations"))


local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelA.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr blank N, fmt(3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" " " "Number of Observations"))


*--- PANEL B (Child's socio-emotional skills at follow up)

local bates "bates_difficult bates_unsociable bates_unstoppable" 
eststo clear
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelB.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr blank N, fmt(3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" " " "Number of Observations"))

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelB.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr blank N, fmt(3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" " " "Number of Observations")) 


*--- PANEL C (Material investments)


local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
eststo clear
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	scalar i = i + 1 
	
} 
esttab using "$output/Cuadro2_panelC.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr blank N, fmt(3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" " " "Number of Observations")) 


*--- PANEL D (Time investments) 

local fcitime "fci_play_act home_stories home_read home_toys home_name"
eststo clear
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelD.tex",  se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) /// 
stats(p_value corr_p_value alpha_corr blank N, fmt(3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" " " "Number of Observations")) 





* 4) Correccion de Benjamini, Krieger, and Yekutieli (2006)
*==============================================================================*

*---Ya tenemos los p_valores guardados en la matriz p_values. La abro y la guardo como un .dta:
preserve 
clear 
* abro la matriz para tratarla como una base de datos. 
svmat p_values
gen outcome = _n
rename p_values1 pval
save "$output/pvals.dta", replace
restore 


*--- Ahora toca usar Michael Anderson's code for sharpened q-values. 
* el input es la base de datos con los p-valores originales (que debo corregirlos)
* el output seran los p-valores corregidos
preserve

use "$output/pvals.dta", clear
version 10
set more off

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
	

quietly sort original_sorting_order
pause off
set more on

display "Code has completed."
display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
display	"Sorting order is the same as the original vector of p-values"

keep outcome pval bky06_qval
* ACA ESTÁ EL OUTPUT. es una base de datos con los p-valores corregidos. 
save "$output/sharpenedqvals.dta", replace  

* hay que notar que esta correccion puede reducir los p-valores.
* esto puede ocurrir cuando los outcomes estan muy correlacionados entre sí. 

restore  

*-- estas lineas son para ver el output 
preserve
use "$output/sharpenedqvals.dta", clear

restore
*--

*-- Almaceno los resultados en una matriz:

mat bky_pval = [0.001, 0.013, 0.407, 0.215, 0.179, 0.267, 0.12, 0.366, 0.398, 0.508, 0.143, 0.004, 0.038, 0.342, 0.001, 0.429, 0.001, 0.029, 0.001, 0.008, 0.009] 


*--Queda agregar estos p-valores ajustados a la tabla. Como antes, corro las regresiones y agrego por panel. 

*definimos un iterados para poder ir accediendo a los elementos de la matriz con los niveles de significancia ajustados.
scalar i = 1 

*--- PANEL A (Child's cognitive skills at follow up) 

local bayley "b_tot_cog b_tot_lr b_tot_le b_tot_mf"
eststo clear 
foreach y of local bayley{
local append append 
if "`y'"=="b_tot_cog" local append replace 
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_eva , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	estadd scalar bky_pval = bky_pval[1,i]
	scalar i = i + 1 	
} 
esttab using "$output/Cuadro2_panelA.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr bky_pval blank N, fmt(3 3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" "BKY Corrected P_value" " " "Number of Observations"))


local macarthur "mac_words mac_phrases"
foreach y of local macarthur{
	cap drop V*
	reg `y'1_st treat mac_words0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	estadd scalar bky_pval = bky_pval[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelA.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr bky_pval blank N, fmt(3 3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" "BKY Corrected P_value" " " "Number of Observations"))


*--- PANEL B (Child's socio-emotional skills at follow up)

local bates "bates_difficult bates_unsociable bates_unstoppable" 
eststo clear
foreach y of local bates{
	cap drop V*
	reg `y'1_st treat `y'0_st $covs_ent, cl(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	estadd scalar bky_pval = bky_pval[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelB.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr bky_pval blank N, fmt(3 3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" "BKY Corrected P_value" " " "Number of Observations"))

local roth "roth_inhibit roth_attention" 
foreach y of local roth{
	cap drop V*
	reg `y'1_st treat bates_difficult0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	estadd scalar bky_pval = bky_pval[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelB.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr bky_pval blank N, fmt(3 3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" "BKY Corrected P_value" " " "Number of Observations")) 


*--- PANEL C (Material investments)


local fcimat "fci_play_mat_type Npaintbooks Nthingsmove Ntoysshape Ntoysbought"
eststo clear
foreach y of local fcimat{
	cap drop V*
	reg `y'1_st treat fci_play_mat_type0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	estadd scalar bky_pval = bky_pval[1,i]
	scalar i = i + 1 
	
} 
esttab using "$output/Cuadro2_panelC.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) ///
stats(p_value corr_p_value alpha_corr bky_pval blank N, fmt(3 3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" "BKY Corrected P_value" " " "Number of Observations")) 


*--- PANEL D (Time investments) 

local fcitime "fci_play_act home_stories home_read home_toys home_name"
eststo clear
foreach y of local fcitime{
	cap drop V*
	reg `y'1_st treat fci_play_act0_st $covs_ent , cluster(cod_dane)
	eststo: test treat = 0
	estadd scalar p_value = r(p)
	estadd scalar corr_p_value = min(1,r(p)*hyp)
	estadd scalar alpha_corr = alpha_corr_h[1,i]
	estadd scalar bky_pval = bky_pval[1,i]
	scalar i = i + 1 
} 
esttab using "$output/Cuadro2_panelD.tex", p se replace label ///
keep(treat) ///
cells(b(fmt(3)) se(par fmt(3))) /// 
stats(p_value corr_p_value alpha_corr bky_pval blank N, fmt(3 3 3 3 0) labels("P_value" "Bonferroni Corrected P_value" "Holm Corrected Significance" "BKY Corrected P_value" " " "Number of Observations")) 








**********************************************-----FIN-----**********************************************	















 







