/*******************************************************************************
						  Problem Set 10: REGRESIÓN DISCONTINUA
                          Universidad de San Andrés
                             Economía Aplicada
*******************************************************************************/
* Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth

/*******************************************************************************/

* 0) Set up environment
*==============================================================================*
global main "\Users\marti\OneDrive\Documentos\Aplicada.stata\PS10"
global output "$main/output"
global input "$main/input"
cd "$output"


* Abrimos la base de datos:
use "$input/grades5.dta", clear 

** TO INSTALL STATA PACKAGES:
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
net install rdlocrand, from(https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata) replace
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/3084126ee0e5401cef662e1b7b3f0d802c319e7a/stata) replace


* Inciso a) 
*==============================================================================*
* Corra regresiones que relacionen el tamaño de la clase (classize) con las calificaciones en matemática y lengua.
label var classize "Tamaño de la clase"
label var avgmath "Nota promedio en Matemática"
label var avgverb "Nota promedio en Lengua"

eststo clear

*----CLASSIZE CONTRA NOTAS EN MATEMATICA
eststo: reg avgmath classize 


*----CLASSIZE CONTRA NOTAS EN LENGUA
eststo: reg avgverb classize 


*** Exportamos Resultados
esttab using "$output/table1.tex", se replace label noobs ///
keep(classize) ///
cells(b(star fmt(3)) se(par fmt(3)))


*Testeamos exogeneidad
estat ovtest

*Testeamos homocedasticidad
estat imtest, white



* Inciso b)
*==============================================================================*
* Corra las mismas regresiones, agregando los controles disponibles (porcentaje de estudiantes desfavorecidos e inscripción)

* Para crear una tabla desde cero:
eststo clear

*Labeleamos (al pedo porque solo mostraremos el coeficiente de classize)
label var enroll "Enrollment"
label var tip_a "Percent disadvantaged"

*----CLASSIZE CONTRA NOTAS EN MATEMATICA
eststo: reg avgmath classize enroll tip_a


*----CLASSIZE CONTRA NOTAS EN LENGUA
eststo: reg avgverb classize enroll tip_a 

*** Exportamos Resultados
esttab using "$output/table2.tex", se replace label noobs ///
keep(classize) ///
cells(b(star fmt(3)) se(par fmt(3))) 



* Inciso c)
*==============================================================================*
scatter classize enroll, title("Tamaño de clase vs Inscripción") ///
xline(40) msize(small)



* Inciso d)
*==============================================================================*

*Guardamos las globales relevantes para realizar los siguientes ejercicios.
global x enroll //running variable. 
global y1 avgmath // set y1 matemáticas
global y2 avgverb // set y2 lengua
global y avgmath avgverb // ambos outcomes 
global covs "tip_a"

* 1) Density discontinuity test. Quiero mostrar que no hay manipulacion en la running variable 
rddensity $x, c(40)


* 2) Placebo tests on pre-determined covariates.  
*En este caso no tenemos covariable para realizar el testeo. 


* Inciso e) 
*==============================================================================*
*En primer lugar, realizaremos las regresiones RDD para las calificaciones en matemática, usando el enfoque de continuity-based approach

* RDD para grado 1
rdrobust $y1 $x, c(40) p(1) masspoints(off) stdvars(on)
rdplot $y1 $x, c(40) p(1) title("RDD - Polinomio Grado 1") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en matemática"))

* RDD para grado 2
rdrobust $y1 $x, c(40) p(2) masspoints(off) stdvars(on)
rdplot $y1 $x, c(40) p(2) masspoints(off) title("RDD - Polinomio Grado 2") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en matemática"))

* RDD para grado 3
rdrobust $y1 $x, c(40) p(3) masspoints(off) stdvars(on)
rdplot $y1 $x, c(40) p(3) title("RDD - Polinomio Grado 3") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en matemática"))

* RDD para grado 4
rdrobust $y1 $x, c(40) p(4) masspoints(off) stdvars(on)
rdplot $y1 $x, c(40) p(4) title("RDD - Polinomio Grado 4") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en matemática"))

*Luego, continuamos con Lengua 
* RDD para grado 1
rdrobust $y2 $x, c(40) p(1) masspoints(off) stdvars(on)
* Gráfico
rdplot $y2 $x, c(40) p(1) masspoints(off) title("RDD - Polinomio Grado 1") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en lengua"))

* RDD para grado 2
rdrobust $y2 $x, c(40) p(2) masspoints(off) stdvars(on)
* Gráfico
rdplot $y2 $x, c(40) p(2) masspoints(off) title("RDD - Polinomio Grado 2") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en lengua"))

* RDD para grado 3
rdrobust $y2 $x, c(40) p(3) masspoints(off) stdvars(on)
* Gráfico
rdplot $y2 $x, c(40) p(3) masspoints(off) title("RDD - Polinomio Grado 3") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en lengua"))

* RDD para grado 4
rdrobust $y2 $x, c(40) p(4) masspoints(off) stdvars(on)
* Gráfico
rdplot $y2 $x, c(40) p(4) masspoints(off) title("RDD - Polinomio Grado 4") ///
graph_options(graphregion(color(white)) xtitle("Enrollment") ytitle("Nota en lengua"))


* Inciso f)
*==============================================================================*
* Bandwidth 10
rdrobust $y1 $x, c(40) h(10) p(2) masspoints(off) stdvars(on)

* Bandwidth 15
rdrobust $y1 $x, c(40) h(15) p(2) masspoints(off) stdvars(on)

* Bandwidth 7
rdrobust $y1 $x, c(40) h(7) p(2) masspoints(off) stdvars(on)


* Inciso e:  
*==============================================================================*
* Creamos la variable instrumental zs (Regla de Maimónides)
gen zs = enroll / (floor((enroll - 1) / 40) + 1)


* Realizamos la estimación IV con zs como instrumento para classize para calificaciones en matemática
ivregress 2sls avgmath (classize = zs) 

* Resultados de las calificaciones de lengua
ivregress 2sls avgverb (classize = zs) 




