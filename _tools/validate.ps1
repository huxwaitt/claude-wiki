param([switch]$WriteCatalog, [string]$Root)
# Wiki root: -Root wins, else the folder holding this _tools\ directory. No hardcoded path.
$root = if ($Root) { (Resolve-Path $Root).Path } else { (Resolve-Path (Join-Path $PSScriptRoot '..')).Path }
$types = 'concept','decision','pattern','pitfall','checklist','procedure'
# ---- Subject vocabularies. All four start empty. ----
# Fill each one together with its counterpart in _schema.md §5/§6 and _sources.md; `_bootstrap.md`
# explains how to derive them. While a list is empty its check is SKIPPED and reported at the end, so an
# unpopulated wiki validates cleanly instead of failing every page on a vocabulary that does not exist yet.
$sources = @()        # accepted source names (_sources.md). A source is "<name> § <exact heading>".
$stages  = @()        # _schema.md §5
$topics  = @()        # _schema.md §5
$depthPattern = ''    # _schema.md §5, e.g. '^L[123](-L[123])?$'
$templates = @{
  concept   = @('What it is','How it works','Implications for the solution','Related decisions','Sources')
  decision  = @('Decide this when','Options','Decision criteria','Recommendation by scenario','Tradeoffs and consequences','Pitfalls?','Sources')
  pattern   = @('Use when','Structure','Variations?','Failure modes','Sources')
  pitfall   = @('Symptom','Root cause','Prevention or fix','The story','Sources')
  checklist = @('Checklist','Sources')
  procedure = @('Preconditions','Steps','Verification','Sources')
}
$caps = @{ concept=900; decision=900; pattern=900; procedure=900; pitfall=350; checklist=400 }
# Length rule (_schema.md §4): body word count excludes frontmatter and the `## Sources` block; a table-heavy page (≥15% of body words inside tables) may exceed its cap by 10%.
$heavyTolerance = 1.10; $heavyShare = 0.15

function Parse-FM([string[]]$lines) {
  $fm = [ordered]@{}; $key = $null; $mode = $null
  foreach ($l in $lines) {
    if ($l -match '^(\w[\w-]*):\s*(.*)$') {
      $key = $Matches[1]; $v = $Matches[2].Trim()
      if ($v -eq '>-' -or $v -eq '>' -or $v -eq '|') { $fm[$key] = ''; $mode = 'fold' }
      elseif ($v -eq '') { $fm[$key] = @(); $mode = 'list' }
      elseif ($v -match '^\[(.*)\]$') { $fm[$key] = @($Matches[1] -split ',\s*' | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ }); $mode = $null }
      else { $fm[$key] = $v.Trim('"'); $mode = $null }
    } elseif ($l -match '^\s+-\s+(.*)$' -and $key) {
      if ($fm[$key] -is [string]) { $fm[$key] = @() }
      $fm[$key] = @($fm[$key]) + $Matches[1].Trim().Trim('"').Trim("'")
    } elseif ($l -match '^\s+(\S.*)$' -and $key -and $mode -eq 'fold') {
      $fm[$key] = (($fm[$key] + ' ' + $Matches[1].Trim()).Trim())
    }
  }
  return $fm
}

