$file = 'e:\Project\DAWIS\lib\src\features\report\data\services\pdf_perincian_service.dart'
$lines = [System.IO.File]::ReadAllLines($file)
Write-Host "Total lines in original: $($lines.Length)"
Write-Host "Line 920 (0-indexed 919): $($lines[919])"
Write-Host "Line 921 (0-indexed 920): $($lines[920])"
Write-Host "Line 1595 (0-indexed 1594): $($lines[1594])"
Write-Host "Line 1596 (0-indexed 1595): $($lines[1595])"
Write-Host "Line 1597 (0-indexed 1596): $($lines[1596])"

# Keep lines 1-920 (0-indexed 0..919)
$before = $lines[0..919]
# Keep lines 1596-end (0-indexed 1595..)
$after = $lines[1595..($lines.Length-1)]

Write-Host "Before lines: $($before.Length)"
Write-Host "After lines: $($after.Length)"

$newCode = [System.IO.File]::ReadAllText('e:\Project\DAWIS\scratch\new_potensi_function.dart')
$newCodeLines = $newCode -split "`n"
Write-Host "New code lines: $($newCodeLines.Length)"

$result = ($before -join "`r`n") + "`r`n" + $newCode + "`r`n" + ($after -join "`r`n")
[System.IO.File]::WriteAllText($file, $result)

$resultLines = [System.IO.File]::ReadAllLines($file)
Write-Host "Result total lines: $($resultLines.Length)"
Write-Host "Done! Spliced file successfully."
