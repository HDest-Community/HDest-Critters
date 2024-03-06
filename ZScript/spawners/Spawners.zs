class DoggySpawner : IdleDummy {
    
    int maxSpawns;
    int numSpawned;

    override void PostBeginPlay() {
        super.PostBeginPlay();

        angle = random(1, 360);
        maxSpawns = random(1, 3);
    }

    action void A_SpawnDoggies(int dist) {
        while(invoker.numSpawned < invoker.maxSpawns) {
            let spawnAngle = (invoker.numSpawned % invoker.maxSpawns) * (360 / invoker.maxSpawns) + angle;
            
            if (hd_debug) console.printf("Spawning Doggy #"..(invoker.numSpawned + 1).." of "..invoker.maxSpawns.." with angle="..spawnAngle.." & dist="..dist);
            
            let offs = AngleToVector(spawnAngle, dist);
            Spawn('Doggy', pos + offs);
            invoker.numSpawned++;
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
        maxSpawns = random(1, 3);
    }

    action void A_SpawnWithereds(int dist) {
        while(invoker.numSpawned < invoker.maxSpawns) {
            let spawnAngle = (invoker.numSpawned % invoker.maxSpawns) * (360 / invoker.maxSpawns) + angle;
            
            if (hd_debug) console.printf("Spawning Withered #"..(invoker.numSpawned + 1).." of "..invoker.maxSpawns.." with angle="..spawnAngle.." & dist="..dist);
            
            let offs = AngleToVector(spawnAngle, dist);
            Spawn('Withered', pos + offs);
            invoker.numSpawned++;
        }
    }


    states {
        spawn:
            TNT1 A 0 nodelay A_SpawnWithereds(maxSpawns > 1 ? 40 : 0);
            stop;
    }
}
