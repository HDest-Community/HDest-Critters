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

    action void A_Lunge() {
        A_FaceTarget(16, 16);
        bnodropoff = false;
        A_Changevelocity(1, 0, 0, CVF_RELATIVE);
        if (A_JumpIfTargetInLOS("null", 20, 0, 128)) {
            invoker.A_Vocalize(seesound);
            SetStateLabel("jump");
        }
    }

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Withered"
        //$Sprite "ZFODF1"

        mass 75;
        health 50;
        gibhealth 100;
        meleerange 40;

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
            #### ABCD 2 A_Lunge();
            goto see;
        jump:
            #### E 3 A_FaceTarget(16, 16);
            #### F 3 A_Changevelocity(cos(pitch) * 2, 0, sin(-pitch) * 2, CVF_RELATIVE);
            #### G 2 A_FaceTarget(6, 6, FAF_TOP);
            #### F 1 A_ChangeVelocity(cos(pitch) * 8, 0, sin(-pitch - frandom(-4, 1)) * 8, CVF_RELATIVE);
            #### ABCD 2 A_HDChase();
            goto missile;
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

        sprite = getspriteindex("ZFD"..random(1, 4));
        resize(0.8, 1.1);
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
            #### # 0 A_JumpIf(!summoned && target is 'HDPlayerPawn' && health < random(0, 40), 1);
            goto super::missile;
            #### # 0 { bnopain = true; }
            #### V 8 A_FaceLastTargetPos();
            #### # 0 A_Vocalize("ZombieFodder/Summon");
            #### W 3 A_FaceLastTargetPos();
            #### XYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXYXY 1 A_FaceLastTargetPos();
            #### # 0 A_SummonWithereds();
            #### # 0 { bnopain = default.bnopain; }
            #### WV 7 A_FaceLastTargetPos();
            goto see;
    }
}


Class WitheredSummonerSeeker : Actor {

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
            TNT1 A 0 A_Jump(15, "SpawnLoop");
            loop;
        SpawnLoop:
            TNT1 A 10 A_Wander();
            TNT1 A 0 A_CheckSight("Create");
            TNT1 A 0 A_Jump(5, "Die");
            loop;
        Create:
            TNT1 A 0 A_StartSound(Spawn('WitheredSummonSpawner', pos).activesound);
        Die:
            stop;
    }
}