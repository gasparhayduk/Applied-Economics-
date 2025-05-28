/*******************************************************************************
						  Problem Set 6: DIFF-IN-DIFF
                          Universidad de San Andrés
                             Economía Aplicada
*******************************************************************************/
* Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth

/*******************************************************************************/

* 0) Set up environment
*==============================================================================*
global main "/Users/gasparhayduk/Desktop/Economía Aplicada/ProblemSet6_Consignas"
global input "$main/input"
global output "$main/output"

cd "$main"

* Abrimos la base de datos:
use "$input/castle.dta", clear

* 1) Inciso 1: 
*==============================================================================*
* Repliquen la Tabla 4 teniendo en cuenta que los resultados que encuentren pueden no ser exactamente iguales a los del paper. 

* define global macros
global crime1 jhcitizen_c jhpolice_c murder homicide  robbery assault burglary larceny motor robbery_gun_r 
global demo blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44 //demographics
global lintrend trend_1-trend_51 //state linear trend
global region r20001-r20104  //region-quarter fixed effects
global exocrime l_larceny l_motor // exogenous crime rates
global spending l_exp_subsidy l_exp_pubwelfare // variables de gasto
global xvar l_police unemployrt poverty l_income l_prisoner l_lagprisoner $demo $spending // time varying controles. 

label variable post "Year of treatment"

*Labeleo la variable post:
label variable post "Castle Doctrine Law" 
label var pre2_cdl "0 to 2 years before adoption of castle doctrine law"

* State está en formato string. Lo encodeo
encode state, gen(state_num)

* Declaro la estructura del panel:
xtset state_num year //state es el identificador de la unidad y 'year' como el temporal







*---------------------------------- REGRESIONES PANEL A: BURGLARY----------------------------------
* Este panel tiene 12 columnas. Las primeras 6 son weighted estimation y las ultimas 6 con OLS unweighted.

*-----(i) WEIGHTED OLS:

* Columna 1: state and year fixed effects:
qui xi: xtreg l_burglary post i.year  [aweight=popwt], fe vce(cluster sid) //corro la regresion 
est sto b1 //guardo el coeficiente de post

* Columna 2: adds region_by_year fixed effects:
qui xi: xtreg l_burglary post i.year $region [aweight=popwt], fe vce(cluster sid)
est sto b2 //guardo el coeficiente de post 

* Columna 3: adds time-varying controls
qui xi: xtreg l_burglary post i.year  $region $xvar [aweight=popwt], fe vce(cluster sid)
est sto b3 //guardo el coeficiente de post 

* Columna 4: incluides an indicator variable for the two years before the CDL was adopted:
qui xi: xtreg l_burglary post i.year  $region $xvar pre2_cdl [aweight=popwt], fe vce(cluster sid)
est sto b4 //guardo el coeficiente de post 

* Columna 5: drops the leading indicator but adds controls for contemporaneous larceny and motor vehicle theft (crimenes exogenos)
qui xi: xtreg l_burglary post i.year  $region $xvar $exocrime [aweight=popwt], fe vce(cluster sid)
est sto b5 //guardo el coeficiente de post 

*Columna 6: state fixed effects, region-by-year fixed effects, time-varying controls, and state-specific linear time trends.
qui xi: xtreg l_burglary post i.year  $region $xvar $lintrend [aweight=popwt], fe vce(cluster sid)
est sto b6 //guardo el coeficiente de post 


*-----(ii) UNWEIGHTED OLS:

* Columna 7: state and year fixed effects:
qui xi: xtreg l_burglary post i.year , fe vce(cluster sid)
est sto b7 //guardo el coeficiente de post 

* Columna 8: adds region_by_year fixed effects:
qui xi: xtreg l_burglary post i.year  $region, fe vce(cluster sid)
est sto b8 //guardo el coeficiente de post 
 
* Columna 9: adds time-varying controls
qui xi: xtreg l_burglary post i.year  $region $xvar, fe vce(cluster sid)
est sto b9 //guardo el coeficiente de post 

