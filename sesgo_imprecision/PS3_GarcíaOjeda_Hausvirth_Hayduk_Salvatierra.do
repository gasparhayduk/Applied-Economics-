/*******************************************************************************
                   Semana 4: Fuentes de sesgo e imprecisión 
                          Universidad de San Andrés
                              Economía Aplicada
*******************************************************************************/

/*******************************************************************************
Este archivo sigue la siguiente estructura:

0) Set up environment

1) Ejercicio 1

2) Ejercicio 2
*******************************************************************************/

* 0) Set up environment
*==============================================================================*

global main "/Users/gasparhayduk/Desktop/Economía Aplicada/PS3"
global input "$main/input"
global output "$main/output"

cd "$main"

* Ejercicio 1

* Realizamos una simulación similar a la realizada en la tutorial
* Vamos a generar un modelo que relaciona la belleza de las personas con la altura y un indice de alegria.

*generamos 100 observaciones
clear
set obs 100
set seed 1233

*Generamos el primer regresor: la altura. Le asignamos una distribución normal con media en 160cm y desvío estandar de 20cm.
gen altura = int(rnormal(160,20))

*Generamos la variable de peso y vamos a suponer que existe una relación positiva cercana a 1 entre la altura y el peso de las personas, de manera tal que cada individuo pesa en kilos aproximadamente la mitad de su altura menos un valor aleatorio que tiene distribución normal con media 10 y desvío estandar 5.
gen peso = int(altura/2 - rnormal(10,5))

*chequeamos la correlacion que existe entre la altura y el peso. Resulta ser 0.9
corr peso altura

*Generamos la variable "alegria" que es ortogonal con la altura y el peso, es decir, la alegria esta presente en los gorditos, flaquitos, altos y enanos.
gen alegria = int(rnormal(10,3))

*Chequeamos la correlación entre los tres regresores. Efectivamente correlaciona muy poco con el resto de regresores
corr peso altura alegria

*Generamos el termino de error
gen u = int(rnormal(0,1))

*Definimos el verdadero modelo. Como somos fieles creyentes que en la vida no todo entra por los ojos, y basandonos en la frase de la canción de Riki Maravilla "De nada sirve la pinta cuando no tienes el fuego", es que la alegría tiene mayor ponderación en explicar la belleza. Además, en nuestro mundo ideal nadie tiene en cuenta el peso de la persona para determinar su belleza, por lo que esta es irrelevante. 
gen belleza =  10*alegria + 2*altura + u


*** Consigna a) ¿Que sucede con los errores estandar de los regresores si aumenta el tamaño muestral? ***

*Generamos la regresión con los regresores correctos
reg belleza alegria altura 

*Guardamos la salida
predict y_hat
est store ols1

*Aumentamos el tamaño de la muestra
preserve
set obs 1000
replace altura = int(rnormal(160,20)) in 101/1000
replace alegria = int(rnormal(10,3)) in 101/1000
replace u = int(rnormal(0,1)) in 101/1000
replace belleza = 10*alegria + 2*altura + u in 101/1000
*Generamos la regresión con muestra mayor
reg belleza alegria altura
predict y_hat2
est store ols2
*Exportamos tablas
esttab ols1 ols2 using "$output/tables/Table 1.tex", replace label se ///
stats(N r2, fmt(0 3) labels("Number of observations" "R-Squared")) 
restore


*** Consigna b) ¿Que sucede con los errores estandar de los regresores si aumenta la varianza del termino de error? ***
preserve
replace u = int(rnormal(0,10))
replace belleza =  10*alegria + 2*altura + u

*Generamos la regresión con mayor varianza del termino de error
reg belleza alegria altura
predict y_hat2
est store ols2

*Exportamos tablas
esttab ols1 ols2 using "$output/tables/Table 2.tex", replace label se ///
stats(N r2, fmt(0 3) labels("Number of observations" "R-Squared")) 
restore

