/*******************************************************************************
						  Problem Set 7: CLUSTER ROBUST INFERENCE
                          Universidad de San Andrés
                             Economía Aplicada
*******************************************************************************/
* Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth

/*******************************************************************************/

* 0) Set up environment
*==============================================================================*
global main "/Users/gasparhayduk/Desktop/Economía Aplicada/PS7"
global input "$main/input"
global output "$main/output"


* Abrimos la base de datos:
use "$input/base01.dta", clear 


* La ecuacion a estimar es:
*		bagrut_i,g = B*Treated_i,g + alpha*X_i,g + u_i,g

*Lo primero que hacemos para asegurarnos el balance entre los grupos tratamiento y control, es utilizar esta técnica de emparejamiento planteada en el paper. 
* En este caso, emparejar significa que cada escuela en el grupo de tratamiento fue emparejada con una escuela en el grupo de control que tenía una tasa de Bagrut similar en el pasado; y una vez hecho este emparejamiento, se asigna de manera aleatoria a uno de los dos. Esto ayuda a aislar el efecto del tratamiento al reducir el sesgo debido a las diferencias iniciales entre las escuelas.

 gen group = 1
 replace group = 2 if pair == 2 | pair == 4
 replace group = 3 if pair == 5 | pair == 8
 replace group = 4 if pair == 7
 replace group = 5 if pair == 9 | pair == 10
 replace group = 6 if pair == 11
 replace group = 7 if pair == 12 | pair == 13
 replace group = 8 if pair == 14 | pair == 15
 replace group = 9 if pair == 16 | pair == 17
 replace group = 10 if pair == 18 | pair == 20
 replace group = 11 if pair == 19
 
 *ahora utilizaremos una por una las cuatro estrategias propuestas para hacer inferencia.
 

eststo clear



*----------------------------------  ESTRATEGIA 1: ROBUST STANDARD ERRORS -------------------------------------
reg zakaibag treated semarab semrel boy i.group, robust
eststo: test treated
estadd scalar p_value=r(p)




*----------------------------------  ESTRATEGIA 2: CLUSTER ROBUST SE    ---------------------------------------
reg zakaibag treated semarab semrel boy i.group, cluster(group)
eststo: test treated
estadd scalar p_value=r(p)


*----------------------------------  ESTRATEGIA 3: WILD-BOOTSTRAP      ----------------------------------------
reg zakaibag treated semarab semrel boy i.group, cluster(group) 
eststo: boottest {treated} , boottype(wild) cluster(group) robust seed(123) 
mat p_wb = r(p)
estadd scalar p_value=r(p)


*----------------------------------  ESTRATEGIA 4: ARTs                -----------------------------------------
do "$main/programs/art.ado"

*Corremos:
eststo: art zakaibag treated semarab semrel boy, cluster(group)  m(regress) report(treated) //aca no podemos meter FE por cluster. 
estadd scalar p_value=r(pvalue_joint)



*------ Junto todo en una tabla. Reporto solo el coeficiente asociado a treated, el SE y el p-valor. Una columna por estrategia:
esttab using "$output/table_results.tex", p se replace label ///
keep(treated, relax) ///
cells(b(fmt(4) star) se(fmt(4) par)) ///
stats(p_value N, fmt(3 0) labels("P-Valor" "Observaciones")) 






