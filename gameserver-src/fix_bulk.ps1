$srcDir = Join-Path $PSScriptRoot "gameserver\src\main\java"

# Get all Java files
$files = Get-ChildItem -Path $srcDir -Filter "*.java" -Recurse

$totalChanges = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content
    
    # Pattern 1: Remove (Object) casts in .put() calls for Trove maps
    # e.g., .put(key, (Object)value) -> .put(key, value)
    $content = [regex]::Replace($content, '\.put\(([^,]+),\s*\(Object\)([^)]+)\)', '.put($1, $2)')
    
    # Pattern 2: Remove (Object) casts in .add() calls  
    # e.g., .add((Object)value) -> .add(value) but be careful
    # Only for collection add calls, not method params
    
    # Pattern 3: Remove (Object[]) casts in .values() calls
    # e.g., .values((Object[])new X[]) -> .values(new X[])
    $content = [regex]::Replace($content, '\.values\(\(Object\[\]\)new\s+', '.values(new ')
    
    # Pattern 4: Remove (Object) casts in Map.get() calls that cause issues
    # e.g., .get((Object)key) -> .get(key)  for Trove/Napile maps where key is already correct type
    $content = [regex]::Replace($content, '\.get\(\(Object\)([^)]+)\)', '.get($1)')
    
    # Pattern 5: Remove (Object) casts in .contains() calls
    $content = [regex]::Replace($content, '\.contains\(\(Object\)([^)]+)\)', '.contains($1)')
    
    # Pattern 6: Remove (Object) casts in .containsEvent() calls
    $content = [regex]::Replace($content, '\.containsEvent\(\(Object\)([^)]+)\)', '.containsEvent($1)')
    
    # Pattern 7: Remove (Object) casts in .remove() calls  
    $content = [regex]::Replace($content, '\.remove\(\(Object\)([^)]+)\)', '.remove($1)')
    
    # Pattern 8: Remove (Object) in .getBool((Object)param, ...) calls
    $content = [regex]::Replace($content, '\.getBool\(\(Object\)([^,]+),', '.getBool($1,')
    
    # Pattern 9: Remove (Object) in .getInteger((Object)...) calls
    $content = [regex]::Replace($content, '\.getInteger\(\(Object\)([^)]+)\)', '.getInteger($1)')
    
    # Pattern 10: Remove (Object) in .set((Object)key, (Object)value) calls
    $content = [regex]::Replace($content, '\.set\(\(Object\)([^,]+),\s*\(Object\)([^)]+)\)', '.set($1, $2)')
    
    # Pattern 11: Remove double (Object)((Object)x) casts 
    $content = [regex]::Replace($content, '\(\(Object\)\(\(Object\)([^)]+)\)\)', '$1')
    
    # Pattern 12: Remove (Object) cast wrapping in ((Object)x).getClass()
    $content = [regex]::Replace($content, '\(\(Object\)([^)]+)\)\.getClass\(\)', '$1.getClass()')
    
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $totalChanges++
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "Total files changed: $totalChanges"
