# homebrew-tap

Homebrew formulae and casks for tools published by avison9. Each is kept
current by the tool's own release workflow on every tagged release: the
cask is generated whole by goreleaser, the formula has its `url` and
`sha256` rewritten. Nothing here is edited by hand between releases.

```
brew install avison9/tap/cdclint          # formula: builds from the tagged source
brew install --cask avison9/tap/cdclint   # cask: the release binary, no Go needed
```

Homebrew resolves a name that is both a formula and a cask to the formula,
so the first command builds from source (it installs `go` as a build
dependency, then a few seconds of `go build`). The formula is the file
that goes to homebrew/core once the project clears its notability bar;
until then it lives here so it is tested by every install.

| name | what it is |
|---|---|
| [cdclint](https://github.com/avison9/cdclint) | lint the contract between your database, your Debezium connector and your sink |
