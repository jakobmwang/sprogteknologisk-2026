# Uskyldigt informationstab? Stille fejl i PDF-parsere, der larmer downstream

Poster til Sprogteknologisk Konference 2026, 20. november, KU. Jakob Mørup Wang og Rasmus Evers Thrane, Aarhus Kommune.

- `poster.pdf` er posteren.
- `referat.pdf` er testdokumentet, et opdigtet mødereferat.
- `parser-output/` er hver parsers output for `referat.pdf`.
- `run.sh` kører parserne, evaluerer, og genererer denne README.

## Parserne

Alle kører med deres standardindstillinger. LiteParse og xberg giver uformateret tekst som standard, så de er kørt en ekstra
gang, hvor de er bedt om markdown. På posteren er LiteParse bedt om markdown for at være konsistent med formatet, der anvendes af de refererede benchmarks.

## Evaluering

Hver parsers output er givet til Claude Haiku med ét spørgsmål ad gangen. Claude Sonnet evaluerer hvert svar mod facit
(LLM-as-a-judge). Spørgsmålene er:

1. Hvor mange personer deltog i mødet?
2. Hvem deltog? Skriv hvert navn for sig, adskilt af semikolon.
3. Hvem tog referat?
4. Hvad tid blev mødet holdt?
5. I hvilket lokale blev mødet holdt?
6. Hvornår og hvor er næste møde?
7. Hvor mange skoler omfatter projektet?
8. Hvilket år er det første med en bevilling til Trygge Skoleveje, fase 2 i tabel 1?
9. Hvilken konference er dokumentet lavet til?

## Resultater

Tid i sekunder er målt fra import til færdigt output på en Intel(R) Core(TM) Ultra 7 155U, med pakker og modeller hentet på
forhånd. Kolonne 1-9 er spørgsmålene: ✅ er et rigtigt svar og ❌ et forkert eller manglende svar. De bedste resultater
står med fed.

| Parser | Version | Tid | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | Rigtige |
|---|---|---:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|---:|
| [docling](parser-output/docling.md) | 2.132.0 | 34,8 s | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | 3/9 |
| [pymupdf4llm](parser-output/pymupdf4llm.md) | 1.28.2 | 1,5 s | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ | 4/9 |
| [liteparse](parser-output/liteparse.txt) | 2.15.1 | 1,2 s | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | 5/9 |
| [liteparse (markdown)](parser-output/liteparse-markdown.md) | 2.15.1 | 1,3 s | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | 4/9 |
| [pypdfium2](parser-output/pypdfium2.txt) | 5.15.2 | **< 0,1 s** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | 6/9 |
| [digpdf](parser-output/digpdf.html) | 0.2.0 | **< 0,1 s** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **9/9** |
| [xberg](parser-output/xberg.txt) | 1.3.9 | 0,2 s | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ | 7/9 |
| [xberg (markdown)](parser-output/xberg-markdown.md) | 1.3.9 | 0,2 s | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | 4/9 |
| [markitdown](parser-output/markitdown.md) | 0.1.9 | 0,7 s | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | 6/9 |
| [marker](parser-output/marker.md) | 2.2.0 | 23,8 s | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | 4/9 |
| [mineru](parser-output/mineru.md) | 4.2.3 | 20,4 s | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | 5/9 |

## Svar

Claude Haiku har svaret én gang på hvert spørgsmål. Posterens tal er 25 svar pr. spørgsmål og parser.

### 1. Hvor mange personer deltog i mødet?

Facit: 4

| Parser | Svar |
|---|---|
| docling | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm Lykke Jensen (4 personer, afbud fra Mads Kristensen). |
| pymupdf4llm | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm og Lykke Jensen, altså 5 personer (Mads Kristensen havde afbud, og Anne er også referent). |
| liteparse | Kan ikke afgøres.  Teksten nævner fire navne under "Deltagere" og ét under "Afbud", men den angiver ikke et samlet antal personer, der deltog i mødet. |
| liteparse (markdown) | Kan ikke afgøres. |
| pypdfium2 | Fire personer deltog i mødet: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen. Mads Kristensen var afbud. |
| digpdf | Fire personer deltog i mødet: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen. Mads Kristensen var meldt afbud. |
| xberg | 4 personer deltog i mødet. |
| xberg (markdown) | Fem personer deltog: Anne, Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen. Mads Kristensen var afbud.  Hvis du vil have det helt præcist: Der er seks navne nævnt. Anne, Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen er deltagere, mens Mads Kristensen er afbud. Det giver fem deltagere, men teksten er tvetydig om, hvor grænsen mellem navnene går. Ud fra selve teksten vil jeg derfor svare: 5. |
| markitdown | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen, altså 4 personer. Mads Kristensen var afbud. |
| marker | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm, Lykke Jensen og Mads Kristensen. Afbud fra Steen? Teksten har felterne "Deltagere" og "Afbud" sammenstillet, så det er ikke entydigt.  Kan ikke afgøres – teksten har ikke en klar adskillelse mellem deltagere og afbud, så det er uklart, hvor mange der præcist deltog. |
| mineru | Fem personer deltog i mødet: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm og Lykke Jensen. Mads Kristensen var meldt afbud. |

### 2. Hvem deltog? Skriv hvert navn for sig, adskilt af semikolon.

Facit: Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen

| Parser | Svar |
|---|---|
| docling | Anne Kjær; Steen Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| pymupdf4llm | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm; Lykke Jensen |
| liteparse | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| liteparse (markdown) | Anne; Kjær Steen Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| pypdfium2 | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| digpdf | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| xberg | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| xberg (markdown) | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| markitdown | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| marker | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm; Lykke Jensen; Mads Kristensen |
| mineru | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |

