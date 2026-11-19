#!/bin/sh
# sh run.sh: ni parsere læser referat.pdf med deres standardindstillinger, hver parsers tekst kommer i parser-output/,
# Haiku får posterens ni spørgsmål om hver tekst, og det hele skrives i README.md. Kræver uv og Claude Code.
set -ef
cd "$(dirname "$0")"
command -v claude >/dev/null || { echo "run.sh kræver Claude Code (claude)."; exit 1; }
mkdir -p parser-output
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export TMPDIR="$tmp"

# parse FIL PAKKER KODE: KODE er Python, der læser referat.pdf og skriver parser-output/FIL. Første kørsel henter pakker
# og modeller. Anden kørsel er låst til én CPU-kerne, og dens tid fra import til færdig tekst kommer i README.
parse() {
  echo "${1%.*} ..."
  with=""; for p in $2; do with="$with --with $p"; done
  uv run -q --no-project $with python -B -c "$3" >"$tmp/log" 2>&1 || { tail -5 "$tmp/log"; exit 1; }
  taskset -c 0 uv run -q --no-project $with python -B -c "import time; t = time.perf_counter()
$3
s = time.perf_counter() - t
from importlib.metadata import version
s = '< 0,1' if s < 0.1 else ('%.1f' % s).replace('.', ',')
open('$tmp/tid.$1', 'w').write('%s %s\n' % (version('$(echo "$2" | sed 's/[^a-z0-9-].*//')'), s))" >"$tmp/log" 2>&1 ||
    { tail -5 "$tmp/log"; exit 1; }
}

# Docling, PyMuPDF4LLM og LiteParse i de versioner, posteren brugte. easyocr ved siden af Docling, ellers kører Docling
# 2.132.0 uden OCR. LiteParse er bedt om markdown, som på posteren.
parse docling.md "docling==2.132.0 easyocr" '
from docling.document_converter import DocumentConverter
doc = DocumentConverter().convert("referat.pdf", raises_on_error=False).document
open("parser-output/docling.md", "w", encoding="utf-8").write(doc.export_to_markdown(page_no=1).strip("\n") + "\n")'

parse pymupdf4llm.md "pymupdf4llm==1.28.2" '
import pymupdf4llm
text = pymupdf4llm.to_markdown("referat.pdf", page_chunks=True)[0]["text"]
open("parser-output/pymupdf4llm.md", "w", encoding="utf-8").write(text.strip("\n") + "\n")'

parse liteparse.md "liteparse==2.15.1" '
from liteparse import LiteParse
text = LiteParse(output_format="markdown").parse("referat.pdf").pages[0].markdown or ""
open("parser-output/liteparse.md", "w", encoding="utf-8").write(text.strip("\n") + "\n")'

parse pypdfium2.txt "pypdfium2==5.15.2" '
import pypdfium2
text = pypdfium2.PdfDocument("referat.pdf")[0].get_textpage().get_text_range()
open("parser-output/pypdfium2.txt", "w", encoding="utf-8").write(text.replace("\r\n", "\n"))'

# digpdf altid i nyeste version.
parse digpdf.html "digpdf" '
import digpdf
open("parser-output/digpdf.html", "w", encoding="utf-8").write(digpdf.html("referat.pdf"))'

# xberg gemmer sine resultater i en cache. Den får en tom cache hver gang, så tiden ikke kommer fra cachen.
parse xberg.txt "xberg==1.3.9" '
import os, tempfile; os.environ["XDG_CACHE_HOME"] = tempfile.mkdtemp()
import asyncio
from xberg import ExtractInput, extract
out = asyncio.run(extract(ExtractInput(kind="uri", uri="referat.pdf")))
open("parser-output/xberg.txt", "w", encoding="utf-8").write(out.results[0].content)'

parse markitdown.md "markitdown[pdf]==0.1.9" '
from markitdown import MarkItDown
open("parser-output/markitdown.md", "w", encoding="utf-8").write(MarkItDown().convert("referat.pdf").text_content)'

parse marker.md "marker-pdf==2.2.0" '
from marker.converters.pdf import PdfConverter
from marker.models import create_model_dict
from marker.output import text_from_rendered
text = text_from_rendered(PdfConverter(artifact_dict=create_model_dict())("referat.pdf"))[0]
open("parser-output/marker.md", "w", encoding="utf-8").write(text)'

parse mineru.md "mineru==4.2.3" '
import shutil, subprocess, tempfile
out = tempfile.mkdtemp()
subprocess.run(["mineru-kit", "parse", "referat.pdf", "-o", out], check=True)
shutil.copy(out + "/referat.md", "parser-output/mineru.md")'

# Haiku som på posteren: uden værktøjer, i en tom mappe, ét spørgsmål pr. kørsel, her én kørsel pr. spørgsmål og tekst.
mkdir "$tmp/tom"
ask() {  # NR SPØRGSMÅL FIL
  prompt="Herunder står teksten fra et PDF-dokument. Undersøg ikke noget, og brug ingen værktøjer. Svar med det samme og kun ud fra teksten. Kan spørgsmålet ikke besvares ud fra teksten, så skriv »kan ikke afgøres«.

Svar med ét kort svar: $2

--- TEKST ---
$(cat "parser-output/$3")
--- SLUT ---"
  (cd "$tmp/tom" && claude -p "$prompt" --model haiku --tools "" --safe-mode --strict-mcp-config < /dev/null) |
    tr '\n' ' ' | sed 's/|/\\|/g; s/ *$//' > "$tmp/svar.$1.$3"
}
filer="docling.md pymupdf4llm.md liteparse.md pypdfium2.txt digpdf.html xberg.txt markitdown.md marker.md mineru.md"
cat > "$tmp/q" <<'EOF'
Hvor mange personer deltog i mødet?|4
Hvem deltog? Skriv hvert navn for sig, adskilt af semikolon.|Anne Kjær Steen; Bjørn Thomsen; Patrick Enggaard; Marie Holm Lykke Jensen
Hvem tog referat?|Anne (Anne Kjær Steen)
Hvad tid blev mødet holdt?|Kl. 13-15
I hvilket lokale blev mødet holdt?|Mødelokale 2.08
Hvornår og hvor er næste møde?|Den 15. december 2026 kl. 13. Stedet står der ikke.
Hvor mange skoler omfatter projektet?|14
Hvilket år er det første med en bevilling til Trygge Skoleveje, fase 2 i tabel 1?|2027
Hvilken konference er dokumentet lavet til?|Sprogteknologisk Konference 2026
EOF
echo "Haiku ..."
n=0
while IFS='|' read -r q facit; do
  n=$((n + 1))
  for f in $filer; do ask $n "$q" $f & done; wait
done < "$tmp/q"

# README.md
{
  cat <<'EOF'
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
EOF
  printf 'Tiden er sekunder fra import til færdig tekst på én CPU-kerne (`taskset -c 0`) af en%s, med pakker og\nmodeller hentet på forhånd.\n' \
    "$(grep -m1 'model name' /proc/cpuinfo | sed 's/.*://')"
  echo
  echo "| Parser | Version | Sekunder |"
  echo "|---|---|---:|"
  for f in $filer; do
    read -r v s < "$tmp/tid.$f"
    printf '| [%s](parser-output/%s) | %s | %s |\n' "${f%.*}" "$f" "$v" "$s"
  done
  echo
  echo "## Haikus svar"
  echo
  echo "Haiku får hver parsers tekst og ét spørgsmål ad gangen og svarer én gang. Posterens tal er 25 svar pr. spørgsmål og tekst."
  n=0
  while IFS='|' read -r q facit; do
    n=$((n + 1))
    printf '\n### %s. %s\n\nFacit: %s\n\n| Parser | Svar |\n|---|---|\n' "$n" "$q" "$facit"
    for f in $filer; do printf '| %s | %s |\n' "${f%.*}" "$(cat "$tmp/svar.$n.$f")"; done
  done < "$tmp/q"
} > README.md
echo "README.md er skrevet."
