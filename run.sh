#!/bin/sh
# sh run.sh: fem parsere læser referat.pdf med standardindstillinger og skriver hver sin tekst i out/. Er Claude Code
# installeret, stiller scriptet bagefter Haiku posterens ni spørgsmål om hver tekst, ét spørgsmål pr. kørsel, og skriver
# svarene i out/svar.txt. Kræver uv (https://docs.astral.sh/uv/).
set -e
cd "$(dirname "$0")"
mkdir -p out

echo "Docling ..."   # easyocr ved siden af, ellers kører Docling 2.132.0 uden OCR
uv run -q --no-project --with docling==2.132.0 --with easyocr python -B -c '
from docling.document_converter import DocumentConverter
doc = DocumentConverter().convert("referat.pdf", raises_on_error=False).document
open("out/docling.md", "w", encoding="utf-8").write(doc.export_to_markdown(page_no=1).strip("\n") + "\n")' 2>/dev/null

echo "PyMuPDF4LLM ..."
uv run -q --no-project --with pymupdf4llm==1.28.2 python -B -c '
import pymupdf4llm
open("out/pymupdf4llm.md", "w", encoding="utf-8").write(pymupdf4llm.to_markdown("referat.pdf", page_chunks=True)[0]["text"].strip("\n") + "\n")' 2>/dev/null

echo "LiteParse ..."
uv run -q --no-project --with liteparse==2.15.1 python -B -c '
from liteparse import LiteParse
open("out/liteparse.md", "w", encoding="utf-8").write((LiteParse(output_format="markdown").parse("referat.pdf").pages[0].markdown or "").strip("\n") + "\n")' 2>/dev/null

echo "pypdfium2 ..."
uv run -q --no-project --with pypdfium2==5.15.2 python -B -c '
import pypdfium2
open("out/pypdfium2.txt", "w", encoding="utf-8").write(pypdfium2.PdfDocument("referat.pdf")[0].get_textpage().get_text_range().replace("\r\n", "\n"))'

echo "digpdf ..."   # altid den nyeste version
uvx -q digpdf@latest referat.pdf > out/digpdf.html

command -v claude >/dev/null || { echo "Teksterne står i out/. Claude Code er ikke installeret, så Haiku bliver ikke spurgt."; exit 0; }

# Haiku som på posteren: uden værktøjer, i en tom mappe, ét spørgsmål pr. kørsel. Posterens tal er 25 kørsler pr.
# spørgsmål og tekst; her er det én.
tom=$(mktemp -d); svar=$(mktemp -d); trap 'rm -rf "$tom" "$svar"' EXIT
ask() {
  prompt="Herunder står teksten fra et PDF-dokument. Undersøg ikke noget, og brug ingen værktøjer. Svar med det samme og kun ud fra teksten. Kan spørgsmålet ikke besvares ud fra teksten, så skriv »kan ikke afgøres«.

Svar med ét kort svar: $1

--- TEKST ---
$(cat "out/$2")
--- SLUT ---"
  (cd "$tom" && claude -p "$prompt" --model haiku --tools "" --safe-mode --strict-mcp-config < /dev/null) | tr '\n' ' '
}
tekster="docling.md pymupdf4llm.md liteparse.md pypdfium2.txt digpdf.html"
n=0
while IFS= read -r q; do
  n=$((n + 1)); echo; echo "$n. $q"
  for t in $tekster; do ask "$q" "$t" > "$svar/$t" & done; wait
  for t in $tekster; do printf '   %-12s %s\n' "${t%.*}" "$(cat "$svar/$t")"; done
done <<'EOF' | tee out/svar.txt
Hvor mange personer deltog i mødet?
Hvem deltog? Skriv hvert navn for sig, adskilt af semikolon.
Hvem tog referat?
Hvad tid blev mødet holdt?
I hvilket lokale blev mødet holdt?
Hvornår og hvor er næste møde?
Hvor mange skoler omfatter projektet?
Hvilket år er det første med en bevilling til Trygge Skoleveje, fase 2 i tabel 1?
Hvilken konference er dokumentet lavet til?
EOF
