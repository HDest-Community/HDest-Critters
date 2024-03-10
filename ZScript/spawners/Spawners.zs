class DoggySpawner : IdleDummy {
    
    int maxSpawns;
    int numSpawned;

    override void PostBeginPlay() {
        super.PostBeginPlay();

        angle = random(1, 360);
        
        let i = random();
        for (let j = 8; j >= 0; j--) {
            if (i >> j) {
                maxSpawns = 8 - j;
                break;
            }
        }
    }

    action void A_SpawnDoggies(int dist) {
        let failedAttempts = 0;

        while(invoker.numSpawned < invoker.maxSpawns && failedAttempts < 10) {

            // Pick a random spot around origin to spawn
            let spawnPos = Vec3Offset(FRandom(-64, 64), FRandom(-64, 64), 0);

            if (hd_debug) Console.PrintF("Attempt #"..(failedAttempts + 1).." to spawn Doggy #"..(invoker.numSpawned + 1).." of "..invoker.maxSpawns.." at pos="..spawnPos);

            // Try to spawn the mob.  If it failed to spawn, or spawned outside of the level, or spawned stuck, remove it and try again.
            let spawned = Spawn('Doggy', spawnPos);
            if (!spawned || !Level.IsPointInLevel(spawned.pos) || !spawned.TestMobjLocation()) {
                spawned.Destroy();
                failedAttempts++;

                if (hd_debug) Console.PrintF("Failed to spawn Doggy #"..invoker.numSpawned..", retrying");
            } else {
                invoker.numSpawned++;
                failedAttempts = 0;
            }
        }
    }


    states {
        spawn:
            TNT1 A 0 nodelay A_SpawnDoggies(maxSpawns > 1 ? 35 : 0);
            stop;
    }
}

class WitheredSpawner : IdleDummy {
    
    int maxSpawns;
    int numSpawned;

    override void PostBeginPlay() {
        super.PostBeginPlay();

        angle = random(1, 360);
        
        let i = random();
        for (let j = 8; j >= 0; j--) {
            if (i >> j) {
                maxSpawns = 8 - j;
                break;
            }
        }
    }

    action void A_SpawnWithereds(int dist) {
        let failedAttempts = 0;

        while(invoker.numSpawned < invoker.maxSpawns && failedAttempts < 10) {

            // Pick a random spot around origin to spawn
            let spawnPos = Vec3Offset(FRandom(-64, 64), FRandom(-64, 64), 0);

            if (hd_debug) Console.PrintF("Attempt #"..(failedAttempts + 1).." to spawn Withered #"..(invoker.numSpawned + 1).." of "..invoker.maxSpawns.." at pos="..spawnPos);

            // Try to spawn the mob.  If it failed to spawn, or spawned outside of the level, or spawned stuck, remove it and try again.
            let spawned = Spawn('WitheredRandom', spawnPos);
            if (!spawned || !Level.IsPointInLevel(spawned.pos) || !spawned.TestMobjLocation()) {
                spawned.Destroy();
                failedAttempts++;

                if (hd_debug) Console.PrintF("Failed to spawn Withered #"..invoker.numSpawned..", retrying");
            } else {
                invoker.numSpawned++;
                failedAttempts = 0;
            }
        }
    }

    states {
        spawn:
            TNT1 A 0 nodelay A_SpawnWithereds(maxSpawns > 1 ? 40 : 0);
            stop;
    }
}

class WitheredRandom : RandomSpawner {
    default {
        DropItem 'Withered', 256, 30;
        DropItem 'WitheredSummoner', 256, 1;
    }
}