This project is written in Typst-flavored literate Haskell; a literate pre-processor must be compiled before the literate code can be built:
```shell
ghc unlit.hs -O2 -o unlit
```

To generate the project report:
```shell
typst compile report.typ
```
