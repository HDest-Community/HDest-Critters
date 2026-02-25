class DoggySpawner : ClusterSpawner {
    default {
        ClusterSpawner.actorClass 'Doggy';
        ClusterSpawner.maxDist 64.0;
    }
}

class RatSpawner : ClusterSpawner {
    default {
        ClusterSpawner.actorClass 'Rat';
        ClusterSpawner.maxSpawns 16;
        ClusterSpawner.maxDist 64.0;
    }
}

class WitheredSpawner : ClusterSpawner {
    default {
        ClusterSpawner.actorClass 'WitheredRandom';
        ClusterSpawner.maxDist 64.0;
    }
}

class WitheredRandom : DummySpawner {}

class WitheredSummonSpawner : DummySpawner {}