### 3. Hvem tog referat?

Facit: Anne (Anne Kjær Steen)

| Parser | Svar |
|---|---|
| docling | kan ikke afgøres |
| pymupdf4llm | Referent: Anne. |
| liteparse | Referent er Anne. |
| liteparse (markdown) | Referent: Anne. |
| pypdfium2 | Referent var Anne. |
| digpdf | Anne |
| xberg | Referent: Anne |
| xberg (markdown) | Anne |
| markitdown | Referent var Anne. |
| marker | Referent: Anne. |
| mineru | Anne |

### 4. Hvad tid blev mødet holdt?

Facit: Kl. 13-15

| Parser | Svar |
|---|---|
| docling | Kl. 13–15 (tirsdag den 3. november 2026). |
| pymupdf4llm | Kl. 13:15 (kl. 1315). |
| liteparse | Kl. 13. |
| liteparse (markdown) | kl. 13 |
| pypdfium2 | Kl. 13 (13-15), tirsdag den 3. november 2026. |
| digpdf | Tirsdag den 3. november 2026 kl. 13-15 (udsat fra tirsdag den 27. oktober). |
| xberg | kl. 13-15 |
| xberg (markdown) | Kl. 13.15 (1315). |
| markitdown | kl. 13 |
| marker | Mødet blev holdt kl. 13-15. |
| mineru | Mødet blev holdt kl. 13-15. |

### 5. I hvilket lokale blev mødet holdt?

Facit: Mødelokale 2.08

| Parser | Svar |
|---|---|
| docling | Mødelokale 2.14 2.08 |
| pymupdf4llm | Mødelokale 2.142.08 |
| liteparse | Mødet blev holdt i Mødelokale 2.08. |
| liteparse (markdown) | Mødelokale 2.08 |
| pypdfium2 | Mødelokale 2.14 |
| digpdf | 2.08 |
| xberg | Mødelokale 2.142.08 |
| xberg (markdown) | Mødelokale 2.14 |
| markitdown | Mødelokale 22.1.048 |
| marker | Mødelokale 2.14 |
| mineru | Mødelokale 2.142.08 |

### 6. Hvornår og hvor er næste møde?

Facit: Den 15. december 2026 kl. 13. Stedet står der ikke.

| Parser | Svar |
|---|---|
| docling | Tirsdag den 24. november kl. 9 ved Lindeskolen. |
| pymupdf4llm | Næste møde er 15. december 2026 kl. 13. |
| liteparse | Næste møde er den 15. december 2026 kl. 13. |
| liteparse (markdown) | Den 15. december 2026 kl. 13 (næste møde, hvor der gøres status på krydsningerne). Mødestedet er ikke angivet i teksten, så det kan ikke afgøres. |
| pypdfium2 | Næste møde er den 15. december 2026 kl. 13. |
| digpdf | Næste møde er den 15. december 2026 kl. 13. Hvor mødet holdes: kan ikke afgøres. |
| xberg | Den 15. december 2026 kl. 13. |
| xberg (markdown) | Næste møde er den 15. december 2026 kl. 13. Stedet er ikke angivet i teksten. |
| markitdown | Den 15. december 2026 kl. 13. |
| marker | Næste møde er den 15. december 2026 kl. 13, men stedet er ikke angivet i teksten: kan ikke afgøres. |
| mineru | Næste møde er den 15. december 2026 kl. 13. |

### 7. Hvor mange skoler omfatter projektet?

Facit: 14

| Parser | Svar |
|---|---|
| docling | 14 skoler (heraf to friskoler). |
| pymupdf4llm | 14 |
| liteparse | 143 skoler. |
| liteparse (markdown) | Projektet omfatter nu 143 skoler. |
| pypdfium2 | Projektet omfatter nu 143 skoler (heraf to friskoler). |
| digpdf | 14 skoler. |
| xberg | 14 skoler. |
| xberg (markdown) | 143 skoler. |
| markitdown | Projektet omfatter 143 skoler. |
| marker | 143 skoler. |
| mineru | 14 |

### 8. Hvilket år er det første med en bevilling til Trygge Skoleveje, fase 2 i tabel 1?

Facit: 2027

| Parser | Svar |
|---|---|
| docling | 2026 (300.000 kr.) |
| pymupdf4llm | 2026 |
| liteparse | Kan ikke afgøres. |
| liteparse (markdown) | 2026 |
| pypdfium2 | kan ikke afgøres |
| digpdf | 2027 |
| xberg | Kan ikke afgøres. |
| xberg (markdown) | 2027 |
| markitdown | 2027 |
| marker | 2028 |
| mineru | Kan ikke afgøres. |

### 9. Hvilken konference er dokumentet lavet til?

Facit: Sprogteknologisk Konference 2026

| Parser | Svar |
|---|---|
| docling | kan ikke afgøres |
| pymupdf4llm | Sprogteknologisk Konference 2026 |
| liteparse | Sprogteknologisk Konference 2026 |
| liteparse (markdown) | Sprogteknologisk Konference 2026 |
| pypdfium2 | Sprogteknologisk Konference 2026 |
| digpdf | Sprogteknologisk Konference 2026 |
| xberg | Sprogteknologisk Konference 2026 |
| xberg (markdown) | kan ikke afgøres |
| markitdown | Sprogteknologisk Konference 2026 |
| marker | Sprogteknologisk Konference 2026 |
| mineru | kan ikke afgøres |
