package dev.l2j.autobots

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel

//Needs to be reworked
internal object CoScopes {
    internal val generalScope: CoroutineScope = CoroutineScope(Dispatchers.Default)
    
    internal val sequenceScope: CoroutineScope = CoroutineScope(Dispatchers.Default)
    internal val massSpawnerScope: CoroutineScope = CoroutineScope(Dispatchers.Default)
    internal val massDespawnerScope: CoroutineScope = CoroutineScope(Dispatchers.Default)
    
    internal val onUpdateScope: CoroutineScope = CoroutineScope(Dispatchers.IO)

    internal fun shutdown() {
        generalScope.cancel("Server shutdown")
        sequenceScope.cancel("Server shutdown")
        massSpawnerScope.cancel("Server shutdown")
        massDespawnerScope.cancel("Server shutdown")
        onUpdateScope.cancel("Server shutdown")
    }
}