# Domains: top-level `NN-slug` folders. A top-level `NN-slug` folder that holds subfolders and no page files is a CONTAINER
# (one level only, _schema.md §5): each child folder `slug` is a domain whose `domain:` field is `NN-container/slug` and whose ids are `slug.<page>`.
$domainDirs = @(); $containers = @()
foreach ($top in (Get-ChildItem $root -Directory | Where-Object Name -match '^\d\d-[\w-]+$' | Sort-Object Name)) {
  $kids = @(Get-ChildItem $top.FullName -Directory | Where-Object Name -match '^[a-z][\w-]*$' | Sort-Object Name)
  $ownPages = @(Get-ChildItem $top.FullName -File -Filter *.md | Where-Object Name -ne '_index.md')
  if ($kids.Count -gt 0 -and $ownPages.Count -eq 0) {
    $containers += [pscustomobject]@{ Dir=$top; Name=$top.Name; Children=@($kids | ForEach-Object { "$($top.Name)/$($_.Name)" }) }
    foreach ($k in $kids) { $domainDirs += [pscustomobject]@{ Dir=$k; Name="$($top.Name)/$($k.Name)"; Slug=$k.Name; NN=$top.Name.Substring(0,2); IsRef=$true } }
  } else {
    $domainDirs += [pscustomobject]@{ Dir=$top; Name=$top.Name; Slug=($top.Name -replace '^\d\d-',''); NN=$top.Name.Substring(0,2); IsRef=$false }
  }
}
$domainSlugs = @($domainDirs | ForEach-Object Slug)
$slugAlt = ($domainSlugs | ForEach-Object { [regex]::Escape($_) }) -join '|'
$pages = @()
$pageFiles = @(); foreach ($d in $domainDirs) { $pageFiles += @(Get-ChildItem $d.Dir.FullName -File -Filter *.md | Where-Object Name -ne '_index.md' | ForEach-Object { [pscustomobject]@{ File=$_; Domain=$d } }) }
foreach ($pf in $pageFiles) { $f = $pf.File
  $txt = Get-Content $f.FullName -Raw
  $lines = $txt -split "`r?`n"
  $issues = @()
  if ($lines[0] -ne '---') { $issues += 'no frontmatter'; $pages += [pscustomobject]@{file=$f.FullName; id=$null; issues=$issues}; continue }
  $end = -1
  for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^---\s*$') { $end = $i; break } }
  if ($end -lt 0) { $issues += 'unterminated frontmatter'; $pages += [pscustomobject]@{file=$f.FullName; id=$null; issues=$issues}; continue }
  $fmLines = $lines[1..($end-1)]; $body = ($lines[($end+1)..($lines.Count-1)]) -join "`n"
  $fm = Parse-FM $fmLines
  if (-not $fm.type) { $fm['type'] = '' }
  $domain = $pf.Domain.Name; $slug = $pf.Domain.Slug
  $expectId = "$slug." + ($f.BaseName)
  if ($fm.id -ne $expectId) { $issues += "id '$($fm.id)' != '$expectId'" }
  if ($fm.domain -ne $domain) { $issues += "domain '$($fm.domain)' != '$domain'" }
  if ($types -notcontains $fm.type) { $issues += "type '$($fm.type)'" }
  if ($f.BaseName -like 'pitfall-*' -and $fm.type -ne 'pitfall') { $issues += 'pitfall filename but type not pitfall' }
  foreach ($k in 'id','type','title','summary','domain','stage','topics','depth','applies_when','sources') { if (-not $fm.Contains($k) -or -not $fm[$k]) { $issues += "missing $k" } }
  $keys = @($fm.Keys); $expected = 'id','type','title','summary','domain','stage','topics','depth','applies_when','not_for','sources','related'
  $ko = @($keys | Where-Object { $expected -contains $_ }); $eo = @($expected | Where-Object { $keys -contains $_ })
  if (($ko -join ',') -ne ($eo -join ',')) { $issues += "field order: $($ko -join ',')" }
  $extra = @($keys | Where-Object { $expected -notcontains $_ }); if ($extra) { $issues += "extra fields: $($extra -join ',')" }
  if ($fm.summary) { $sw = ($fm.summary -split '\s+').Count; if ($sw -gt 40) { $issues += "summary $sw words" }; if ($fm.summary -match '^(This page|This entry|Covers|Describes|Explains)') { $issues += 'summary describes topic not answer' } }
  if ($fm.title -and ($fm.title -split '\s+').Count -gt 12) { $issues += 'title >12 words' }
  if ($stages.Count) { foreach ($s in @($fm.stage)) { if ($stages -notcontains $s) { $issues += "stage '$s'" } } }
  if (@($fm.stage).Count -gt 2) { $issues += 'stage >2' }
  if ($topics.Count) { foreach ($t in @($fm.topics)) { if ($topics -notcontains $t) { $issues += "topic '$t'" } } }
  if (@($fm.topics).Count -gt 4) { $issues += 'topics >4' }
  if ($depthPattern -and $fm.depth -notmatch $depthPattern) { $issues += "depth '$($fm.depth)'" }
  $aw = @($fm.applies_when).Count; if ($aw -lt 2 -or $aw -gt 5) { $issues += "applies_when count $aw" }
  if (@($fm.not_for).Count -gt 3) { $issues += 'not_for >3' }
  # Source form (_schema.md §3): "<source name> § <exact heading>", name from $sources; or "Maintainer/<date> § …".
  foreach ($s in @($fm.sources)) {
    if ($s -match '^Maintainer/\d{4}-\d{2}-\d{2} § .+') { continue }
    if ($s -notmatch '^(.+?) § (.+)$') { $issues += "source form: $s"; continue }
    if ($sources.Count -and $sources -notcontains $Matches[1]) { $issues += "unknown source: $($Matches[1])" }
  }
  # body
  if ($body -notmatch '(?m)^# ') { $issues += 'no H1' }
  if ($body -notmatch '\*\*Bottom line:\*\*') { $issues += 'no Bottom line' }
  $h2 = @([regex]::Matches($body, '(?m)^## (.+)$') | ForEach-Object { $_.Groups[1].Value.Trim() })
  if ($templates.ContainsKey($fm.type)) {
    $req = @($templates[$fm.type] | Where-Object { $_ -notlike '*?' }); $opt = @($templates[$fm.type] | Where-Object { $_ -like '*?' } | ForEach-Object { $_.TrimEnd('?') })
    foreach ($h in $req) { if ($h2 -notcontains $h) { $issues += "missing heading '$h'" } }
    foreach ($h in $h2) { if (($req + $opt) -notcontains $h) { $issues += "extra heading '$h'" } }
    $seq = @($h2 | Where-Object { ($req + $opt) -contains $_ }); $tmpl = @($templates[$fm.type] | ForEach-Object { $_.TrimEnd('?') } | Where-Object { $seq -contains $_ })
    if (($seq -join '|') -ne ($tmpl -join '|')) { $issues += 'heading order' }
  }
  $bodyNoSrc = [regex]::Replace($body, '(?ms)^## Sources\s*$.*?(?=^## |\z)', '')
  $words = ($bodyNoSrc -split '\s+' | Where-Object { $_ }).Count
  $tableWords = (([regex]::Matches($bodyNoSrc, '(?m)^\|.*$') | ForEach-Object { $_.Value }) -join ' ' -split '\s+' | Where-Object { $_ }).Count
  $heavy = ($words -gt 0 -and ($tableWords / $words) -ge $heavyShare)
  if ($caps.ContainsKey($fm.type)) {
    $limit = if ($heavy) { [math]::Floor($caps[$fm.type] * $heavyTolerance) } else { $caps[$fm.type] }
    if ($words -gt $limit) { $issues += "body $words words > cap $limit" + $(if ($heavy) { " (table-heavy: +10%)" } else { '' }) }
  }
  if ($words -lt 120 -and $fm.type -ne 'pitfall' -and $fm.type -ne 'checklist') { $issues += "body only $words words" }
  $bq = @([regex]::Matches($body, '(?m)^>')).Count; if ($bq -gt 2) { $issues += "$bq blockquote lines" }
  $pages += [pscustomobject]@{ file=$f.FullName; id=$fm.id; fm=$fm; words=$words; issues=$issues; domain=$domain }
}
$ids = @($pages | Where-Object id | ForEach-Object id)
foreach ($p in $pages) {
  if (-not $p.fm) { continue }
  foreach ($r in @($p.fm.related)) { if ($ids -notcontains $r) { $p.issues += "related dangling: $r" } }
  foreach ($n in @($p.fm.not_for)) { if ($n -match '→\s*`?([\w-]+\.[\w-]+)`?\s*$') { if ($ids -notcontains $Matches[1]) { $p.issues += "not_for dangling: $($Matches[1])" } } else { $p.issues += "not_for form: $n" } }
  $bodyRefs = [regex]::Matches((Get-Content $p.file -Raw), "``((?:$slugAlt)\.[\w-]+)``") | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
  foreach ($r in $bodyRefs) { if ($ids -notcontains $r -and $r -ne $p.id) { $p.issues += "body ref dangling: $r" } }
}
# ---- structural checks (wiki-level; reported separately from per-page issues) ----
$struct = @()
$idRx = "(?:$slugAlt)\.[\w-]+"
$rootIdx = Get-Content "$root\_index.md" -Raw
$playbook = Get-Content "$root\_playbook.md" -Raw
foreach ($d in $domainDirs) {
  if (-not (Test-Path "$($d.Dir.FullName)\_index.md")) { $struct += "$($d.Name): missing _index.md"; continue }
  if ($rootIdx -notmatch "``$([regex]::Escape($d.Name))``") { $struct += "_index.md domain table lacks row for $($d.Name)" }
  $dIdx = Get-Content "$($d.Dir.FullName)\_index.md" -Raw
  $dPages = @($pages | Where-Object { $_.domain -eq $d.Name -and $_.id })
  foreach ($p in $dPages) {
    if ($dIdx -notmatch "\|\s*``?$([regex]::Escape($p.id))``?\s*\|") { $struct += "$($d.Name)\_index.md: no table row for $($p.id)" }
    # _playbook.md is the PROCESS spine: every non-pitfall page of a process domain appears once; reference (container) domains are reached from the router and `related`, not listed page by page.
    if (-not $d.IsRef -and $p.fm.type -ne 'pitfall' -and $playbook -notmatch "``$([regex]::Escape($p.id))``") { $struct += "_playbook.md: missing $($p.id)" }
  }
  foreach ($r in ([regex]::Matches($dIdx, "``?($idRx)``?") | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)) { if ($ids -notcontains $r) { $struct += "$($d.Name)\_index.md: dangling id $r" } }
}
foreach ($c in $containers) {
  if (-not (Test-Path "$($c.Dir.FullName)\_index.md")) { $struct += "$($c.Name): container missing _index.md"; continue }
  $cIdx = Get-Content "$($c.Dir.FullName)\_index.md" -Raw
  foreach ($k in $c.Children) { if ($cIdx -notmatch "``$([regex]::Escape($k))``") { $struct += "$($c.Name)\_index.md: does not list child domain $k" } }
  if ($rootIdx -notmatch "``$([regex]::Escape($c.Name))``") { $struct += "_index.md lacks a mention of container $($c.Name)" }
}
foreach ($m in [regex]::Matches($rootIdx, '(?m)^\|\s*`(\d\d-[\w-]+(?:/[\w-]+)?)`\s*\|')) { if ($domainDirs.Name -notcontains $m.Groups[1].Value -and $containers.Name -notcontains $m.Groups[1].Value) { $struct += "_index.md domain table row for non-existent folder $($m.Groups[1].Value)" } }
foreach ($r in ([regex]::Matches($playbook, "``($idRx)``") | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)) { if ($ids -notcontains $r) { $struct += "_playbook.md: dangling id $r" } }
$changelog = if (Test-Path "$root\_maintenance.md") { Get-Content "$root\_maintenance.md" -Raw } else { $struct += "_maintenance.md missing"; '' }
# count drift: where a top-level file states a count, it must equal the live count (phrases absent → no check)
$overview = if (Test-Path "$root\_overview.md") { Get-Content "$root\_overview.md" -Raw } else { '' }
$nPages = $pages.Count; $nPit = @($pages | Where-Object { $_.fm -and $_.fm.type -eq 'pitfall' }).Count; $nNon = $nPages - $nPit
$gAliasCount = 0; $inA = $false
foreach ($l in (Get-Content "$root\_glossary.md")) { if ($l -match '^## Aliases') { $inA = $true; continue }; if ($inA -and $l -match '^\|' -and $l -notmatch '^\|\s*(Alias|-+)\s*\|') { $gAliasCount++ } }
$gTermCount = 0; $inA = $false
foreach ($l in (Get-Content "$root\_glossary.md")) { if ($l -match '^## Aliases') { $inA = $true }; if (-not $inA -and $l -match '^\|' -and $l -notmatch '^\|\s*(Term|-+)\s*\|') { $gTermCount++ } }
$countChecks = @(
  @{ f='_index.md';    t=$rootIdx;  rx='(\d+) pages · (\d+) domains';                 want=@($nPages, $domainDirs.Count) },
  @{ f='_index.md';    t=$rootIdx;  rx='\((\d+) terms, (\d+) aliases\)';              want=@($gTermCount, $gAliasCount) },
  @{ f='_index.md';    t=$rootIdx;  rx='\((\d+) named failure cases';                 want=@($nPit) },
  @{ f='_overview.md'; t=$overview; rx='across (\d+) pages';                          want=@($nPages) },
  @{ f='_overview.md'; t=$overview; rx='(\d+) small, atomic';                         want=@($nPages) },
  @{ f='_overview.md'; t=$overview; rx='The (\d+) named failure narratives';          want=@($nPit) },
  @{ f='_overview.md'; t=$overview; rx='(\d+) terms merged';                          want=@($gTermCount) },
  @{ f='_overview.md'; t=$overview; rx='(\d+) aliases resolve';                       want=@($gAliasCount) },
  @{ f='_overview.md'; t=$overview; rx='all (\d+) non-pitfall pages';                 want=@($nNon) }
)
foreach ($c in $countChecks) {
  $m = [regex]::Match($c.t, $c.rx); if (-not $m.Success) { continue }
  for ($i = 0; $i -lt $c.want.Count; $i++) { if ([int]$m.Groups[$i+1].Value -ne $c.want[$i]) { $struct += "$($c.f): count drift '$($m.Value)' — live value $($c.want -join '/')" } }
}
foreach ($m in [regex]::Matches($overview, 'Counts: ([^\r\n]+)')) { foreach ($mm in [regex]::Matches($m.Groups[1].Value, '(\d+) (concept|decision|pattern|pitfall|checklist|procedure)')) { $live = @($pages | Where-Object { $_.fm -and $_.fm.type -eq $mm.Groups[2].Value }).Count; if ([int]$mm.Groups[1].Value -ne $live) { $struct += "_overview.md: count drift '$($mm.Value)' — live $live" } } }
foreach ($sec in [regex]::Matches($overview, '(?ms)^### (\d\d) [^\r\n]*\r?\n(.*?)(?=^### |^## |\z)')) {
  $nn = $sec.Groups[1].Value
  $c = $containers | Where-Object { $_.Name -like "$nn-*" } | Select-Object -First 1
  if ($c) {
    # container section: one line per child domain, naming `<slug>` in backticks and ending in "<n> pages + <m> pitfalls."
    foreach ($d in ($domainDirs | Where-Object { $_.Name -like "$($c.Name)/*" })) {
      $m = [regex]::Match($sec.Groups[2].Value, "(?m)^.*``$([regex]::Escape($d.Slug))``.*?(\d+) pages(?: \+ (\d+) pitfalls)?\."); if (-not $m.Success) { $struct += "_overview.md: container section '### $nn' has no counted line for $($d.Name)"; continue }
      $dp = @($pages | Where-Object { $_.domain -eq $d.Name -and $_.fm }); $dPit = @($dp | Where-Object { $_.fm.type -eq 'pitfall' }).Count; $dNon = $dp.Count - $dPit
      $sPit = if ($m.Groups[2].Success) { [int]$m.Groups[2].Value } else { 0 }
      if ([int]$m.Groups[1].Value -ne $dNon -or $sPit -ne $dPit) { $struct += "_overview.md: $($d.Name) count drift '$($m.Groups[1].Value) pages + $sPit pitfalls' — live $dNon pages + $dPit pitfalls" }
    }
    continue
  }
  $d = $domainDirs | Where-Object { -not $_.IsRef -and $_.Name -like "$nn-*" } | Select-Object -First 1; if (-not $d) { $struct += "_overview.md: section '### $nn' has no matching domain folder"; continue }
  $m = [regex]::Match($sec.Groups[2].Value, '(\d+) pages(?: \+ (\d+) pitfalls)?\.'); if (-not $m.Success) { continue }
  $dp = @($pages | Where-Object { $_.domain -eq $d.Name -and $_.fm }); $dPit = @($dp | Where-Object { $_.fm.type -eq 'pitfall' }).Count; $dNon = $dp.Count - $dPit
  $sPit = if ($m.Groups[2].Success) { [int]$m.Groups[2].Value } else { 0 }
  if ([int]$m.Groups[1].Value -ne $dNon -or $sPit -ne $dPit) { $struct += "_overview.md: $($d.Name) count drift '$($m.Value)' — live $dNon pages + $dPit pitfalls" }
}
foreach ($d in $domainDirs) { if ($overview -and $overview -notmatch "(?m)^### $($d.NN) ") { $struct += "_overview.md: no '### $($d.NN) …' section for $($d.Name)" } }
# glossary: See ids resolve (or <slug>.* domain wildcard); aliases resolve to a term
$gTerms = @(); $inAlias = $false
foreach ($l in (Get-Content "$root\_glossary.md")) {
  if ($l -match '^## Aliases') { $inAlias = $true; continue }
  if ($l -notmatch '^\|') { continue }
  $cells = @(($l.Trim() -replace '^\||\|$','') -split '\|' | ForEach-Object { $_.Trim() })
  if ($cells[0] -in 'Term','Alias' -or $cells[0] -match '^-+$') { continue }
  if (-not $inAlias) {
    $gTerms += $cells[0]
    if ($cells.Count -lt 3) { $struct += "_glossary.md: malformed row '$($cells[0])'"; continue }
    if ((($cells[1] -split '\s+').Count) -gt 25) { $struct += "_glossary.md: definition >25 words '$($cells[0])'" }
    foreach ($m in [regex]::Matches($cells[2], '`?([\w-]+)\.([\w*-]+)`?')) {
      $s = $m.Groups[1].Value; $pg = $m.Groups[2].Value
      if ($domainSlugs -notcontains $s) { $struct += "_glossary.md: See '$($m.Value)' unknown domain ('$($cells[0])')" }
      elseif ($pg -ne '*' -and $ids -notcontains "$s.$pg") { $struct += "_glossary.md: See dangling $s.$pg ('$($cells[0])')" }
    }
  }
}
$inAlias = $false
foreach ($l in (Get-Content "$root\_glossary.md")) {
  if ($l -match '^## Aliases') { $inAlias = $true; continue }
  if (-not $inAlias -or $l -notmatch '^\|') { continue }
  $cells = @(($l.Trim() -replace '^\||\|$','') -split '\|' | ForEach-Object { $_.Trim() })
  if ($cells[0] -eq 'Alias' -or $cells[0] -match '^-+$') { continue }
  if ($gTerms -notcontains $cells[1]) { $struct += "_glossary.md: alias '$($cells[0])' → '$($cells[1])' is not a Term" }
}
# sources: the source name is checked against $sources per page above. Whether a source is reachable as a
# local file is subject-specific, so nothing is resolved against the filesystem here; that name check is
# the guard.
# A "Maintainer/<date>" source must still be backed by a changelog entry of that date.
foreach ($p in ($pages | Where-Object fm)) {
  foreach ($s in @($p.fm.sources)) {
    if ($s -match '^Maintainer/(\d{4}-\d{2}-\d{2}) § ') {
      if ($changelog -notmatch "(?m)^- $([regex]::Escape($Matches[1]))\b") { $p.issues += "Maintainer source has no _maintenance.md changelog entry dated $($Matches[1])" }
    }
  }
}

