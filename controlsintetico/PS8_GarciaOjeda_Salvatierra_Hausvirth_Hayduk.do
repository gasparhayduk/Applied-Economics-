/*******************************************************************************
							   Problem Set 8
							 Control sintético
                          Universidad de San Andrés
                              Economía Aplicada
*******************************************************************************
* Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth

*******************************************************************************/

* 0) Set up environment
*==============================================================================*

*==============================================================================*
global main "/Users/gasparhayduk/Desktop/Economía Aplicada/ConsignasPS8"
global output "$main/output"
global input "$main/input"

cd "$output"

* Importo el dataset. Usamos la base df.csv
import delimited "$input/df.csv", clear

* Las variable state es categórica string y encima con errores de escritura, la pasamos a código
encode state, generate(state2)
drop state
rename state2 state

* Arreglo los labels que se importaron mal 
label define state2 3 "Amapá" 6 "Ceará" 8 "Espírito Santo" 9 "Goiás" 10 "Maranhao" 15 "Paraíba" 16 "Pará" 14 "Paraná" 18 "Piauí" 22 "Rondonia" 26 "Sao Paulo", modify
label values state state2

* Aclarar a Stata que es un panel
tsset state year

* Guardamos la base
save "df.dta", replace 

* 1) Réplica graficos del paper de Freire

* ---- FIGURA 1: Homicide rates per 100,000 population: São Paulo and Brazil (excluding the state of São Paulo)---- *
* La primer figura es simplemente la evolución histórica de la tasa de homicidios por 100k habitantes en San Pablo en relación con el promedio. La aplicacion de la politica fue en 1999

* Obtenemos el promedio de homicidios para el resto de Estados de Brasil
bysort year: egen hr_promedio_resto = mean(homiciderates) if state != 26

* Me quedo con los datos solo de Sao Paulo
gen hr_sp = .
replace hr_sp = homiciderates if state == 26

* Armamos el gráfico
twoway (line hr_sp year, lwidth(medium) lpattern(solid)) ///
       (line hr_promedio_resto year, lwidth(medium) lpattern(dash)), ///
       ytitle("Homicide Rates") xtitle("Year") ///
       legend(order(1 "São Paulo" 2 "Brazil (average)") pos(6)) ///
       xline(1999, lpattern(dash) lcolor(black)) ///
       text(50 2000 "Policy Change", place(e) size(medium))

* Exporto el grafico
graph export "$output/figura1.png", replace


* ---- FIGURA 2: Trends in homicide rates: São Paulo versus synthetic São Paulo.---- *
/* La segunda figura surge luego de la construcción del Sao Paulo sintético. Lo que realiza es la evolución del sintético y de Sao Paulo. 
Las variables de control que utiliza son: stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent */

* Instalar el comando
*ssc install synth

* Estimamos el sintético
synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1998), trunit(26) trperiod(1999) nested fig

* Exporto el grafico
graph export "$output/figura2.png", replace

* ---- FIGURA 3: Homicide rates gap between São Paulo and synthetic São Paulo.---- *
/* Grafico con la misma info del 2, sólo que considera el gap pretratamiento entre Sao Paulo y el sintético.
Hay que volver a cargar la base de datos y correr de nuevo el synth porque sino se grafica mal (no termino de entender bien por que pasa).*/

* Cargamos la base de datos
use "$output/df.dta", clear
tsset state year

* Estimamos el sintético
synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1998), trunit(26) trperiod(1999) nested

* Obtenemos el gap
matrix gaps=e(Y_treated) -e(Y_synthetic)
matrix Y_treated=e(Y_treated)
matrix Y_synthetic=e(Y_synthetic)
keep year 
svmat gaps 
svmat Y_treated
svmat Y_synthetic
*svmat hace que las columnas de las matrices se vuelvan variables. 

* Graficamos 
twoway (line gaps1 year, lwidth(medium) lpattern(solid)), ///
       ytitle("Gaps Homicide Rates") xtitle("Year") ///
       xline(1999, lpattern(dash) lcolor(black)) ///
	   yline(0, lpattern(dash) lcolor(black)) ///
       text(50 2000 "Policy Change", place(e) size(medium)) ///
	   yscale(range(-30 30))
	   
* Exporto el grafico
graph export "$output/figura3.png", replace

	   
* ---- FIGURA 4: Placebo policy implementation in 1994: São Paulo versus synthetic São Paulo.---- *
/* En este gráfico se incluye un placebo en 1994, es decir, se corre el modelo como si el tratamiento hubiera sido hecho en 1994 (cuando en realidad fue en 1999)*/

* Cargamos la base de datos
use "$output/df.dta", clear
tsset state year

* Estimamos el sintético cambiando el año de tratamiento (1994)
synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1993), trunit(26) trperiod(1994) nested fig

* Exporto el grafico
graph export "$output/figura4.png", replace


