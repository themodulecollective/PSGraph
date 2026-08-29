# Changelog

All notable changes to PSGraph are documented here. This file starts at
3.0.0 — everything below is relative to the last upstream release
(2.1.38, August 2019), the point at which `themodulecollective/PSGraph`
forked from the then-dormant `KevinMarquette/PSGraph`.

## 3.1.0 - 2026-08-29

### Added

- `Record -TableAttributes` controls the outer `<TABLE>` element (e.g.
  `CELLBORDER`), letting callers hide borders between every row in one
  call instead of repeating `Row -Attributes` on each one. (#81)
- `Row -Separator` emits a dedicated thin divider row. (#81)
- `Cells`: converts pipeline objects into HTML table rows for use inside
  a `Record`. Ported from upstream PR #105, fixing a property-name typo
  (`PortPoroperty` -> `PortProperty`) and switching to this module's
  existing uppercase `<TR>`/`<TD>` convention.
- `Export-PSGraph` gained format-specific aliases (`pngGraph`,
  `svgGraph`, `dotGraph`, etc., one per `-OutputFormat` value) that infer
  the output format from the alias name unless `-OutputFormat` is passed
  explicitly. Ported from upstream PR #105, using this module's existing
  static `[Alias(...)]` pattern instead of the original's runtime
  `New-Alias -Scope Global` loop (which also collided with `Graph`'s
  existing `DiGraph` alias).
- Windows PowerShell 5.1 support is restored. `PSGraph.psd1`'s
  `PowerShellVersion` is back to `5.1` and `CompatiblePSEditions` now
  lists both `Desktop` and `Core`. The module's only edition-sensitive
  line, `Install-GraphViz`'s OS check, now guards its `$IsMacOS`
  reference instead of relying on undefined-variable-as-falsy.

### Fixed

- `Format-Value`'s HTML-like-label detection only recognized labels
  starting with `<table`; any other valid GraphViz HTML-like label
  (`<b>...`, `<font>...`) fell through to the default branch and was
  corrupted by quote-escaping. (#100)

## 3.0.0 - 2026-08-29

### Added

- `Export-PSGraph -PassThru` returns rendered graph output (e.g. SVG)
  directly through the pipeline instead of writing it to a file — useful
  for notebook workflows (Jupyter / .NET Interactive).
- `Rank -RankType` (`same` / `min` / `source` / `max` / `sink`) for
  GraphViz rank constraints beyond the default `same`. (#101)
- `Row -Attributes` for row-level HTML attributes, e.g. hiding a row's
  border. (#64)
- `Install-GraphViz -Scope CurrentUser` for installing GraphViz without
  admin rights, with an automatic fallback to the nuget.org GraphViz
  package when the Chocolatey provider can't be registered. (#75, #88,
  #85, upstream PR #112)
- `New-NodeAttributeSet` / `New-EdgeAttributeSet` (aliases
  `NodeAttributes` / `EdgeAttributes`): build case-correct GraphViz
  attribute hashtables from PowerShell parameters, with tab completion
  for shape/color/font/arrow values. Ported from upstream PR #105, fixing
  bugs in the original (`.ToLower()` called on non-string parameters, a
  malformed array entry that silently dropped `-Distortion`).

### Fixed

- `Export-PSGraph -ShowGraph` failed on destination paths containing
  spaces on PowerShell 7 (`Invoke-Expression` replaced with
  `Invoke-Item`). (#110, upstream PR #102)
- Generated DOT output could carry a byte-order mark or mis-encode
  non-ASCII labels, which broke `dot`'s parser in some environments
  (e.g. Azure Pipelines); output encoding is now pinned to UTF-8 without
  BOM. (#97, #104)
- `dot`/GraphViz auto-detection now uses a cross-platform `Get-Command`
  PATH lookup instead of a hardcoded, Windows-only path glob; an
  explicit `-GraphVizPath` still takes precedence. (#75, #88, #85)
- `Graph`'s `compound` attribute defaulted to `true` even when the
  caller explicitly passed `compound=$false`, silently overriding it.
  (#98)
- `Format-Value`'s record-port regex silently dropped GUID-style port
  names instead of quoting them. (#65)
- The documented `SubGraph` example didn't actually bind the way the
  docs described; fixed the example to match how PowerShell resolves an
  unnamed subgraph with `-Attributes`. (#66)
- `$IsOSX`, used internally, isn't a real PowerShell automatic variable;
  corrected to `$IsMacOS`.
- The dev-mode module loader (`PSGraph.psm1`) exported functions only,
  silently dropping every module alias — including `digraph`. Aliases
  (`digraph`, `NodeAttributes`, `EdgeAttributes`) now resolve correctly
  after `Import-Module` in dev mode, matching the manifest.

### Changed

- Tests migrated from legacy Pester 3/4 (`Should Be`) to Pester 5
  (`Should -Be`); Pester is pinned to 5.7.1 in the build to avoid
  ambiguous `Invoke-Pester` resolution when multiple major versions are
  installed side by side.
- CI migrated from AppVeyor/Azure Pipelines to GitHub Actions, running
  the full test suite across a Windows/Linux/macOS × `pwsh` matrix
  (previously untested on Linux/macOS in CI).
- `psake.ps1` (a legacy, unused parallel build script) and the AppVeyor/
  Azure Pipelines configs it served were removed; `module.build.ps1`
  (InvokeBuild) is the sole build pipeline.
- Gallery metadata (`ProjectUri`, `LicenseUri`) now points at
  `themodulecollective/PSGraph`, the actively maintained fork.

### Known limitations (unchanged, documented)

- The bare `Node` command name can collide with Node.js tooling on some
  systems (upstream issues #109, #59). This is a long-standing, actively
  debated upstream design question with no consensus; it is intentionally
  left unresolved in this release rather than addressed as an incidental
  breaking change. Any rename or alias will ship as its own deliberate
  major-version change.
