# Uskyldigt informationstab? Stille fejl i PDF-parsere, der larmer downstream

Poster til Sprogteknologisk Konference 2026, 20. november, KU. Jakob Mørup Wang og Rasmus Evers Thrane, Aarhus Kommune.

- `poster.pdf` er posteren.
- `referat.pdf` er testdokumentet, et opdigtet mødereferat.
- `parser-output/` er det, hver parser læser i `referat.pdf`.
- `run.sh` kører parserne, stiller Haiku spørgsmålene og skriver denne README: `sh run.sh`. Det kræver
  [uv](https://docs.astral.sh/uv/) og [Claude Code](https://claude.com/claude-code), og første kørsel henter modeller
  på flere GB.

## Parserne

Alle kører med deres standardindstillinger. LiteParse er bedt om markdown, som på posteren, og Docling, PyMuPDF4LLM og
LiteParse er i de versioner, posteren brugte.
Tiden er sekunder fra import til færdig tekst på én CPU-kerne (`taskset -c 0`) af en Intel(R) Core(TM) Ultra 7 155U, med pakker og
modeller hentet på forhånd.

| Parser | Version | Sekunder |
|---|---|---:|
| [docling](parser-output/docling.md) | 2.132.0 | 34,8 |
| [pymupdf4llm](parser-output/pymupdf4llm.md) | 1.28.2 | 1,5 |
| [liteparse](parser-output/liteparse.md) | 2.15.1 | 1,3 |
| [pypdfium2](parser-output/pypdfium2.txt) | 5.15.2 | < 0,1 |
| [digpdf](parser-output/digpdf.html) | 0.2.0 | < 0,1 |
| [xberg](parser-output/xberg.txt) | 1.3.9 | 0,2 |
| [markitdown](parser-output/markitdown.md) | 0.1.9 | 0,7 |
| [marker](parser-output/marker.md) | 2.2.0 | 23,8 |
| [mineru](parser-output/mineru.md) | 4.2.3 | 20,4 |

## Haikus svar

Haiku får hver parsers tekst og ét spørgsmål ad gangen og svarer én gang. Posterens tal er 25 svar pr. spørgsmål og tekst.

### 1. Hvor mange personer deltog i mødet?

Facit: 4

| Parser | Svar |
|---|---|
| docling | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm Lykke Jensen (4 personer, afbud fra Mads Kristensen). |
| pymupdf4llm | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm og Lykke Jensen, altså 5 personer (Mads Kristensen havde afbud, og Anne er også referent). |
| liteparse | Kan ikke afgøres. |
| pypdfium2 | Fire personer deltog i mødet: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen. Mads Kristensen var afbud. |
| digpdf | Fire personer deltog i mødet: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen. Mads Kristensen var meldt afbud. |
| xberg | 4 personer deltog i mødet. |
| markitdown | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard og Marie Holm Lykke Jensen, altså 4 personer. Mads Kristensen var afbud. |
| marker | Deltagere: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm, Lykke Jensen og Mads Kristensen. Afbud fra Steen? Teksten har felterne "Deltagere" og "Afbud" sammenstillet, så det er ikke entydigt.  **Kan ikke afgøres** – teksten har ikke en klar adskillelse mellem deltagere og afbud, så det er uklart, hvor mange der præcist deltog. |
| mineru | Fem personer deltog i mødet: Anne Kjær Steen, Bjørn Thomsen, Patrick Enggaard, Marie Holm og Lykke Jensen. Mads Kristensen var meldt afbud. |

### 2. Hvem deltog? Skriv hvert navn for sig, adskilt af semikolon.

Facit: Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen

| Parser | Svar |
|---|---|
| docling | Anne Kjær; Steen Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| pymupdf4llm | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm; Lykke Jensen |
| liteparse | Anne; Kjær Steen Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| pypdfium2 | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| digpdf | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| xberg | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| markitdown | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |
| marker | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm; Lykke Jensen; Mads Kristensen |
| mineru | Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen |

### 3. Hvem tog referat?

Facit: Anne (Anne Kjær Steen)

| Parser | Svar |
|---|---|
| docling | kan ikke afgøres |
| pymupdf4llm | Referent: Anne. |
| liteparse | Referent: Anne. |
| pypdfium2 | Referent var Anne. |
| digpdf | Anne |
| xberg | Referent: Anne |
| markitdown | Referent var Anne. |
| marker | Referent: Anne. |
| mineru | Anne |

### 4. Hvad tid blev mødet holdt?

Facit: Kl. 13-15

| Parser | Svar |
|---|---|
| docling | Kl. 13–15 (tirsdag den 3. november 2026). |
| pymupdf4llm | Kl. 13:15 (kl. 1315). |
| liteparse | kl. 13 |
| pypdfium2 | Kl. 13 (13-15), tirsdag den 3. november 2026. |
| digpdf | Tirsdag den 3. november 2026 kl. 13-15 (udsat fra tirsdag den 27. oktober). |
| xberg | kl. 13-15 |
| markitdown | kl. 13 |
| marker | Mødet blev holdt kl. 13-15. |
| mineru | Mødet blev holdt kl. 13-15. |

### 5. I hvilket lokale blev mødet holdt?

Facit: Mødelokale 2.08

| Parser | Svar |
|---|---|
| docling | Mødelokale 2.14 2.08 |
| pymupdf4llm | Mødelokale 2.142.08 |
| liteparse | Mødelokale 2.08 |
| pypdfium2 | Mødelokale 2.14 |
| digpdf | 2.08 |
| xberg | Mødelokale 2.142.08 |
| markitdown | Mødelokale 22.1.048 |
| marker | Mødelokale 2.14 |
| mineru | Mødelokale 2.142.08 |

### 6. Hvornår og hvor er næste møde?

Facit: Den 15. december 2026 kl. 13. Stedet står der ikke.

| Parser | Svar |
|---|---|
| docling | Tirsdag den 24. november kl. 9 ved Lindeskolen. |
| pymupdf4llm | Næste møde er 15. december 2026 kl. 13. |
| liteparse | Den 15. december 2026 kl. 13 (næste møde, hvor der gøres status på krydsningerne). Mødestedet er ikke angivet i teksten, så det kan ikke afgøres. |
| pypdfium2 | Næste møde er den 15. december 2026 kl. 13. |
| digpdf | Næste møde er den 15. december 2026 kl. 13. Hvor mødet holdes: kan ikke afgøres. |
| xberg | Den 15. december 2026 kl. 13. |
| markitdown | Den 15. december 2026 kl. 13. |
| marker | Næste møde er den 15. december 2026 kl. 13, men stedet er ikke angivet i teksten: kan ikke afgøres. |
| mineru | Næste møde er den 15. december 2026 kl. 13. |

### 7. Hvor mange skoler omfatter projektet?

Facit: 14

| Parser | Svar |
|---|---|
| docling | 14 skoler (heraf to friskoler). |
| pymupdf4llm | 14 |
| liteparse | Projektet omfatter nu 143 skoler. |
| pypdfium2 | Projektet omfatter nu 143 skoler (heraf to friskoler). |
| digpdf | 14 skoler. |
| xberg | 14 skoler. |
| markitdown | Projektet omfatter 143 skoler. |
| marker | 143 skoler. |
| mineru | 14 |

### 8. Hvilket år er det første med en bevilling til Trygge Skoleveje, fase 2 i tabel 1?

Facit: 2027

| Parser | Svar |
|---|---|
| docling | **2026** (300.000 kr.) |
| pymupdf4llm | 2026 |
| liteparse | **2026** |
| pypdfium2 | kan ikke afgøres |
| digpdf | 2027 |
| xberg | Kan ikke afgøres. |
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
| pypdfium2 | Sprogteknologisk Konference 2026 |
| digpdf | Sprogteknologisk Konference 2026 |
| xberg | Sprogteknologisk Konference 2026 |
| markitdown | Sprogteknologisk Konference 2026 |
| marker | Sprogteknologisk Konference 2026 |
| mineru | kan ikke afgøres |
