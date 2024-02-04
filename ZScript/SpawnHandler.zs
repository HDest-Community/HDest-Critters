// Struct for Enemyspawn information.
class CritterSpawnEnemy play {

    // ID by string for spawner
    string spawnName;

    // ID by string for spawnees
    Array<CritterSpawnEnemyEntry> spawnReplaces;

    // Whether or not to persistently spawn.
    bool isPersistent;

    // Whether or not to replace the original enemy
    bool replaceEnemy;

    string toString() {

        let replacements = "[";

        foreach (spawnReplace : spawnReplaces) replacements = replacements..", "..spawnReplace.toString();

        replacements = replacements.."]";

        return String.format("{ spawnName=%s, spawnReplaces=%s, isPersistent=%b, replaceEnemy=%b }", spawnName, replacements, isPersistent, replaceEnemy);
    }
}

class CritterSpawnEnemyEntry play {

    string name;
    int    chance;

    string toString() {
        return String.format("{ name=%s, chance=%s }", name, chance >= 0 ? "1/"..(chance + 1) : "never");
    }
}

// One handler to rule them all.
class CrittersHandler : EventHandler {
    // List of persistent classes to completely ignore.
    // This -should- mean this mod has no performance impact.
    static const string blacklist[] = {
        'HDSmoke',
        'BloodTrail',
        'CheckPuff',
        'WallChunk',
        'HDBulletPuff',
        'HDFireballTail',
        'ReverseImpBallTail',
        'HDSmokeChunk',
        'ShieldSpark',
        'HDFlameRed',
        'HDMasterBlood',
        'PlantBit',
        'HDBulletActor',
        'HDLadderSection'
    };

    // List of Enemy-spawn associations.
    // used for Enemy-replacement on mapload.
    array<CritterSpawnEnemy> EnemySpawnList;

    bool cvarsAvailable;

    // appends an entry to Enemyspawnlist;
    void addEnemy(string name, Array<CritterSpawnEnemyEntry> replacees, bool persists, bool rep=true) {

        if (hd_debug) {

            let msg = "Adding "..(persists ? "Persistent" : "Non-Persistent").." Replacement Entry for "..name..": [";

            foreach (replacee : replacees) msg = msg..", "..replacee.toString();

            console.printf(msg.."]");
        }

        // Creates a new struct;
        CritterSpawnEnemy spawnee = CritterSpawnEnemy(new('CritterSpawnEnemy'));

        // Populates the struct with relevant information,
        spawnee.spawnName = name;
        spawnee.isPersistent = persists;
        spawnee.replaceEnemy = rep;
        spawnee.spawnReplaces.copy(replacees);

        // Pushes the finished struct to the array.
        enemySpawnList.push(spawnee);
    }

    CritterSpawnEnemyEntry addEnemyEntry(string name, int chance) {

        // Creates a new struct;
        CritterSpawnEnemyEntry spawnee = CritterSpawnEnemyEntry(new('CritterSpawnEnemyEntry'));
        spawnee.name = name;
        spawnee.chance = chance;
        return spawnee;
    }

    // Populates the replacement and association arrays.
    void init() {

        cvarsAvailable = true;

        // --------------------
        // Enemy spawn lists.
        // --------------------

        // Doggies
        Array<CritterSpawnEnemyEntry> spawns_doggy;
        spawns_doggy.push(addEnemyEntry('Zombieman', doggy_zombieman_spawn_bias));
        spawns_doggy.push(addEnemyEntry('Demon', doggy_demon_spawn_bias));
        addEnemy('Doggy', spawns_doggy, doggy_persistent_spawning);

        // Evil Sprites
        Array<CritterSpawnEnemyEntry> spawns_evilSprite;
        spawns_evilSprite.push(addEnemyEntry('HDCasingBits', evilsprite_casings_spawn_bias));
        spawns_evilSprite.push(addEnemyEntry('HDGoreBits', evilsprite_gore_spawn_bias));
        spawns_evilSprite.push(addEnemyEntry('DeadDoomImp', evilsprite_deadimp_spawn_bias));
        spawns_evilSprite.push(addEnemyEntry('DeadDemon', evilsprite_deaddemon_spawn_bias));
        addEnemy('EvilSprite', spawns_evilSprite, evilsprite_persistent_spawning);

        // Gib Monsters
        Array<CritterSpawnEnemyEntry> spawns_gibMonster;
        spawns_gibMonster.push(addEnemyEntry('HDCasingBits', gibmonster_casings_spawn_bias));
        spawns_gibMonster.push(addEnemyEntry('HDGoreBits', gibmonster_gore_spawn_bias));
        spawns_gibMonster.push(addEnemyEntry('DeadDoomImp', gibmonster_deadimp_spawn_bias));
        spawns_gibMonster.push(addEnemyEntry('DeadDemon', gibmonster_deaddemon_spawn_bias));
        addEnemy('GibMonster', spawns_gibMonster, gibmonster_persistent_spawning);

        Array<CritterSpawnEnemyEntry> spawns_gibMonster_cyberGibs;
        spawns_gibMonster_cyberGibs.push(addEnemyEntry('CyberGibs', gibmonster_cybergibs_spawn_bias));
        addEnemy('GibMonster', spawns_gibMonster_cyberGibs, true);

        // Withereds
        Array<CritterSpawnEnemyEntry> spawns_withereds;
        spawns_withereds.push(addEnemyEntry('HDCasingBits', withered_casings_spawn_bias));
        spawns_withereds.push(addEnemyEntry('HDGoreBits', withered_gore_spawn_bias));
        spawns_withereds.push(addEnemyEntry('DeadDoomImp', withered_deadimp_spawn_bias));
        spawns_withereds.push(addEnemyEntry('DeadDemon', withered_deaddemon_spawn_bias));
        addEnemy('Withered', spawns_withereds, withered_persistent_spawning);
    }

