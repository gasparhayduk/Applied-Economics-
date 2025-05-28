/*******************************************************************************
                   Semana 5: Variables Instrumentales 
                          Universidad de San Andrés
                              Economía Aplicada
*******************************************************************************/
* Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth

/*******************************************************************************/

* 0) Set up environment
*==============================================================================*
global main "/Users/gasparhayduk/Desktop/Economía Aplicada/PS4"
global input "$main/input"
global output "$main/output"

cd "$main"

* Abrimos la base de datos:
use "$input/poppy.dta", clear


* 1) Inciso 1
*==============================================================================*

* Generamos la variable “Chinese presence” como se especifica en el paper. Para ello, utilizaremos una dummy que toma valor 0 si no existe presencia china dentro del municipio, y 1 en caso contrario. 

gen chinesepresence = 0
replace chinesepresence =1 if chinos1930hoy > 0 

* Labeleamos algunas variables:
label var cartel2010 "Cartel presence 2010"
label var cartel2005 "Cartel presence 2005"
label var chinesepresence "Chinese presence"
label var chinos1930hoy "Chinese population"
label var IM_2015 "Marginalization"
label var Impuestos_pc_mun "Per capita tax revenue"
label var n_index_p "Laakso and Taagepera index"
label var dalemanes "German presence"
label var tempopium "Poppy suitability"
label var distancia_km "Distance to U.S. (km)"
label var distkmDF "Distance to Mexico City (km)"
label var mindistcosta "Distance to closest port"
label var capestado "Head of state"
label var POB_TOT_2015 "Population in 2015 (in 000)"
label var superficie_km "Surface (000 km2)"
label var TempMed_Anual "Average temperature (Celsius)"
label var PrecipAnual_med "Average precipitation (mm)"
label var growthperc "Local population growth (1920-30)"
label var pob1930cabec "Population in 1930 (in 000)"




* 2) Inciso 2: Estadisticas Descriptivas y dropeo de obs de Distrito Federal
*==============================================================================*
* Dropeamos Distrito Federal
drop if estado == "Distrito Federal"


*Luego realizamos la tabla correspondiente. 

ssc install asdoc

asdoc tabstat cartel2010 cartel2005 chinesepresence chinos1930hoy IM_2015 ///
Impuestos_pc_mun n_index_p dalemanes tempopium distancia_km distkmDF mindistcosta ///
capestado POB_TOT_2015 superficie_km TempMed_Anual PrecipAnual_med growthperc pob1930cabec, ///
stat(mean sd min max) replace save(Cuadro_1.tex)



* Ejercicio 3
*==============================================================================*
*Para este ejercicio replicamos la tabla 5 del paper que presenta las 4 formas de medir la presencia de carteles. En nuestro caso, contamos únicamente con 2 de las 4 variables originales: presencia de carteles en 2010 y en 2005. 

*En primer lugar, realizamos las regresiones hechas por MCO, con y sin controles, cor errores cluster.


* (1) Cartel presence 2010 - Sin controles
eststo clear
eststo: reg cartel2010 chinesepresence i.id_estado, cluster(id_estado)
* Guardamos la información de esta regresión
estadd local statedummies "Yes" 
estadd local controls "No"
estadd local clusters = e(N_clust)

* (2) Cartel presence 2010 - Con controles
eststo: reg cartel2010 chinesepresence dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
* Guardamos la información de esta regresión
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* (3) Cartel presence 2005 - Sin controles
eststo: reg cartel2005 chinesepresence i.id_estado, cluster(id_estado)
* Guardamos la información de esta regresión
estadd local statedummies "Yes"
estadd local controls "No"
estadd local clusters = e(N_clust)

* (4) Cartel presence 2005 - Con controles
eststo: reg cartel2005 chinesepresence dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
* Guardamos la información de esta regresión
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Exportar la tabla a LaTeX
esttab using "$output/Cuadro_2.tex", replace ///
    se label noobs keep(chinesepresence) ///
    cells(b(star fmt(4)) se(par fmt(4)) p(fmt(3) par("[ ]"))) ///
    stats(statedummies controls clusters N, fmt(0 0 0 0) ///
    labels("State dummies" "Controls" "Clusters" "Observations")) ///





* 4) Inciso 4: replicacion Tabla 7
*==============================================================================*

