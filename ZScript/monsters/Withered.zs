// ------------------------------------------------------------
// Withered
// ------------------------------------------------------------

class Withered : FighterImp {

    override void PostBeginPlay() {
        super.PostBeginPlay();

        sprite = getspriteindex("ZFD"..random(1, 4));
        resize(0.8, 1.1);
    }

    override void deathdrop() {
        if (!bfriendly && !bhasdropped) {
            bhasdropped = true;

            if (!random(0, 6)) {
                for (int i = 0; i < 9; i++) {
                    DropNewItem("HDCasingBits", 200);
                }
            }
        }
    }

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Withered"
        //$Sprite "ZFODF1"

        mass 75;
        health 50;
        gibhealth 100;

        SeeSound "ZombieFodder/Sight";
        PainSound "ZombieFodder/Pain";
        DeathSound "ZombieFodder/Death";
        ActiveSound "ZombieFodder/Active";
        meleesound "ZombieFodder/Melee";


        tag "$TAG_WITHERED";
        obituary "$OB_WITHERED";
        hitobituary "$OB_WITHERED_HIT";
    }

    states {
        prefetch:
            ZFD1 A 0;
            ZFD2 A 0;
            ZFD3 A 0;
            ZFD4 A 0;
        spawn:
            ZFD1 A 0;
            goto idle;
        melee:
            #### EE 4 A_FaceLastTargetPos();
            #### F 2;
            #### G 8 A_FireballerScratch(null, random(10, 30), ballchance: 0);
            #### F 4;
            goto see;
        missile:
        shoot:
        lead:
        spam:
        coverfire:
        coverdecide:
        hork:
            goto see;
    }
}

class WitheredSummoner : Withered {

    bool summoned;

    override void PostBeginPlay() {
        super.PostBeginPlay();

        sprite = getspriteindex("ZFD4");
    }

    action void A_SummonWithereds() {
        let numSpawned = 0;
        foreach (player : players) if(HDPlayerPawn(player.mo) && !HDSpectator(player.mo)) numSpawned += random(10, 20);

        for (let i = numSpawned; i > 0; i--) Spawn('WitheredSummonerSeeker', pos);
        invoker.summoned = true;
    }

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Withered"
        //$Sprite "ZFODF1"

        mass 75;
        health 30;
        gibhealth 100;
    }

    states {
        missile:
            #### # 0 A_JumpIf(summoned || !(target is 'HDPlayerPawn'), 'see');
            #### V 8 A_FaceLastTargetPos();
            #### # 0 A_Vocalize("ZombieFodder/Summon");
            #### W 3 A_FaceLastTargetPos();
            #### XYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXY 1 A_FaceLastTargetPos();
            #### # 0 A_SummonWithereds();
            #### WV 7 A_FaceLastTargetPos();
            goto see;
    }
}


Class WitheredSummonerSeeker : Actor {

    Array<Name> summonables;

    override void PostBeginPlay() {
        Name classes[] = {
            'WitheredRandom',
            'ZombieScientistRandom',
            'MeleeZombie'
        };

        foreach (cls : classes) {
            if ((Class<Actor>)(cls)) {
                summonables.push(cls);
            }
        }
    }

    default {
        +THRUACTORS
        +NOTELEPORT
        +FRIGHTENED
        -COUNTKILL

        Speed 100;
        Radius 20;
        Height 56;
        Mass 40;
        MaxStepHeight 64;
        MaxDropOffHeight 64;
    }
    
    states {
        Spawn:
            TNT1 A 1 A_Chase();
            TNT1 A 0 A_CheckSight("SpawnLoop");
            loop;
        SpawnLoop:
            TNT1 A 10 A_Wander();
            TNT1 A 0 A_CheckSight("Create");
            TNT1 A 0 A_Jump(5, "Die");
            loop;
        Create:
            TNT1 A 0 A_StartSound(Spawn(summonables[random(0, summonables.Size() - 1)], pos).activesound);
        Die:
            stop;
    }
}