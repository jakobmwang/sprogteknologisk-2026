# Uskyldigt informationstab? Stille fejl i PDF-parsere, der larmer downstream

Poster til Sprogteknologisk Konference 2026, 20. november, KU. Jakob Mørup Wang og Rasmus Evers Thrane, Aarhus Kommune.

- `poster.pdf` er posteren.
- `referat.pdf` er testdokumentet, et opdigtet mødereferat.
- `run.sh` kører testen.

```sh
sh run.sh
```

`run.sh` læser `referat.pdf` med Docling, PyMuPDF4LLM og LiteParse i de versioner, posteren brugte, og til
sammenligning med pypdfium2 og digpdf. Hver parsers tekst kommer i `out/`. Er [Claude Code](https://claude.com/claude-code)
installeret, stiller scriptet bagefter Haiku posterens ni spørgsmål om hver tekst og skriver svarene i `out/svar.txt`.

Det kræver [uv](https://docs.astral.sh/uv/). Første kørsel henter Doclings modeller.