* ---- FIGURA 5: Leave-one-out distribution of the synthetic control for São Paulo---- *
* Leave one out. En esta figura lo que hace es estimar el sintético para Sao Paulo con los n-1 estados restantes (siendo n los estados con los que estimaba antes). En cada estimación saca un Estado distinto. La idea es mostrar que no importa con que Estados lo haciamos igual nos daba diferencias post tratamiento entre Sao Paulo y su sintetico

* Cargamos la base de datos
use "$output/df.dta", clear
tsset state year

* Estimamos el sintético
synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1998), trunit(26) trperiod(1999) nested

* Queremos saber que Estados eran utilizados para contruir el sintetico original (es decir, aquellos para los cuales el peso era >0)
* En e(W_weights) se guardan los pesos de cada unidad
mat list e(W_weights)

* El sintetico se construye usando a  Distrito Federal (7),  Maranhao (10), Minas Gerais (13) y Rio de Janeiro (21)
* Vamos a correr nuevos sinteticos sacando de a uno los estados que forman del Sao Paulo sintetico para ver si no hay ningun estado driving the results

* Cargamos la base de datos
use "$output/df.dta", clear
tsset state year

tempname resmat
        local i 26
        qui synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1998), trunit(`i') trperiod(1999) nested keep(loo-resout`i', replace)
		*primero estimo para sao paulo. la base loo-resout26 es el sintetico para SP usando TODOS los estados del donor pool
		
		
		*ahora construyo todos los sintetiticos posibles para sao paulo sacando de a uno a los estados del donor pool. siempre le aplico el tratamiento a sao paulo
		*quiero mostrar que el efecto se mantiene aunque vaya sacando de uno del donor pool. quiero decir que no hay ningun estado driving the results. 
		local i 26
		forvalues j=1/27 {
		if `j'== 26 { 
		continue
		}
		use "$output/df.dta", clear
		tsset state year 
		* sacamos un estado
		drop if state==`j'
		* corremos el sintetico
        qui synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1998), trunit(`i') trperiod(1999) nested keep(loo-resout`j', replace)	
		* la base loo-resoutj me dice el sintetico para SP excluyendo al estado j
        }
		
* volvemos a mergear las bases individuales
forvalues i = 1/27 {
use "$output/loo-resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$output/loo-resout`i'.dta", replace
}

use "$output/loo-resout1.dta", clear
forvalues i = 2/27 {
merge 1:1 _Co_Number _time using "$output/loo-resout`i'.dta", nogen
}

*twoway (line _Y_synthetic_20 _time, lcolor(grey)) (line _Y_synthetic_21 _time, lcolor(grey)) (line _Y_treated_26 _time, lcolor(black) lwidth(thick)) (line _Y_synthetic_26 _time, lcolor(black) lpattern(dash)), xline(1999) legend(off)

*twoway (line _Y_synthetic_20 _time, lcolor(grey) lwidth(medium) lpattern(solid)) ///
*      (line _Y_synthetic_21 _time, lcolor(grey) lwidth(medium) lpattern(solid)) ///
*       (line _Y_treated_26 _time, lcolor(black) lwidth(thick)) ///
*       (line _Y_synthetic_26 _time, lcolor(black) lpattern(dash)), ///
*      xline(1999) ///
*       legend(order(3 "SP" 4 "Synthetic SP" 1 "Synthetic SP (leave-one-out)") ///
*              rows(1) position(6) colgap(5))
			  
twoway (line _Y_synthetic_7 _time, lcolor(gray) lwidth(medium) lpattern(solid)) ///
       (line _Y_synthetic_10 _time, lcolor(gray) lwidth(medium) lpattern(solid)) ///
	   (line _Y_synthetic_13 _time, lcolor(gray) lwidth(medium) lpattern(solid)) ///
	   (line _Y_synthetic_21 _time, lcolor(gray) lwidth(medium) lpattern(solid)) ///
       (line _Y_treated_26 _time, lcolor(black) lwidth(thick)) ///
       (line _Y_synthetic_26 _time, lcolor(black) lpattern(dash)), ///
       xline(1999) ///
       legend(order(3 "SP" 4 "Synthetic SP" 1 "Synthetic SP (leave-one-out)") ///
              rows(1) position(6) colgap(5))			  



* Exporto el grafico
graph export "$output/figura5.png", replace


* ---- FIGURA 6: Permutation test: Homicide rate gaps in São Paulo and twenty-six control states---- *
* Tengo que aplicarle el tratamiento a los demas estados y ver qué onda. 
* El gap para SP deberia hacerse negativo desp de 1999 mientras que el gap para los demas estados deberia tener movimientos aleatorios (algunos para arriba y otros para abajo)

* Cargamos la base de datos
use "$output/df.dta", clear
tsset state year

tempname resmat
        local i 26
        qui synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1998), trunit(`i') trperiod(1999) nested keep(resout`i', replace)
		
* Resout es una matriz que nos guarda para cada "year": outcome sintetico, outcome treated, y weights. 
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
        local names `"`names' `"`i'"'"'
        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")

		*saco a SP y aplico el tratamiento a estados fakes
		drop if state == 26

        forvalues i = 1/27 {
		if `i'==26 { 
		continue
		}
        qui synth homiciderates stategdpcapita yearsschoolingimp populationprojectionln giniimp populationextremepovertyimp stategdpgrowthpercent homiciderates(1990(1)1998), trunit(`i') trperiod(1999) keep(resout`i', replace)
        matrix `resmat' = nullmat(`resmat') \ e(RMSPE)
		* Nos guardamos el MSPE. mean squared prediction error
        local names `"`names' `"`i'"'"'
        }

        mat colnames `resmat' = "RMSPE"
        mat rownames `resmat' = `names'
        matlist `resmat' , row("Treated Unit")
		
* Si corremos hasta aca, podemos notar que las unidades tratadas cuyo RMSPE supera al de Sao Paulo en mas de 2 veces son las unidades 1, 3, 12, 21, 8, 23 y 27. Estas unidades se excluiran en la figura 7

* fijemonos que contiene cada base resout`i'
use "$output/resout26.dta", clear 
* el 26 es el tratamiento aplicado a SP, el 1 aplicado a Acre, el 2 aplicado a Alagoas, etc.. 
* tengo una base por estado, en la que se dice qué peso se le da a cada estado, el outcome del estado y el outcome sintetico para cada año. 