* Columna 10: incluides an indicator variable for the two years before the CDL was adopted:
qui xi: xtreg l_burglary post i.year $region $xvar pre2_cdl, fe vce(cluster sid)
est sto b10 //guardo el coeficiente de post 
 
* Columna 11: drops the leading indicator but adds controls for contemporaneous larceny and motor vehicle theft (crimenes exogenos)
qui xi: xtreg l_burglary post i.year  $region $xvar $exocrime, fe vce(cluster sid)
est sto b11 //guardo el coeficiente de post 

*Columna 12: state fixed effects, region-by-year fixed effects, time-varying controls, and state-specific linear time trends.
qui xi: xtreg l_burglary post i.year  $region $xvar $lintrend, fe vce(cluster sid)
est sto b12 //guardo el coeficiente de post 



*----------------------------------REGRESIONES PANEL B: ROBBERY----------------------------------
* Este panel tiene 12 columnas. Las primeras 6 son weighted estimation y las ultimas 6 con OLS unweighted.

*-----(i) WEIGHTED OLS:

* Columna 1: state and year fixed effects:
qui xi: xtreg l_robbery post i.year   [aweight=popwt], fe vce(cluster sid) //corro la regresion 
est sto r1 //guardo el coeficiente de post

* Columna 2: adds region_by_year fixed effects:
qui xi: xtreg l_robbery post i.year  $region [aweight=popwt], fe vce(cluster sid)
est sto r2 //guardo el coeficiente de post 

* Columna 3: adds time-varying controls
qui xi: xtreg l_robbery post i.year  $region $xvar [aweight=popwt], fe vce(cluster sid)
est sto r3 //guardo el coeficiente de post 

* Columna 4: incluides an indicator variable for the two years before the CDL was adopted:
qui xi: xtreg l_robbery post i.year  $region $xvar pre2_cdl [aweight=popwt], fe vce(cluster sid)
est sto r4 //guardo el coeficiente de post 

* Columna 5: drops the leading indicator but adds controls for contemporaneous larceny and motor vehicle theft (crimenes exogenos)
qui xi: xtreg l_robbery post i.year $region $xvar $exocrime [aweight=popwt], fe vce(cluster sid)
est sto r5 //guardo el coeficiente de post 

*Columna 6: state fixed effects, region-by-year fixed effects, time-varying controls, and state-specific linear time trends.
qui xi: xtreg l_robbery post i.year  $region $xvar $lintrend [aweight=popwt], fe vce(cluster sid)
est sto r6 //guardo el coeficiente de post 


*-----(ii) UNWEIGHTED OLS:

* Columna 7: state and year fixed effects:
qui xi: xtreg l_robbery post i.year i.state, fe vce(cluster sid)
est sto r7 //guardo el coeficiente de post

* Columna 8: adds region_by_year fixed effects:
qui xi: xtreg l_robbery post i.year  $region, fe vce(cluster sid)
est sto r8 //guardo el coeficiente de post
 
* Columna 9: adds time-varying controls
qui xi: xtreg l_robbery post i.year  $region $xvar, fe vce(cluster sid)
est sto r9 //guardo el coeficiente de post

* Columna 10: incluides an indicator variable for the two years before the CDL was adopted:
qui xi: xtreg l_robbery post i.year  $region $xvar pre2_cdl, fe vce(cluster sid)
est sto r10 //guardo el coeficiente de post
 
* Columna 11: drops the leading indicator but adds controls for contemporaneous larceny and motor vehicle theft (crimenes exogenos)
qui xi: xtreg l_robbery post i.year $region $xvar $exocrime, fe vce(cluster sid)
est sto r11 //guardo el coeficiente de post

*Columna 12: state fixed effects, region-by-year fixed effects, time-varying controls, and state-specific linear time trends.
qui xi: xtreg l_robbery post i.year  $region $xvar $lintrend, fe vce(cluster sid)
est sto r12 //guardo el coeficiente de post


