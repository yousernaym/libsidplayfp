<#
.SYNOPSIS
  Regenerate a libsidplayfp .bin driver image from its .a65 source.

  Mirrors the upstream autotools rule (Makefile.am, ".a65.bin"):
      xa -R -G <in.a65> -o <tmp.o65>
      od -v -An -w8 -tx1 <tmp.o65> | sed -re 's/[[:alnum:]]+/0x&,/g' > <out.bin>
  i.e. assemble to a relocatable o65 object, then emit its bytes as a C array
  initializer (lowercase "0xNN," tokens, 8 per line, LF line endings) that
  psiddrv.cpp / MUS.cpp #include directly.

  Driven by the GenerateSidBins target in libsidplayfp.vcxproj; xa65.exe is the
  vendored cross-assembler built by tools/xa65/xa65.vcxproj.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Xa,    # path to xa65.exe
    [Parameter(Mandatory)][string]$A65,   # input .a65 source
    [Parameter(Mandatory)][string]$Bin    # output .bin (C array include)
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Xa)) { throw "xa65 assembler not found: $Xa" }
if (-not (Test-Path -LiteralPath $A65)) { throw "a65 source not found: $A65" }

$o65 = "$Bin.o65"
try {
    & $Xa -R -G $A65 -o $o65
    if ($LASTEXITCODE -ne 0) { throw "xa65 failed ($LASTEXITCODE) on $A65" }

    $bytes = [System.IO.File]::ReadAllBytes($o65)
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        [void]$sb.Append((' 0x{0:x2},' -f $bytes[$i]))
        if ((($i + 1) % 8) -eq 0) { [void]$sb.Append("`n") }
    }
    if (($bytes.Length % 8) -ne 0) { [void]$sb.Append("`n") }

    # LF, no BOM, to match the od|sed output and avoid spurious git churn.
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Bin, $sb.ToString(), $enc)
}
finally {
    if (Test-Path -LiteralPath $o65) { Remove-Item -LiteralPath $o65 -Force }
}
