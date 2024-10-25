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
        spawns_doggy.push(addEnemyEntry('ShotgunGuy', doggy_shotgunguy_spawn_bias));
        spawns_doggy.push(addEnemyEntry('Demon', doggy_demon_spawn_bias));
        addEnemy('DoggySpawner', spawns_doggy, doggy_persistent_spawning);

        // Evil Sprites
        Array<CritterSpawnEnemyEntry> spawns_evilSprite;
        spawns_evilSprite.push(addEnemyEntry('LostSoul', evilsprite_lostsoul_spawn_bias));
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
        addEnemy('GibMonster', spawns_gibMonster_cyberGibs, true, false);

        // Ghouls
        Array<CritterSpawnEnemyEntry> spawns_ghoul;
        spawns_ghoul.push(addEnemyEntry('LostSoul', ghoul_lostsoul_spawn_bias));
        addEnemy('HDGhoul', spawns_ghoul, ghoul_persistent_spawning);

        // Rats
        Array<CritterSpawnEnemyEntry> spawns_rat;
        spawns_rat.push(addEnemyEntry('DeadZombieStormtrooper', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadZombieAutoStormtrooper', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadZombieSemiStormtrooper', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadZombieSMGStormtrooper', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadJackboot', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadJackAndJillboot', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadUndeadJackbootman', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadZombieShotgunner', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadFighterImp', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadHealerImp', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadMageImp', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadBabuin', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadSpecBabuin', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadSpectre', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadFlyZapper', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadBabuinito', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadSpecBabuinito', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('PistolZombiemanCorpse', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('SawnoffZombiemanCorpse', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieLadyCleaver', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieLadyKnife', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieLadySyringe', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieLadyWrench', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieAxe', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieChainsaw', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieCrowbar', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('Dead_ZombieHammer', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadCombatJackboot', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadDoomedJackboot', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadDoomedJackAndJillboot', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadDoomedZombieShotgunner', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadRiotCopZombie', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadZombieDog', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadSpecZombieDog', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadRifleman', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('ReallyDeadRifleman', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('DeadRiflemanCrouched', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('ReallyDeadRiflemanCrouched', rat_corpse_spawn_bias));

        spawns_rat.push(addEnemyEntry('HDHeadsStickBase', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHeadsStickOld', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHeadStickBase', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHeadStickBlack', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHeadStickOld', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDDeadStick', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDTwitchStick', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDTwitchHang', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDTwitchHangNS', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHTNoGuts', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHTLkDown', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHTLkUp', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHTNoBrain', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDHTSkull', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt2', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt3', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt4', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt5', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt2NS', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt3NS', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt4NS', rat_corpse_spawn_bias));
        spawns_rat.push(addEnemyEntry('HDMt5NS', rat_corpse_spawn_bias));
        addEnemy('RatSpawner', spawns_rat, rat_persistent_spawning, false);

        // Shocker Imp
        Array<CritterSpawnEnemyEntry> spawns_shimp;
        spawns_shimp.push(addEnemyEntry('DoomImp', shockimp_spawn_bias));
        addEnemy('ShockImp', spawns_shimp, shockimp_persistent_spawning);

        // Still Alive Stick
        Array<CritterSpawnEnemyEntry> spawns_stillAlive;
        spawns_stillAlive.push(addEnemyEntry('LiveStick', stillalive_spawn_bias));
        addEnemy('StillAliveStick', spawns_stillAlive, stillalive_persistent_spawning);

        // Withereds
        Array<CritterSpawnEnemyEntry> spawns_withereds;
        spawns_withereds.push(addEnemyEntry('Zombieman', withered_zombieman_spawn_bias));
        spawns_withereds.push(addEnemyEntry('ShotgunGuy', withered_shotgunguy_spawn_bias));
        spawns_withereds.push(addEnemyEntry('DoomImp', withered_imp_spawn_bias));
        spawns_withereds.push(addEnemyEntry('Demon', withered_demon_spawn_bias));
        spawns_withereds.push(addEnemyEntry('HDCasingBits', withered_casings_spawn_bias));
        spawns_withereds.push(addEnemyEntry('HDGoreBits', withered_gore_spawn_bias));
        spawns_withereds.push(addEnemyEntry('DeadZombieman', withered_deadzombieman_spawn_bias));
        spawns_withereds.push(addEnemyEntry('DeadShotgunGuy', withered_deadshotgunguy_spawn_bias));
        spawns_withereds.push(addEnemyEntry('DeadDoomImp', withered_deadimp_spawn_bias));
        spawns_withereds.push(addEnemyEntry('DeadDemon', withered_deaddemon_spawn_bias));
        addEnemy('WitheredSpawner', spawns_withereds, withered_persistent_spawning);
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

            // if currently in pre-spawn or configured to be persistent,
            // and original thing being spawned is not an owned item,
            // and not configured to replace original spawn,
            // attempt to spawn new thing.
            let item = Inventory(thing);
            if (
                (prespawn || enemySpawn.isPersistent)
             && !(item && item.owner)
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