*----------------------------------REGRESIONES PANEL C: AGGRAVATED ASSAULT----------------------------------
* Este panel tiene 12 columnas. Las primeras 6 son weighted estimation y las ultimas 6 con OLS unweighted.


*-----(i) WEIGHTED OLS:

* Columna 1: state and year fixed effects:
qui xi: xtreg l_assault post i.year [aweight=popwt], fe vce(cluster sid) //corro la regresion 
est sto a1 //guardo el coeficiente de post

* Columna 2: adds region_by_year fixed effects:
qui xi: xtreg l_assault post i.year  $region [aweight=popwt], fe vce(cluster sid)
est sto a2 //guardo el coeficiente de post 

* Columna 3: adds time-varying controls
qui xi: xtreg l_assault post i.year  $region $xvar [aweight=popwt], fe vce(cluster sid)
est sto a3 //guardo el coeficiente de post 

* Columna 4: incluides an indicator variable for the two years before the CDL was adopted:
qui xi: xtreg l_assault post i.year  $region $xvar pre2_cdl [aweight=popwt], fe vce(cluster sid)
est sto a4 //guardo el coeficiente de post 

* Columna 5: drops the leading indicator but adds controls for contemporaneous larceny and motor vehicle theft (crimenes exogenos)
qui xi: xtreg l_assault post i.year  $region $xvar $exocrime [aweight=popwt], fe vce(cluster sid)
est sto a5 //guardo el coeficiente de post 

*Columna 6: state fixed effects, region-by-year fixed effects, time-varying controls, and state-specific linear time trends.
qui xi: xtreg l_assault post i.year  $region $xvar $lintrend [aweight=popwt], fe vce(cluster sid)
est sto a6 //guardo el coeficiente de post 


*-----(ii) UNWEIGHTED OLS:

* Columna 7: state and year fixed effects:
qui xi: xtreg l_assault post i.year , fe vce(cluster sid)
est sto a7 //guardo el coeficiente de post

* Columna 8: adds region_by_year fixed effects:
qui xi: xtreg l_assault post i.year  $region, fe vce(cluster sid)
est sto a8 //guardo el coeficiente de post
 
* Columna 9: adds time-varying controls
qui xi: xtreg l_assault post i.year  $region $xvar, fe vce(cluster sid)
est sto a9 //guardo el coeficiente de post

* Columna 10: incluides an indicator variable for the two years before the CDL was adopted:
qui xi: xtreg l_assault post i.year  $region $xvar pre2_cdl, fe vce(cluster sid)
est sto a10 //guardo el coeficiente de post
 
* Columna 11: drops the leading indicator but adds controls for contemporaneous larceny and motor vehicle theft (crimenes exogenos)
qui xi: xtreg l_assault post i.year  $region $xvar $exocrime, fe vce(cluster sid)
est sto a11 //guardo el coeficiente de post

*Columna 12: state fixed effects, region-by-year fixed effects, time-varying controls, and state-specific linear time trends.
qui xi: xtreg l_assault post i.year  $region $xvar $lintrend, fe vce(cluster sid)
est sto a12 //guardo el coeficiente de post


* Crear una tabla con las regresiones de Burglary en formato LaTeX
esttab b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 using "$output/table1.tex", keep(post pre2_cdl) ///
prehead("\begin{tabular}{l*{12}{c}} \hline\hline") ///
posthead("\hline \\ \multicolumn{13}{c}{\textbf{Panel A: Burglary}} \\\\[-1ex]") ///
fragment ///
nomtitles ///
label ///
replace

* Añadir las regresiones de Robbery al mismo archivo LaTeX en el Panel B
esttab r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 using "$output/table1.tex", keep(post pre2_cdl) ///
posthead("\hline \\ \multicolumn{13}{c}{\textbf{Panel B: Robbery}} \\\\[-1ex]") ///
fragment ///
append ///
nomtitles nonumbers nolines ///
prefoot("\hline") ///
postfoot("\hline\hline \end{tabular}") ///
label

