/**************************************************************************************
                               Problem Set 1

                          Universidad de San Andrés
                              Economía Aplicada
									2024				
Gaspar Hayduk; Juan Gabriel García Ojeda; Elias Lucas Salvatierra; Martina Hausvirth
**************************************************************************************/

* 0) Set up environment
*==============================================================================*
clear all // borro cualquiera cosa que esté abierta


* Save path in local or global:
global main "/Users/gasparhayduk/Desktop/Economía Aplicada/PS1" //cambiar según directorio de cada uno
global input "$main/input"
global output "$main/output"

* Base de datos:
use "$input/data_russia.dta", clear
*==============================================================================*



* 1) Cleaning data: incisos 1, 2, 3 y 4. 
*==============================================================================*

*Visualizing data
*browse 

*Si corremos 'codebook' nos dirá qué tipo de data es cada variable. El objetivo de esta sección es transformar todas las variables a numericas. 

***---- Las variables econrk, powrnk, evalhl, geo, resprk, satlif, wtchng, hhpres, work0, work1, work2 (y algunas mas) tienen string cuando deberian tener numeros. Por ejemplo, tienen 'four' en lugar de 4, y cuando es 4 es "4".
* Estas variables son CATEGORICAS (creo), cada valor representa una categoria. 
* Primero paso todo al mismo tipo de string, es dificil trabajar con "two" y "2", prefiero tener uno de los dos.
* despues uso encode para pasarlo a numerica. 

* Tabuleo para ver los valores posibles:
foreach var of varlist econrk powrnk evalhl geo resprk satlif wtchng marsta1 marsta2 marsta3 hhpres work0 work1 work2 satecc highsc belief cmedin hprblm hosl3m operat hattac alclmo ortho hhpres {
	tab `var'
}


* Paso todo a un mismo tipo de string, donde dice "two" lo convertimos en "2". y convertimos todos los missing a una misma categoria. 
foreach var of varlist econrk powrnk evalhl geo resprk satlif wtchng marsta1 marsta2 marsta3 hhpres work0 work1 work2 satecc highsc belief cmedin hprblm hosl3m operat hattac alclmo ortho  hhpres {
	replace `var' = "1" if `var' == "one"
	replace `var' = "2" if `var' == "two"
	replace `var' = "3" if `var' == "three"
	replace `var' = "4" if `var' == "four"
	replace `var' = "5" if `var' == "five"
	replace `var' = "6" if `var' == "six"
	replace `var' = "7" if `var' == "seven"
	replace `var' = "8" if `var' == "eight"
	replace `var' = "9" if `var' == "nine"
	replace `var' = "."   if `var' == ".b"
	replace `var' = "."   if `var' == ".c"
	replace `var' = "."   if `var' == ".d"
	replace `var' = "0" if `var' =="zero"
}


* Defino el label para encode:

label define mylabel 0  "0" 1  "1" 2  "2" 3  "3"  4  "4" 5  "5" 6  "6" 7  "7" 8  "8" 9  "9" 50 "."  // 50 será mi valor de missing, luego lo cambio



* Aplico encode:

foreach var of varlist econrk powrnk evalhl geo resprk satlif wtchng marsta1 marsta2 marsta3 hhpres work0 work1 work2 satecc highsc belief cmedin hprblm hosl3m operat hattac alclmo ortho  {
	encode `var', generate (`var'_enc) label (mylabel) 
	drop `var'
    rename `var'_enc `var'
}

* Seteo el valor de 50 como missing.
foreach var of varlist econrk powrnk evalhl geo resprk satlif wtchng marsta1 marsta2 marsta3 hhpres work0 work1 work2 satecc highsc belief cmedin hprblm hosl3m operat hattac alclmo ortho {
	replace `var'=. if `var'==50
}




***---- La variable waistc está guardada como string pero es un float (un continuo), con monage pasa lo mismo. Las paso a float con destring. 
destring waistc, replace 
destring monage, replace



***--- Ahora queda trabajar con las variables hipsiz y totexpr. Debemos extraer el numero del texto (que seguira siendo un string pero despues usamos destring) .
**Para esto usamos split: 

* Spliteo hipsiz:
split hipsiz, gen (h) // Esto genera 3 variables: h1, h2 y h3. hi dice 'hip', h2 dice 'circunsference' y h3 la medida. Quiero esto ultimo.
* Elimino las primeras dos variables y a la ultima le cambio el nombre:
drop h1
drop h2
drop hipsiz 
rename h3 hipsiz 

* Spliteo totexpr
split totexpr, gen (h)
drop h1
drop h2
drop totexpr 
rename h3 totexpr 


* QUEDA CONVERTIR LOS "," EN MISSING Y DESPUES PASAR A FLOAT CON destring.REPETIR PARA 'totexpr'. TAMBIEN HAY QUE HACER ESTO CON LA VARIABLE 'tincm_r'

***--- Pasamos "," a "." en hip_size, tot_expr y tincm_r 

replace hipsiz = subinstr(hipsiz, ",", ".", .)
replace totexpr = subinstr(totexpr, ",", ".", .)
replace tincm_r = subinstr(tincm_r, ",", ".", .)

***--- Pasamos hip_size, tot_expr y tincm_r a float
destring hipsiz, replace force
destring totexpr, replace force
destring tincm_r, replace force


***---- Trabajamos ahora con las variables sex, smokes y obese. 

*Smokes y Sex no tienen missings.

// Sex
replace sex="1" if sex=="male" 
replace sex="0" if sex=="female"
label define label_sex 1 "1" 0 "0" // 1 si es male y 0 si es female
encode sex, generate (sex_enc) label (label_sex) 

