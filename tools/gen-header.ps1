<#
.SYNOPSIS
  Generate a header from an autotools ".in" template for the MSVC build.

  Upstream (libsidplayfp / libresidfp) is autotools-only: it substitutes @TOKEN@
  placeholders in *.in templates at configure time. We don't run configure, so
  this script does the same substitution at build time, driven by the
  GenerateBuildHeaders target in the .vcxproj. This keeps version-derived headers
  (sidversion.h, siddefs-fp.h, config_version.h) in sync with the submodule
  automatically, so a version bump is just "git submodule update" + rebuild.

  Version/package values are read from the submodule's configure.ac:
    LIB_MAJOR/LIB_MINOR/LIB_LEVEL  <- m4_define([lib_major|minor|level], [N])
    PACKAGE_VERSION                <- "MAJ.MIN.LEV"
    PACKAGE_NAME / PACKAGE_URL     <- AC_INIT(...)
  Any remaining @TOKEN@s (e.g. compiler-specific ones) must be supplied via
  -Subst "KEY=VALUE;KEY2=VALUE2". Leftover unsubstituted tokens are an error.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$In,           # template (*.in)
    [Parameter(Mandatory)][string]$Out,          # generated header
    [Parameter(Mandatory)][string]$ConfigureAc,  # submodule configure.ac
    [string]$Subst = ''                          # extra "KEY=VALUE;..." substitutions
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $In))          { throw "template not found: $In" }
if (-not (Test-Path -LiteralPath $ConfigureAc)) { throw "configure.ac not found: $ConfigureAc" }

$map = @{}
$ac = Get-Content -Raw -LiteralPath $ConfigureAc
foreach ($lvl in 'major', 'minor', 'level') {
    if ($ac -match "m4_define\(\[lib_$lvl\]\s*,\s*\[(\d+)\]\)") { $map["LIB_$($lvl.ToUpper())"] = $Matches[1] }
    else { throw "lib_$lvl not found in $ConfigureAc" }
}
$map['PACKAGE_VERSION'] = "$($map['LIB_MAJOR']).$($map['LIB_MINOR']).$($map['LIB_LEVEL'])"
if ($ac -match 'AC_INIT\(\s*\[([^\]]+)\]\s*,\s*\[[^\]]*\]\s*,\s*\[[^\]]*\]\s*,\s*\[[^\]]*\]\s*,\s*\[([^\]]*)\]') {
    $map['PACKAGE_NAME'] = $Matches[1]
    $map['PACKAGE_URL']  = $Matches[2]
}

if ($Subst) {
    foreach ($pair in ($Subst -split ';')) {
        if ($pair) { $kv = $pair -split '=', 2; $map[$kv[0]] = $kv[1] }
    }
}

$text = Get-Content -Raw -LiteralPath $In
foreach ($k in $map.Keys) { $text = $text.Replace("@$k@", [string]$map[$k]) }

$leftover = [regex]::Match($text, '@[A-Za-z_][A-Za-z0-9_]*@')
if ($leftover.Success) { throw "unsubstituted token $($leftover.Value) in $In" }

# LF, no BOM, to match the upstream template style and avoid spurious churn.
$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($Out, $text, $enc)