* Añadir las regresiones de Assault en el Panel C
esttab a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 using "$output/table1.tex", keep(post pre2_cdl)  ///
posthead("\hline \\ \multicolumn{13}{c}{\textbf{Panel C: Assault}} \\\\[-1ex]") ///
fragment ///
append ///
nomtitles nonumbers nolines ///
prefoot("\hline") ///
postfoot("\hline\hline \end{tabular}") ///
label






* 2) Inciso 2: 
*==============================================================================*

* Reproduzcan la Columna (1) del panel C de la Tabla 4 utilizando el estimador de Callaway y Sant’Anna’s (2020).
* Reporten el ATT simple. Grafiquen el impacto de la intervención para cuatro grupos y presente el gráfico de estudio de eventos
*Instalo por las dudas:
ssc install drdid
ssc install csdid

* This command requires that the year of treatment variable has a zero if the unit was never treated.
*treatment_date me dice el año en el que se sanciona la ley, tiene un . para los que nunca adoptan. 
replace treatment_date = 0 if treatment_date==.

* Estimo:
csdid l_assault i.year i.state_num, ivar(state_num) time(year) gvar(treatment_date) method(reg) notyet


*----Exporto el ATT simple: 
estat simple, estore(simple_att)
esttab simple_att using "$output/table2.tex", stats(N) replace

*-- Event study para toda la muestra:
estat event
csdid_plot, legend(label(1 "95% CI") label(2 "Pre-Treatment Coefficient") label(3 "95% CI") label(4 "Post-Treatment Coefficient"))
graph export "$output/event_study_plot.png", replace




*--Impacto de la intervención para cuatro grupos: 
csdid_plot, group(2005) name(m1,replace) title("Grupo 2005") style(rcap) legend(label(1 "95% CI") label(2 "Pre-Treatment Coefficient") label(3 "95% CI") label(4 "Post-Treatment Coefficient") region(lstyle(foreground)) rows(2) position(6))  
csdid_plot, group(2006) name(m2,replace) title("Grupo 2006") style(rcap) legend(label(1 "95% CI") label(2 "Pre-Treatment Coefficient") label(3 "95% CI") label(4 "Post-Treatment Coefficient") region(lstyle(foreground)) rows(2) position(6))
csdid_plot, group(2007) name(m3,replace) title("Grupo 2007") style(rcap) legend(label(1 "95% CI") label(2 "Pre-Treatment Coefficient") label(3 "95% CI") label(4 "Post-Treatment Coefficient") region(lstyle(foreground)) rows(2) position(6))
csdid_plot, group(2008) name(m4,replace) title("Grupo 2008") style(rcap) legend(label(1 "95% CI") label(2 "Pre-Treatment Coefficient") label(3 "95% CI") label(4 "Post-Treatment Coefficient") region(lstyle(foreground)) rows(2) position(6))
graph combine m1 m2 m3 m4, xcommon scale(0.8)
graph export "$output/impact_groups.png", replace


*----Pretrends test. Testeo tendencias previas
estat pretrend 
*La hipotesis nula es que todas las tendencias previas son paralelas. El p-valor es cero, por lo que rechazamos la hipotesis nula a cualq nivel de significancia. 





* 2) Inciso 3: 
*==============================================================================*
* Estimen nuevamente la Columna (1) del panel C de la tabla 4 utilizando el imputation estimator de Borusyak et al.(2021) sin usar variables de control.
* ¿Qué conclusión sacan de las tendencias previas? Comenten los resultados y las diferencias.

* Instalo por las dudas: capaz hay que instalar ftools y reghdfe
ssc install did_imputation

* Debemos volver a generar . en treatment_date:
replace treatment_date=. if treatment_date==0

* Estimo: SIN CONTROLES
did_imputation l_assault state_num year treatment_date, 

* Exporto resultados:
eststo modelo3

esttab modelo3 using "$output/table3.tex", replace

did_imputation l_assault state_num year treatment_date, pretrends(5)

*Exporto resultados:
eststo modelo4
esttab modelo4 using "$output/table4.tex", replace






