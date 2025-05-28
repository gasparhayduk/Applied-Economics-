/*******************************************************************************
						  Problem Set 11: MATCHING
                          Universidad de San Andrés
                             Economía Aplicada
*******************************************************************************/
* Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth

/*******************************************************************************/

* 0) Set up environment
*==============================================================================*
clear all
global main "/Users/gasparhayduk/Desktop/Economía Aplicada/ps11"
global output "$main/output"
global input "$main/input"
cd "$output"


*==============================================================================*

* Abrimos la data:
use "$input/base_censo.dta", clear


*==============================================================================*
* Inciso 1: test de medias para pobl_1999, via1, ranking_pobr 
ttest pobl_1999, by(treated)
ttest via1, by(treated)
ttest ranking_pobr, by(treated)
*La hipotesis nula del test es que las medias son iguales. Los pvalores son 0.0071, 0.0028 y 0.07. 
* como todos son menores a 0.10, rechazo H0. 



*==============================================================================*
* Inciso 2: calculo del PS.
* Calculate propensity score
probit treated ind_abs_pobr ldens_pob prov_cap pob_1 pob_2 pob_3 pob_4 km_cap_prov via3 via5 via7 via9 region_2 region_3 laltitud tdesnutr deficit_post deficit_aulas
predict p_score

* Hay missing values. los dropeamos:
drop if  p_score==. 


*==============================================================================*
* Inciso 3: Distribucion del PS para tratados y no tratados:

*Falta guardar la figura. Esta es la que va
twoway (kdensity p_score if treated==1, lwidth(thick) lpattern(solid) lcolor(green)) ///
       (kdensity p_score if treated==0, lwidth(thick) lpattern("_####_####") lcolor(red)) ///
       , scheme(s1mono) legend(lab(1 "Treated") lab(2 "Not treated")) ///
       xtitle("Propensity Score") ytitle("Density") 
	   
* Exporto el grafico
graph export "$output/figura1.png", replace 

*==============================================================================*
* Inciso 4: Generar una dummy que valga 1 si la obs esta dentro del common support
bysort treated: summ p_score
egen x = min(p_score) if treated==1
egen psmin = min(x)
*min PS for treated group 
egen y = max(p_score) if treated==0
egen psmax=max(y)
*max PS for treated group
drop x y
gen common_sup=1 if (p_score>=psmin & p_score<=psmax) & p_score!=.
*genero una dummy que indique si cada obs esta o no dentro del common support
replace common_sup=0 if common_sup==.


* Dropeamos las obs que estan fuera del CS:
drop if common_sup==0


*==============================================================================*
* Corremos lineas para matchear distritos tratados con distritos no tratados:
* ssc install psmatch2 
psmatch2 treated if common_sup==1, p(p_score) noreplacement
gen matches=_weight
replace matches=0 if matches==. 



*==============================================================================* 
* Inciso 6: graficar nuevamente la distribucion del PS para ambos grupos pero considerando la submuestra matches==1

preserve
keep if matches == 1


* Falta guardar la figura. Esta es la que va
twoway (kdensity p_score if treated==1, lwidth(thick) lpattern(solid) lcolor(green)) ///
       (kdensity p_score if treated==0, lwidth(thick) lpattern("_####_####") lcolor(red)) ///
       , scheme(s1mono) legend(lab(1 "Treated") lab(2 "Not treated")) ///
       xtitle("Propensity Score") ytitle("Density")

	   * Exporto el grafico
graph export "$output/figura2.png", replace 
	   
restore

*==============================================================================* 
* Inciso 7: Repetir los tests de medias pero solo para la submuestra matches==1


*Testeamos 
ttest pobl_1999 if matches == 1, by(treated)
ttest via1 if matches == 1, by(treated)
ttest ranking_pobr if matches == 1, by(treated)



* Ahora sí no rechazamos H0 de medias iguales