    // Random stuff, stores it and forces negative values just to be 0.
    bool giveRandom(int chance) {
        if (chance > -1) {
            let result = random(0, chance);

            if (hd_debug) console.printf("Rolled a "..(result + 1).." out of "..(chance + 1));

            return result == 0;
        }

        return false;
    }

    // Tries to replace the item during spawning.
    bool tryReplaceEnemy(ReplaceEvent e, string spawnName, int chance) {
        if (giveRandom(chance)) {
            if (hd_debug) console.printf(e.replacee.getClassName().." -> "..spawnName);

            e.replacement = spawnName;

            return true;
        }

        return false;
    }

    // Tries to create the Enemy via random spawning.
    bool tryCreateEnemy(Actor thing, string spawnName, int chance) {
        if (giveRandom(chance)) {
            if (hd_debug) console.printf(thing.getClassName().." + "..spawnName);

            Actor.Spawn(spawnName, thing.pos);

            return true;
        }

        return false;
    }

    override void worldLoaded(WorldEvent e) {

        // Populates the main arrays if they haven't been already.
        if (!cvarsAvailable) init();
    }

    override void checkReplacement(ReplaceEvent e) {

        // Populates the main arrays if they haven't been already.
        if (!cvarsAvailable) init();

        // If there's nothing to replace or if the replacement is final, quit.
        if (!e.replacee || e.isFinal) return;

        // If thing being replaced is blacklisted, quit.
        foreach (bl : blacklist) if (e.replacee is bl) return;

        string candidateName = e.replacee.getClassName();

        // If current map is Range, quit.
        if (level.MapName == 'RANGE') return;

        handleEnemyReplacements(e, candidateName);
    }

    override void worldThingSpawned(WorldEvent e) {

        // Populates the main arrays if they haven't been already.
        if (!cvarsAvailable) init();

        // If thing spawned doesn't exist, quit.
        if (!e.thing) return;

        // If thing spawned is blacklisted, quit.
        foreach (bl : blacklist) if (e.thing is bl) return;

        string candidateName = e.thing.getClassName();

        // If current map is Range, quit.
        if (level.MapName == 'RANGE') return;

        handleEnemySpawns(e.thing, candidateName);
    }

    private void handleEnemyReplacements(ReplaceEvent e, string candidateName) {

        // Checks if the level has been loaded more than 1 tic.
        bool prespawn = !(level.maptime > 1);

        // Iterates through the list of Enemy candidates for e.thing.
        foreach (enemySpawn : enemySpawnList) {

            if ((prespawn || enemySpawn.isPersistent) && enemySpawn.replaceEnemy) {
                foreach (spawnReplace : enemySpawn.spawnReplaces) {
                    if (spawnReplace.name ~== candidateName) {
                        if (hd_debug) console.printf("Attempting to replace "..candidateName.." with "..enemySpawn.spawnName.."...");

                        if (tryReplaceEnemy(e, enemySpawn.spawnName, spawnReplace.chance)) return;
                    }
                }
            }
        }
    }

    private void handleEnemySpawns(Actor thing, string candidateName) {

        // Checks if the level has been loaded more than 1 tic.
        bool prespawn = !(level.maptime > 1);

        // Iterates through the list of Enemy candidates for e.thing.
        foreach (enemySpawn : enemySpawnList) {

            // if an Enemy is owned or is an ammo (doesn't retain owner ptr),
            // do not replace it.
            let item = Inventory(thing);
            if (
                (prespawn || enemySpawn.isPersistent)
             && (!(item && item.owner) && prespawn)
             && !enemySpawn.replaceEnemy
            ) {
                foreach (spawnReplace : enemySpawn.spawnReplaces) {
                    if (spawnReplace.name ~== candidateName) {
                        if (hd_debug) console.printf("Attempting to spawn "..enemySpawn.spawnName.." with "..candidateName.."...");

                        if (tryCreateEnemy(thing, enemySpawn.spawnName, spawnReplace.chance)) return;
                    }
                }
            }
        }
    }
}
