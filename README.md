# Práctica I - De los píxeles a la integral: Área bajo la curva

Clase ST0244 - Lenguajes de Programación
Universidad: Universidad EAFIT
Profesor: Alexander Narváez Berrío

## Integrantes del equipo

* Sebastian Cardenas Cadavid
* Derek Chica Velasquez


---

## Objetivo

El mismo problema matemático se implementa utilizando dos paradigmas de programación:

1. Programación funcional con Haskell
2. Programación lógica con Prolog

La entrada es una imagen binaria en formato PBM P4. Cada columna se interpreta como el valor de una función discreta:

```text
f(x) = número de píxeles negros consecutivos desde la parte inferior de la columna x
```

La estructura completa de alturas es:

```text
M = [f(0), f(1), ..., f(width - 1)]
```

Como:

```text
Δx = 1 píxel
```

la suma de Riemann se convierte en:

```text
Área = Σ f(x) = sum(M)
```

---

# Archivo de entrada

El proyecto lee directamente el archivo:

```text
curva_binaria_P4.pbm
```

La imagen proporcionada tiene dimensiones:

```text
567 × 319 píxeles
```

Como PBM P4 es un formato binario, cada byte contiene hasta ocho píxeles. Los programas determinan el valor de un píxel `(x, y)` mediante:

1. El cálculo del byte que contiene el píxel.
2. La determinación de la posición del bit.
3. La extracción de ese bit utilizando operaciones binarias.

En el formato P4:

```text
1 = negro
0 = blanco
```

El número de bytes por fila se calcula como:

```text
bytesPerRow = ceil(width / 8)
```

Para esta imagen:

```text
bytesPerRow = 71
```

---

# Resultado final

Ambas implementaciones deben obtener:

```text
Área = 108660 píxeles cuadrados
```

Este valor se obtuvo construyendo la lista completa de alturas `M` y calculando:

```text
Área = sum(M)
```

---

# Estructura del repositorio

```text
Practica-I-From-Pixels-to-Integral/
│
├── README.md
├── curva_binaria_P4.pbm
│
├── Haskell/
│   └── Main.hs
│
└── Prolog/
    └── main.pl
```

---

# Solución en Haskell

## Enfoque funcional

La transformación principal es:

```haskell
heights img = map (f img) [0 .. width img - 1]
```

Esto crea:

```text
dominio → alturas
```

Después:

```haskell
area = sum m
```

crea:

```text
alturas → área
```

Por lo tanto, la transformación funcional completa es:

```text
PBM → bytes → píxeles → f(x) → M → área
```

## Requisitos

Entorno recomendado:

* GHC
* GHCi o runghc

El programa utiliza librerías estándar de Haskell, incluyendo `Data.ByteString` y `Data.Bits`.

## Ejecución

Desde la carpeta principal del proyecto:

```bash
runghc Haskell/Main.hs curva_binaria_P4.pbm
```

O:

```bash
cd Haskell
runghc Main.hs ../curva_binaria_P4.pbm
```

---

# Solución en Prolog

## Enfoque declarativo

La relación principal es:

```text
f(X, Width, Height, BytesPerRow, Data, Altura)
```

Esta describe la relación entre:

* una posición horizontal `X`
* la imagen binaria
* la altura de la columna `Altura`

La lista de alturas se construye de manera declarativa utilizando:

```prolog
findall(
    Altura,
    (
        between(0, MaxX, X),
        f(X, Width, Height, BytesPerRow, Data, Altura)
    ),
    M
).
```

Después, el área se obtiene con:

```prolog
sum_list(M, Area).
```

Por lo tanto:

```text
relaciones → valores que cumplen f(x) → M → área
```

## Requisitos

Entorno recomendado:

* SWI-Prolog

## Ejecución

Desde la carpeta principal del proyecto:

```bash
swipl -q -s Prolog/main.pl -g "main('curva_binaria_P4.pbm')" -t halt
```

O de manera interactiva:

```bash
swipl
```

Luego:

```prolog
?- ['Prolog/main.pl'].
?- main('curva_binaria_P4.pbm').
```

---

# Estrategia de visualización en consola

La imagen original es más grande que una ventana de terminal típica.

Por esta razón, ambos programas utilizan compresión espacial.

## Visualización de la imagen original

La imagen se divide en bloques.

Para cada bloque:

```text
si al menos un píxel es negro → se imprime █
de lo contrario → se imprime un espacio
```

El tamaño máximo aproximado es:

```text
100 columnas × 35 filas
```

Los factores de reducción se calculan a partir de las dimensiones originales.

Esto permite conservar la forma general de la curva mientras se puede visualizar en la consola.

## Visualización de la función de alturas

La lista `M` se comprime horizontalmente.

Varias alturas consecutivas se agrupan y se representan mediante su valor máximo. Los valores resultantes se escalan verticalmente para ocupar aproximadamente 25 filas de la terminal.

Se utilizan caracteres de bloque Unicode:

```text
█
```

Esto permite visualizar las variaciones de `f(x)` sin necesidad de utilizar una interfaz gráfica.

---

# Valores de muestra

Ambos programas muestran al menos 10 valores distribuidos a lo largo del dominio con el siguiente formato:

```text
x = ... -> f(x) = ... píxeles
```

Las posiciones se seleccionan a lo largo del ancho de la imagen.

---

# Comparación de paradigmas

## Haskell

La implementación en Haskell enfatiza las transformaciones de datos:

```text
dominio
  ↓ map f
M
  ↓ sum
área
```

La idea principal es que la estructura de alturas se crea aplicando la misma función a cada valor del dominio.

## Prolog

La implementación en Prolog enfatiza las relaciones lógicas:

```text
X + imagen → Altura que cumple f(X)
             ↓
          findall
             ↓
             M
             ↓
          sum_list
             ↓
            Área
```

En lugar de describir una secuencia de instrucciones, los predicados describen las relaciones que deben cumplirse entre una posición, la imagen y su altura.

---

# Verificación

El archivo PBM proporcionado es leído directamente por ambas implementaciones.

El archivo no se convierte manualmente en una matriz de texto.

Ambas implementaciones:

* Analizan el encabezado PBM P4.
* Procesan los datos binarios del raster.
* Acceden a los píxeles utilizando operaciones de bits.
* Calculan los píxeles negros consecutivos desde la parte inferior.
* Construyen `M`.
* Calculan el área mediante una suma de Riemann.
* Visualizan la curva original.
* Visualizan la función de alturas.
* Muestran valores de muestra.

El resultado esperado de la verificación es:

```text
Área en Haskell = 108660 píxeles cuadrados
Área en Prolog  = 108660 píxeles cuadrados
```

---
Relacionar el cálculo final con la suma de Riemann:

```text
Área = Σ f(xᵢ)Δx
```

Como:

```text
Δx = 1
```

entonces:

```text
Área = Σ f(xᵢ)
```

lo cual es exactamente:

```text
sum(M)
```
