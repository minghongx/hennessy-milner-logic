To generate the project report:
```shell
typst compile report.typ
```

HLS is [not yet](https://haskell-language-server.readthedocs.io/en/2.13.0.0/troubleshooting.html#preprocessors) able to find project pre-processors. Install `unlit` globally with Stack as a workaround.
```shell
stack install unlit
```
