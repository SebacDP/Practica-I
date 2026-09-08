# Practice I - From Pixels to the Integral: Area Under a Curve

**Course:** ST0244 - Programming Languages Programming  
**University:** EAFIT University  
**Lecturer:** Alexander Narváez Berrío  

## Team members

- Replace with member 1
- Replace with member 2
- Replace with member 3
- Replace with member 4

---

## Objective

The same mathematical problem is implemented using two programming paradigms:

1. **Functional programming with Haskell**
2. **Logic programming with Prolog**

The input is a binary image in **PBM P4** format. Each column is interpreted as a discrete function value:

```text
f(x) = number of consecutive black pixels from the bottom of column x
```

The complete height structure is:

```text
M = [f(0), f(1), ..., f(width - 1)]
```

Because:

```text
Δx = 1 pixel
```

the Riemann sum becomes:

```text
Area = Σ f(x) = sum(M)
```

---

# Input file

The project reads directly:

```text
curva_binaria_P4.pbm
```

The supplied image has dimensions:

```text
567 × 319 pixels
```

Since PBM **P4** is a binary format, each byte contains up to eight pixels. The programs determine the pixel value `(x, y)` by:

1. Calculating the byte containing the pixel.
2. Determining the bit position.
3. Extracting that bit using bit operations.

For P4:

```text
1 = black
0 = white
```

The number of bytes per row is:

```text
bytesPerRow = ceil(width / 8)
```

For this image:

```text
bytesPerRow = 71
```

---

# Final result

Both implementations must obtain:

```text
Area = 108660 square pixels
```

This value was obtained by constructing the complete list of column heights `M` and calculating:

```text
Area = sum(M)
```

---

# Repository structure

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

# Haskell solution

## Functional approach

The central transformation is:

```haskell
heights img = map (f img) [0 .. width img - 1]
```

This creates:

```text
domain → heights
```

Then:

```haskell
area = sum m
```

creates:

```text
heights → area
```

Therefore, the complete functional transformation is:

```text
PBM → bytes → pixels → f(x) → M → area
```

## Requirements

Recommended environment:

- GHC
- GHCi or runghc

The program uses standard Haskell libraries including `Data.ByteString` and `Data.Bits`.

## Execution

From the project root:

```bash
runghc Haskell/Main.hs curva_binaria_P4.pbm
```

Or:

```bash
cd Haskell
runghc Main.hs ../curva_binaria_P4.pbm
```

---

# Prolog solution

## Declarative approach

The central relation is:

```text
f(X, Width, Height, BytesPerRow, Data, Altura)
```

This describes the relationship between:

- a horizontal position `X`
- the binary image
- the column height `Altura`

The list of heights is constructed declaratively using:

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

Then the area is obtained with:

```prolog
sum_list(M, Area).
```

Therefore:

```text
relations → values satisfying f(x) → M → area
```

## Requirements

Recommended environment:

- SWI-Prolog

## Execution

From the project root:

```bash
swipl -q -s Prolog/main.pl -g "main('curva_binaria_P4.pbm')" -t halt
```

Or interactively:

```bash
swipl
```

Then:

```prolog
?- ['Prolog/main.pl'].
?- main('curva_binaria_P4.pbm').
```

---

# Console visualization strategy

The original image is larger than a typical terminal window.

For that reason, both programs use spatial compression.

## Original image visualization

The image is divided into blocks.

For each block:

```text
if at least one pixel is black → print █
otherwise → print space
```

The maximum target size is approximately:

```text
100 columns × 35 rows
```

The sampling factors are calculated from the original dimensions.

This preserves the general shape of the curve while making it visible in the console.

## Height function visualization

The list `M` is compressed horizontally.

Several consecutive heights are grouped and represented by their maximum value. The resulting values are then scaled vertically to approximately 25 terminal rows.

Unicode block characters are used:

```text
█
```

This makes the variations of `f(x)` visible without requiring a graphical interface.

---

# Sample values

Both programs display at least 10 values distributed across the domain in the form:

```text
x = ... -> f(x) = ... pixels
```

The positions are selected across the width of the image.

---

# Comparison of paradigms

## Haskell

The Haskell implementation emphasizes transformations of data:

```text
domain
  ↓ map f
M
  ↓ sum
area
```

The key idea is that the height structure is created by applying the same function to every value of the domain.

## Prolog

The Prolog implementation emphasizes logical relationships:

```text
X + image → Altura satisfying f(X)
             ↓
          findall
             ↓
             M
             ↓
          sum_list
             ↓
            Area
```

Instead of describing a sequence of instructions, the predicates describe the relationships that must hold between a position, the image and its height.

---

# Verification

The supplied PBM file is read directly by both implementations.

The file is **not manually converted into a text matrix**.

Both implementations:

- Parse the PBM P4 header.
- Process binary raster data.
- Access pixels using bit operations.
- Calculate consecutive black pixels from the bottom.
- Construct `M`.
- Calculate the area with a Riemann sum.
- Visualize the source curve.
- Visualize the height function.
- Show sample values.

Expected verification result:

```text
Haskell Area = 108660 square pixels
Prolog  Area = 108660 square pixels
```

---

# Suggested video presentation

1. Show the repository and the original `curva_binaria_P4.pbm` file.
2. Explain that PBM P4 stores pixels as bits.
3. Execute the Haskell program.
4. Show the compact image visualization.
5. Show the height function visualization.
6. Show sample values.
7. Show the area: `108660`.
8. Explain `map f` and `sum`.
9. Execute the Prolog program.
10. Show the same outputs and area.
11. Explain the relation `f(...)`, `findall/3` and `sum_list/2`.
12. Compare functional and declarative programming.
13. Connect the final calculation with the Riemann sum:

```text
Area = Σ f(xᵢ)Δx
```

Since:

```text
Δx = 1
```

then:

```text
Area = Σ f(xᵢ)
```

which is exactly:

```text
sum(M)
```
