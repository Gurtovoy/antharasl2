$srcDir = Join-Path $PSScriptRoot "gameserver\src\main\java"
$count = 0

Get-ChildItem -Path $srcDir -Recurse -Filter "*.java" | ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)
    $original = $content

    # Fix 1: Remove (AbstractHolder) cast in super() calls in parsers
    $content = $content -replace 'super\(\(AbstractHolder\)', 'super('

    # Fix 2: Remove (Object) from .put() calls on napile maps - remaining patterns
    # e.g. this._events.put(hash, (Object)event) -> this._events.put(hash, event)
    $content = $content -replace '\.put\(([^,]+),\s*\(Object\)', '.put($1, '

    # Fix 3: Remove (Object) from .add() calls  
    # e.g. .add((Object)skill, chance) -> .add(skill, chance)
    $content = $content -replace '\.add\(\(Object\)', '.add('

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($_.FullName, $content)
        $count++
        Write-Host "Fixed: $($_.FullName)"
    }
}
Write-Host "Total files fixed: $count"