* mergeo todas las bases. 
* renombro variables de cada base individual para despues hacer un merge. 
forvalues i = 1/27 {
use "$output/resout`i'.dta", clear
ren _Y_synthetic _Y_synthetic_`i'
ren _Y_treated _Y_treated_`i'
gen _Y_gap_`i'=_Y_treated_`i'-_Y_synthetic_`i'
save "$output/resout`i'.dta", replace
}

use "$output/resout1.dta", clear
forvalues i = 2/27 {
merge 1:1 _Co_Number _time using "$output/resout`i'.dta", nogen
}
* hasta aca tengo todos los merges. 

* Grafico los gaps:
twoway (line _Y_gap_1 _time, lcolor(gray)) (line _Y_gap_2 _time, lcolor(gray)) (line _Y_gap_3 _time, lcolor(gray)) ///
       (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) ///
       (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_8 _time, lcolor(gray)) (line _Y_gap_9 _time, lcolor(gray)) ///
       (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray)) (line _Y_gap_12 _time, lcolor(gray)) ///
       (line _Y_gap_13 _time, lcolor(gray)) (line _Y_gap_14 _time, lcolor(gray)) (line _Y_gap_15 _time, lcolor(gray)) ///
       (line _Y_gap_16 _time, lcolor(gray)) (line _Y_gap_17 _time, lcolor(gray)) (line _Y_gap_18 _time, lcolor(gray)) ///
       (line _Y_gap_19 _time, lcolor(gray)) (line _Y_gap_20 _time, lcolor(gray)) (line _Y_gap_21 _time, lcolor(gray)) ///
       (line _Y_gap_22 _time, lcolor(maroon)) (line _Y_gap_23 _time, lcolor(gray)) (line _Y_gap_24 _time, lcolor(gray)) ///
       (line _Y_gap_25 _time, lcolor(gray)) (line _Y_gap_27 _time, lcolor(gray)) (line _Y_gap_26 _time, lcolor(red) lwidth(thick)), ///
       xline(1999) legend(off) xtitle("Year") name(gg2, replace)
	   
graph export "$output/figura6.png", replace

	   
*------------  Figura 7: Permutation test: Homicide rate gaps in Sao Paulo and selected control states ------------
* las unidades tratadas cuyo RMSPE supera al de Sao Paulo en mas de 2 veces son las unidades 1, 3, 12, 21, 8, 23 y 27. Estas unidades se excluiran en la figura 7
* Grafico los gaps:
twoway (line _Y_gap_2 _time, lcolor(gray)) ///
       (line _Y_gap_4 _time, lcolor(gray)) (line _Y_gap_5 _time, lcolor(gray)) (line _Y_gap_6 _time, lcolor(gray)) ///
       (line _Y_gap_7 _time, lcolor(gray)) (line _Y_gap_9 _time, lcolor(gray)) ///
       (line _Y_gap_10 _time, lcolor(gray)) (line _Y_gap_11 _time, lcolor(gray))  ///
       (line _Y_gap_13 _time, lcolor(gray)) (line _Y_gap_14 _time, lcolor(gray)) (line _Y_gap_15 _time, lcolor(gray)) ///
       (line _Y_gap_16 _time, lcolor(gray)) (line _Y_gap_17 _time, lcolor(gray)) (line _Y_gap_18 _time, lcolor(gray)) ///
       (line _Y_gap_19 _time, lcolor(gray)) (line _Y_gap_20 _time, lcolor(gray))  ///
       (line _Y_gap_22 _time, lcolor(maroon)) (line _Y_gap_24 _time, lcolor(gray)) ///
       (line _Y_gap_25 _time, lcolor(gray)) (line _Y_gap_26 _time, lcolor(red) lwidth(thick)), ///
       xline(1999) legend(off) xtitle("Year") name(gg2, replace)


graph export "$output/figura7.png", replace
