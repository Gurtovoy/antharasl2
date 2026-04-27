$srcDir = Join-Path $PSScriptRoot "gameserver\src\main\java"
$files = Get-ChildItem -Path $srcDir -Filter "*.java" -Recurse
$totalChanges = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content
    
    # Pattern: Remove remaining (Object) casts used as method args where not needed
    # .sendPacket((Object)xxx) -> .sendPacket(xxx)  -- but skip IBroadcastPacket casts
    
    # Pattern: Fix getParams().getString((Object)xxx) -> getParams().getString(xxx)
    $content = [regex]::Replace($content, '\.getString\(\(Object\)([^)]+)\)', '.getString($1)')
    
    # Pattern: Fix .getIntegerArray((Object)xxx, -> .getIntegerArray(xxx,
    $content = [regex]::Replace($content, '\.getIntegerArray\(\(Object\)([^,]+),', '.getIntegerArray($1,')
    
    # Pattern: Remove (Object) casts in .set() single-arg calls 
    # Fix patterns like .set((Object)key, value) where first arg needs to be String
    $content = [regex]::Replace($content, '\.set\(\(Object\)([^,]+),\s*', '.set($1, ')
    
    # Pattern: Remove (Object) casts in .getEnum() calls
    $content = [regex]::Replace($content, '\.getEnum\(\(Object\)', '.getEnum(')
    
    # Pattern: Remove (Object) casts in .getString() calls
    $content = [regex]::Replace($content, '\.getString\(\(Object\)', '.getString(')
    
    # Pattern: Fix (Object) cast in entry.getKey()/(Object)entry.getValue() from Map.entrySet()
    $content = [regex]::Replace($content, '\(Object\)(entry\.\w+\(\))', '$1')
    
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $totalChanges++
        Write-Host "Fixed: $($file.Name)"
    }
}
Write-Host "Total files changed: $totalChanges"