"pages: $($pages.Count)  by domain: " + (($pages | Group-Object domain | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join ' ')
"by type: " + (($pages | Where-Object fm | Group-Object { $_.fm.type } | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join ' ')
"total body words: " + (($pages | Measure-Object words -Sum).Sum)
$bad = $pages | Where-Object { $_.issues.Count -gt 0 }
"files with issues: $($bad.Count)"
foreach ($p in $bad) { "-- " + ($p.file -replace [regex]::Escape($root),''); $p.issues | ForEach-Object { "     $_" } }
# ---- catalog: always regenerate in memory; write on -WriteCatalog, otherwise report staleness ----
if ($true) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine('# GENERATED from page frontmatter by wiki-validate.ps1 -WriteCatalog. Do not edit; edit the page.')
  [void]$sb.AppendLine('pages:')
  foreach ($p in ($pages | Where-Object fm | Sort-Object id)) {
    $q = { param($s) '"' + ($s -replace '"','\"') + '"' }
    [void]$sb.AppendLine("  - id: $($p.id)")
    [void]$sb.AppendLine("    type: $($p.fm.type)")
    [void]$sb.AppendLine("    title: $(& $q $p.fm.title)")
    [void]$sb.AppendLine("    summary: $(& $q $p.fm.summary)")
    [void]$sb.AppendLine("    domain: $($p.fm.domain)")
    [void]$sb.AppendLine("    stage: [$(@($p.fm.stage) -join ', ')]")
    [void]$sb.AppendLine("    topics: [$(@($p.fm.topics) -join ', ')]")
    [void]$sb.AppendLine("    depth: $($p.fm.depth)")
    [void]$sb.AppendLine("    applies_when:"); foreach ($a in @($p.fm.applies_when)) { [void]$sb.AppendLine("      - $(& $q $a)") }
    if (@($p.fm.not_for).Count) { [void]$sb.AppendLine("    not_for:"); foreach ($a in @($p.fm.not_for)) { [void]$sb.AppendLine("      - $(& $q $a)") } }
    [void]$sb.AppendLine("    sources:"); foreach ($a in @($p.fm.sources)) { [void]$sb.AppendLine("      - $(& $q $a)") }
    if (@($p.fm.related).Count) { [void]$sb.AppendLine("    related: [$(@($p.fm.related) -join ', ')]") }
    [void]$sb.AppendLine("    file: $($p.file -replace [regex]::Escape($root + '\'),'' -replace '\\','/')")
    [void]$sb.AppendLine("    words: $($p.words)")
  }
  $catText = $sb.ToString()
  if ($WriteCatalog) {
    [System.IO.File]::WriteAllText("$root\_catalog.yaml", $catText, (New-Object System.Text.UTF8Encoding $false))
    "catalog written: $root\_catalog.yaml"
  } else {
    $existing = if (Test-Path "$root\_catalog.yaml") { Get-Content "$root\_catalog.yaml" -Raw } else { '' }
    if (($existing -replace "`r`n","`n") -ne ($catText -replace "`r`n","`n")) { $struct += "_catalog.yaml stale — run validate.ps1 -WriteCatalog" }
  }
}
"structure issues: $($struct.Count)"
$struct | ForEach-Object { "     $_" }
# Unfilled subject vocabularies (see _bootstrap.md). Not issues — checks that are not running yet.
$todo = @()
if (-not $sources.Count) { $todo += '$sources (accepted source names; mirror _sources.md)' }
if (-not $stages.Count)  { $todo += '$stages (_schema.md §5)' }
if (-not $topics.Count)  { $todo += '$topics (_schema.md §5)' }
if (-not $depthPattern)  { $todo += '$depthPattern (_schema.md §5)' }
if ($todo.Count) {
  "vocabularies not yet defined - these checks are skipped: $($todo.Count)"
  $todo | ForEach-Object { "     $_" }
}
