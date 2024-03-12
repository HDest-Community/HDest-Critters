// ------------------------------------------------------------
// EvilSprite
// ------------------------------------------------------------
class EvilSprite : HDMobBase {

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Sprite"
        //$Sprite "FRITA0"

        monster; +nogravity +float +floatbob
        +avoidmelee +lookallaround
        +pushable +dontfall +cannotpush +thruspecies
        +hdmobbase.doesntbleed
        -telestomp -solid

        species "BaronOfHell";
        tag "$TAG_EVILSPRITE";
        
        health 35;
        radius 11;
        height 32;
        scale 0.333;
        speed 4;
        mass 33;
        painchance 120;

        damagefactor "cold", 1.2;
        damagefactor "Balefire", 0.1;
        
        seesound "EvilSprite/see";
        painsound "EvilSprite/pain";
        deathsound "EvilSprite/death";
        meleesound "EvilSprite/melee";

        obituary "$OB_EVILSPRITE";
        hitobituary "$OB_EVILSPRITE_HIT";
    }

    states {
        spawn:
            FRIT A 0 bright;
        spawn2:
            #### ABCD 6 bright A_HDLook();
            loop;
        see:
            #### A 0 bright {if (!random(0,16)) vel.z += frandom(-4, 4);}
            #### ABCD 4 bright A_HDChase();
            loop;
        melee:
            #### S 6 bright A_FaceTarget();
            #### T 6 bright;
            #### U 6 bright A_FireballerScratch("SpriteBall", random(8, 32));
            goto see;
        missile:
            #### S 0 bright A_Jump(64, "missile2");
            #### S 6 bright A_FaceLastTargetPos();
            #### T 6 bright;
            #### U 6 bright A_SpawnProjectile("SpriteBall", 16);
            goto see;
        missile2:
            #### E 6 bright A_FaceLastTargetPos();
            #### F 6 bright A_StartSound("EvilSprite/spit", CHAN_WEAPON);
            #### G 6 bright A_SpawnProjectile("SpriteComet", 16);
            goto see;
        pain:
            #### H 3 bright;
            #### H 1 bright A_Recoil(4);
            #### H 1 bright A_Vocalize(painsound);
            #### ABCD 2 bright A_FastChase();
            #### ABCD 3 bright;
            goto missile;
        Death:
		    #### I 0 bright spawn("HDExplosion", pos, ALLOW_REPLACE);
            #### I 6 bright A_Scream();
            #### J 5 bright A_NoBlocking();
            #### KLMNOPQR 4 bright A_SpawnItemEx(
                "HDSmoke",
                random(-2, 2), random(-2, 2), random(4, 8),
                vel.x, vel.y, vel.z + 2,
                SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
            );
            stop;
    }
}

class SpriteBall : HDImpBall {
    default {
        -ROLLSPRITE;
        -ROLLCENTER;

        missiletype "HDImpBallTail";
        speed 6;
        scale 0.4;
        damagetype "hot";
    }

    states {
        spawn:
            FRTM ABABAB 2 bright A_FBTailAccelerate();
        spawn2:
            FRTM AB 6 bright A_HDIBFly();
            loop;
        death:
            TNT1 AAA 0 A_SpawnItemEx("HDSmoke", flags: SXF_NOCHECKPOSITION);
            TNT1 A 0 {if (blockingmobj) A_Immolate(blockingmobj, target, 40);}
            FTRM CDE 1 A_SpawnItemEx("HDSmoke", flags: SXF_NOCHECKPOSITION);
            goto super::death;
    }
}

class SpriteComet : HDFireBall {
    default {
        renderstyle "normal";
        missiletype "SpriteCometTail";
        speed 15;
        scale 0.4;
        damagetype "hot";
    }

    states {
        spawn:
            COMT ABC 6 bright A_FBTail();
            loop;
        death:
            TNT1 AAA 0 A_SpawnItemEx("HDSmoke", flags: SXF_NOCHECKPOSITION);
            TNT1 A 0 {
                if (blockingmobj) {
                    A_Immolate(blockingmobj, target, 80);
                }
            }
            COMT DEFGHI 1 bright A_SpawnItemEx("HDSmoke", flags: SXF_NOCHECKPOSITION);
            stop;
    }
}

class SpriteCometTail : HDFireBallTail {
    default {
        renderstyle "normal";
        gravity 0;
    }

    states {
        spawn:
            FRTB ABCDEFGHI 1 Bright;
            Stop;
    }
}