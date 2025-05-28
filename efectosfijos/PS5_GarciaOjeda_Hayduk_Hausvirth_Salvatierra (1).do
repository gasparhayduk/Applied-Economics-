/*******************************************************************************
                   Universidad de San Andrés
                       Economía Aplicada
							2024
				  Problem Set 5: Efectos fijos
*******************************************************************************/
* Juan Gabriel García Ojeda; Gaspar Hayduk; Martina Hausvirth; Elias Lucas D. Salvatierra; 
/*******************************************************************************/

* 0) Set up environment
*==============================================================================*
* Se definen rutas globales para las carpetas principales, de entrada y de salida
*global main "/Users/lucassalvatierra/Desktop/Aplicada PS6"
global main "C:\Users\Usuario\OneDrive\Juanga\OneDrive\JUANGA\Maestria\Udesa\Economia Aplicada\Problem sets\PS5"
global input "$main/input"
global output "$main/output"

* Se cambia el directorio de trabajo a la carpeta principal y se cargan los datos desde la carpeta de entrada.
*cd "$main"
use "$input/microcredit.dta", clear

* Se reemplazan los valores de la variable 'year' para corregir la codificación de los años.
replace year = 1991 if year==0
replace year = 1998 if year==1

* Se establecen los datos en formato de panel, con 'nh' como identificador de la unidad y 'year' como el temporal.
xtset nh year

* Se instalan los paquetes necesarios: reghdfe para regresiones con efectos fijos de alta dimensión, y ftools para manejo eficiente de datos.
*ssc install reghdfe
*ssc install ftools

* 1) Baseline specification
*==============================================================================*

* Se generan las variables de la especificación base.
* Se crea la variable 'l_exptot' que es el logaritmo de 'exptot'.
gen l_exptot = log(exptot)

* Se asignan etiquetas descriptivas a las variables 'l_exptot' (gasto en log) y 'dfmfd' (participación femenina).
label var l_exptot "Gasto (log)"
label var dfmfd "Participación femenina"

* Se realiza una regresión del logaritmo del gasto sobre la participación femenina.
reg l_exptot dfmfd

* Se exportan los resultados de la regresión a un archivo LaTeX con etiquetas adicionales sobre los efectos fijos y controles no incluidos.
outreg2 using "$output/Tabla 1.tex", dec(4) label addtext(Efectos fijos por aldea, No, Efectos fijos por hogar, No, Efectos fijos por año, No, Controles, No) replace


* 2) Fixed effects
*==============================================================================*
* Se estima un modelo de regresión absorbiendo efectos fijos por hogar (nh) y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(nh) 
outreg2 using "$output/Tabla 2.tex", dec(4) label  addtext(Efectos fijos por aldea, No, Efectos fijos por hogar, Sí, Efectos fijos por año, No, Efectos fijos por aldea x año, No, Efectos fijos por hogar x año, No, Controles, No) replace

* Se estima un modelo absorbiendo efectos fijos por año y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(year) 
outreg2 using "$output/Tabla 3.tex", dec(4) label  addtext(Efectos fijos por aldea, No, Efectos fijos por hogar, No, Efectos fijos por año, Sí, Efectos fijos por aldea x año, No, Efectos fijos por hogar x año, No, Controles, No) append

* Se estima un modelo absorbiendo efectos fijos por aldea (villid) y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(village) 
outreg2 using "$output/Tabla 4.tex", dec(4) label  addtext(Efectos fijos por aldea, Sí, Efectos fijos por hogar, No, Efectos fijos por año, No, Efectos fijos por aldea x año, No, Efectos fijos por hogar x año, No, Controles, No) replace

* Se absorben efectos fijos tanto por aldea como por hogar y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(nh village) 
outreg2 using "$output/Tabla 5.tex", dec(4) label  addtext(Efectos fijos por aldea, Sí, Efectos fijos por hogar, Sí, Efectos fijos por año, No, Efectos fijos por aldea x año, No, Efectos fijos por hogar x año, No, Controles, No) replace

* Se absorben efectos fijos por hogar y por año, y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(nh year) 
outreg2 using "$output/Tabla 6.tex", dec(4) label  addtext(Efectos fijos por aldea, No, Efectos fijos por hogar, Sí, Efectos fijos por año, Sí, Efectos fijos por aldea x año, No, Efectos fijos por hogar x año, No, Controles, No) append

* Se absorben efectos fijos por aldea y por año, y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(village year) 
outreg2 using "$output/Tabla 7.tex", dec(4) label  addtext(Efectos fijos por aldea, Sí, Efectos fijos por hogar, No, Efectos fijos por año, Sí, Efectos fijos por aldea x año, No, Efectos fijos por hogar x año, No, Controles, No) replace

* Se genera una nueva variable de interacción entre aldea y año
gen village_year = village*year
* Se estima un modelo absorbiendo efectos fijos por aldea × año, y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(village_year) 
outreg2 using "$output/Tabla 8.tex", dec(4) label  addtext(Efectos fijos por aldea, No, Efectos fijos por hogar, No, Efectos fijos por año, No, Efectos fijos por aldea x año, Sí, Efectos fijos por hogar x año, No, Controles, No) replace

* Se genera una nueva variable de interacción entre hogar y año.
gen nh_year = nh*year
* Se absorben efectos fijos por hogar × año, y se exportan los resultados.
*reghdfe l_exptot dfmfd, absorb(nh_year) 
*outreg2 using "$output/Tabla 9.tex", dec(4) label  addtext(Efectos fijos por aldea, No, Efectos fijos por hogar, No, Efectos fijos por año, No, Efectos fijos por aldea x año, No, Efectos fijos por hogar x año, Sí, Controles, No) replace

*NO SE PUEDE ESTIMAR CON ESTA INTERACCION, MAS VARIABLES QUE DATOS DISPONIBLES. 

egen tag = tag(nh year)
count if tag == 1

* Se absorben efectos fijos por aldea × año y por hogar, y se exportan los resultados.
reghdfe l_exptot dfmfd, absorb(village_year  nh) 
outreg2 using "$output/Tabla 10.tex", dec(4) label  addtext(Efectos fijos por aldea, No, Efectos fijos por hogar, Sí, Efectos fijos por año, No, Efectos fijos por aldea x año, Sí, Efectos fijos por hogar x año, No, Controles, No) replace
