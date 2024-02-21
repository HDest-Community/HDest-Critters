// ------------------------------------------------------------
// Withered
// ------------------------------------------------------------

class Withered : FighterImp {

    override void postbeginplay() {
        super.postbeginplay();

        sprite = getspriteindex("ZFD"..random(1, 3));
        resize(0.8, 1.1);
    }

    override void deathdrop() {
        if (!bfriendly) A_DropItem("HDSpent7mmSpawner", -1, 40);
    }

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Withered"
        //$Sprite "ZFODF1"

        mass 75;
        health 10;
        gibhealth 50;

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

class HDSpent7mmSpawner : Actor {
    States {
        Spawn:
            ZFOD AAAAAAAAA 0 A_DropItem("HDSpent7mm", -1, 200);
            stop;
    }
}