drop sex
rename sex_enc sex 

// Smokes 
replace smokes="1" if smokes=="Smokes"
label define label_smokes 1 "1" 0 "0" // 1 si fuma y 0 si no 
encode smokes, generate (smokes_enc) label (label_smokes) 

drop smokes
rename smokes_enc smokes 

// Obese 
replace obese="1" if obese=="This person is obese"
replace obese="0" if obese=="This person is not obese"
label define label_obese 1 "This person is obese" 0 "This person is not obese" 50 "." //1 si es obeso, 0 si no es obeso y 50 si hay "."
encode obese, generate (obese_enc) label (label_obese) 

drop obese
rename obese_enc obese 

replace obese=. if obese==50 //transformo los 50 en missing. 


***--- INCISO 2: cuento los missings de cada variable---***

*Buscamos obtener aquellas variables que presenten mas de 5% de missing values

mdesc 

// Las variables que resultan tener mas de 5% de missing values son: Age (in months), Self-reported Height, HH Income Real, HH Expenditures Real, Obese.  

***--- INCISO 3: veo datos irregulares ---***

*Chequeamos valores particulares, en general las variables float

foreach var of varlist inwgt monage htself height waistc tincm_r hipsiz totexpr {

count if `var' < 0
}


*De lo anterior surge que tincm_r y totexpr presentan valores negativos. Ambas variables indican Ingresos y Gastos respectivamente, por lo que no tiene sentido que tengan valores negativos. Reemplazamos los valores por "."
 
replace tincm_r=. if tincm_r < 0
replace totexpr=. if totexpr < 0

** Cuento las observaciones donde los gastos sean mayores a los ingresos:
count if totexpr > tincm_r 
* Hay 1,556 observaciones donde los gastos son mayores a los ingresos 


***--- INCISO 4: ordeno los datos ---***

order id site sex 
gsort -totexpr


***--- Guardo base de datos limpia

save "$input/russian_clean", replace
use "$input/russian_clean.dta", clear

*==============================================================================*



* 2) Descriptive statistics
*==============================================================================*


*----Inciso 5: Tablas Descriptivas ----* 


*Modificamos la variable monage (edad) para que figure en años

gen age = monage/12

*Agregamos los labels
label var sex "Sexo"
label var age "Edad"
label var satlif "Satisfacción con la vida"
label var waistc "Circunferencia de la cadera"
label var totexpr "Gasto real"

*Generamos la tabla y la exportamos
estpost summarize sex age satlif waistc totexpr 
esttab using "$output/tables/Table 1.tex", cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") collabels("Mean" "SD" "Min" "Max") nomtitle nonumber replace label 

***--- INCISO 6: Distribución de hipsiz para los hombres y para las mujeres. ---***
*ssc install grstyle 

*a)

*Comparamos la distribución de hipsiz entre hombres y mujeres
twoway (kdensity hipsiz if sex==0)   ///
       (kdensity hipsiz if sex==1), ///
legend(order(1 "Mujeres" 2 "Hombres")) title("Distribución de la circunsferencia de la cadera") ///
ytitle("Densidad") xtitle("Circunferencia de la cadera")
graph export "$output/figures/hipsiz_histogram_menvswomen.png", replace

*b) realizamos un test de medias entre sex y hpsiz y exportamos los resultados

ttest hipsiz, by (sex)
*Generamos los labels
label var hipsiz "Circ. de cadera"

estpost ttest hipsiz, by (sex)
esttab using "$output/tables/Table 2.tex", cells("mu_1(fmt(2)) mu_2(fmt(2)) b(fmt(2)) se(fmt(2)) p(fmt(2))") collabels("Media Mujeres" "Media Hombres" "Promedio de diferencias" "SD" "p-value") nomtitle nonumber replace label

*------------------------------------------------------------------------------*
*==============================================================================*



* 4) Regressions
*==============================================================================*


***--- INCISO 7: Regresando la felicidad de las personas ---***  


*** Gráficos Introductorios:

**Prior 1: las personas con salud son mas felices: 
graph box satlif, over(hosl3m, relabel(1 "Sano" 2 "Hosp. Últ. 3 Meses")) ytitle("Satisfacción con la vida") nooutsides title("") note("") 
graph export "$output/figures/satlif_salud.png", replace


**Prior 2: las personas sin salud son menos felices, pero seran mas felices si tienen pareja. Vamos a ver si esta hipotesis se cumple!!

** Generamos la interaccion:

gen interac=. 


replace interac = 0 if hosl3m == 0 & marsta1 == 0 // sanos solos
replace interac = 1 if hosl3m == 0 & marsta1 == 1 // sanos en pareja
replace interac = 2 if hosl3m == 1 & marsta1 == 1 // hospitalizados en pareja
replace interac = 3 if hosl3m == 1 & marsta1 == 0 // hospitalizados solos



*Grafico 2:
graph box satlif, over(interac, relabel(1 "SS" 2 "SP" 3 "HP" 4 "HS")) nooutsides  note("") ytitle("Satisfacción con la vida")
graph export "$output/figures/pareja_salud2.png", replace 


*------ Hacemos las regresiones: 

*1: satisfaccion contra salud:
reg satlif  hosl3m
outreg2 using "$output/tables/Table 3.tex", replace label tex(fragment)

*2: satisfaccion contra salud y pareja:
reg satlif  i.marsta1##i.hosl3m
outreg2 using "$output/tables/Table 3.tex", append label tex(fragment)





