*** Consigna c) ¿Que sucede con los errores estandar de un regresor si aumenta la varianza de X?
preserve
replace alegria = int(rnormal(10,15))
replace belleza = 10*alegria + 2*altura + u
 
*Generamos regresión con mayor varianza de X=alegria
reg belleza alegria altura
predict y_hat2
est store ols2

*Exportamos tablas
esttab ols1 ols2 using "$output/tables/Table 3.tex", replace label se ///
stats(N r2, fmt(0 3) labels("Number of observations" "R-Squared")) 
restore

*** Consigna d) ¿Cuanto vale la suma de residuos?
*DE ESTA CONSIGNA NO ENTIENDO SI PIDE QUE COMPAREMOS LA SUMA DE RESIDUOS ENTRE MODELOS O SOLAMENTE LE DEMOS EL NUMERO DE LA SUMA DE RESIDUOS DE UN MODELO

*Primero obtengo la suma de residuos del modelo original
reg belleza alegria altura
predict residuos, residuals
egen suma_residuos = total(residuos)

di "La suma de residuos es: " suma_residuos 

*Practicamente dan cero

**** Consigna e) ¿Son los residuos ortogonales a los regresores?

*Para ver si son ortogonales se puede observar la relación entre los mismos. Tomamos los residuos de la regresión llevada a cabo en el anterior inciso

estpost corr residuos alegria altura  
eststo correlation
esttab using "$output/tables/Tabla 4.tex", replace

**** Consigna f) ¿Como afecta la alta multicolinealidad a la estimación de Y?

*Hacemos la regresión incluyendo peso que tiene una relación fuerte con altura y guardamos la prediccion

reg belleza alegria altura peso 
predict y_hat_mult

*estpost list belleza y_hat y_hat_mult in 1/5    
*esttab using "$output/tables/Tabla 5.tex", replace


*armarmos una lista con la variable original, la prediccion del modelo sin multicolinealidad y la prediccion del modelo con multicolinealidad
list belleza y_hat y_hat_mult in 1/5

*No se bien como exportar una tabla decente para este caso, asi que la arme manual REVISAR!!!!!!!


**** Consigna g) ¿Que sucede si corren una regresion con un error no aleatorio en X?¿Y si ese error fuera aleatorio?

*Comenzamos generando un error no aleatorio en alegria 
gen alegria1 = alegria + 5
*Regresamos belleza con sus regresores y reemplazamos alegria por alegria1
reg belleza alegria1 altura 
predict y_hat_noaleat
est store ols3


*Generamos un error aleatorio en alegria
gen error = int(rnormal(0,10))
gen alegria2 = alegria + error
*Regresamos belleza con sus regresores y reemplazamos alegria por alegria2
reg belleza alegria2 altura
predict y_hat_aleat
est store ols4

*Exportamos las salidas de las regresiones 
esttab ols1 ols3 ols4 using "$output/tables/Table 6.tex", replace label se ///
stats(N r2, fmt(0 3) labels("Number of observations" "R-Squared")) 

**** Consigna h) ¿Que sucede si corren una regresión con un error no aleatorio en Y?¿Y si ese error fuera aleatorio?

*Comenzamos generando un error no aleatorio en belleza 
gen belleza1 = belleza + 5
*Regresamos belleza con sus regresores y reemplazamos alegria por alegria1
reg belleza1 alegria altura 
predict y_hat_noaleat1
est store ols5


*Generamos un error aleatorio en belleza, utilizamos la misma variable aleatoria que en el inciso anterior
gen belleza2 = belleza + error
*Regresamos belleza con sus regresores y reemplazamos alegria por alegria2
reg belleza2 alegria altura
predict y_hat_aleat1
est store ols6

*Exportamos las salidas de las regresiones 
esttab ols1 ols5 ols6 using "$output/tables/Table 7.tex", replace label se ///
stats(N r2, fmt(0 3) labels("Number of observations" "R-Squared")) 