* La ecuacion es: marginalization_i,s = alpha*cartel_presence + pi*controles + mu_s _ epsilon_i,s. i indexa municipalodad y s estado.
* se instrumenta cartel_presence con chinese presence in 1930. 

*--- Especificacion 1: sin controles y state dummies
eststo clear
eststo: ivregress 2sls IM_2015 (cartel2010 = chinesepresence) i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "No"
estadd local clusters = e(N_clust) 

*--- Especificacion 2: controles y state dummies. Es la basica
eststo: ivregress 2sls IM_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

*--- Especificacion 3: especifiacion basica solo para municipalidades a mas de 100km de la frontera 
eststo: ivregress 2sls IM_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado if distancia_km>=100, cluster(id_estado) 
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

*--- Especificacion 4: especificacion basica pero se excluyen municipalidades de Sinaloa:
preserve
drop if estado=="Sinaloa"

eststo: ivregress 2sls IM_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

restore


*--- Especificacion 5: controles para crecimiento poblacional local
eststo: ivregress 2sls IM_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado growthperc i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust) 


*--- Exportamos resultados:
esttab using "$output/Cuadro 3.tex", se replace label noobs ///
keep(cartel2010) ///
cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3) par(`"["' `"]"'))) ///
stats(ftest statedummies controls clusters N, fmt(2 3 0 0 0) ///
labels("F-test" "State dummies" "Controls" "Clusters" "Observations")) 



***** Replicacion Tabla 8: ahora la variable dependiente es cada uno de los componentes del indice de marginalizacion. Todas con la especificacion basica.

* Labeleamos los 9 componentes:
label var ANALF_2015 "Illiteracy"
label var SPRIM_2015 "Without primary"
label var OVSDE_2015 "Without toilet"
label var OVSEE_2015 "Without electricity"
label var OVSAE_2015 "Without water"
label var VHAC_2015 "Overcrowding"
label var OVPT_2015 "Earthen floor"
label var PL5000_2015 "Small localities"
label var PO2SM_2015 "Low salary"



* Columna 1: Illiteracy
eststo clear
eststo: ivregress 2sls ANALF_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Columna 2: Without primary
eststo: ivregress 2sls SPRIM_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)


* Columna 3: Without toilet
eststo: ivregress 2sls OVSDE_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Columna 4: without electricity
eststo: ivregress 2sls OVSEE_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Columna 5: without water
eststo: ivregress 2sls OVSAE_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Columna 6: overcrowding
eststo: ivregress 2sls VHAC_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Columna 7: earthen floor 
eststo: ivregress 2sls OVPT_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Columna 8: small localities
eststo: ivregress 2sls PL5000_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

* Columna 9: low salary
eststo: ivregress 2sls PO2SM_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
weakivtest
estadd scalar ftest = r(F_eff)
estadd local statedummies "Yes"
estadd local controls "Yes"
estadd local clusters = e(N_clust)

*** Exportamos Resultados
esttab using "$output/Cuadro 4.tex", se replace label noobs ///
keep(cartel2010) ///
cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3) par(`"["'`"]"'))) ///
stats(statedummies controls clusters N, fmt(0 0 2 0) ///
labels("State dummies" "Controls" "Clusters" "Observations")) 




* 4) Inciso 5: ¿Pueden testear la exogeneidad del instrumento?
*==============================================================================*

* Testeamos la exogeneidad de la presencia del cartel sabiendo que el instrumento es exógeno utilizando la especificación básica (segunda columna de la Tabla 7):
* La hipotesis nula es H0: variable exogena.
ivregress 2sls IM_2015 (cartel2010 = chinesepresence) dalemanes tempopium TempMed_Anual PrecipAnual_med superficie_km pob1930cabec distancia_km distkmDF mindistcosta capestado i.id_estado, cluster(id_estado)
estat endogenous
*el p-valor es 0.0036, menor a cualquier nivel de significancia, por lo que rechazamos la hipotesis nula de que la variable es exogena. 

*estat endogenous performs tests to determine whether endogenous regressors in the model are in fact exogenous (conditional on the instrument being exogenous). If the test statistic is significant, then the variables being tested must be treated as endogenous. This is not the case in our example.
* with an unadjusted VCE: the Durbin (1954) and Wu-Hausman statistics
* with a robust VCE, a robust score test (Wooldrigde 1995) and a robust regression-based test







