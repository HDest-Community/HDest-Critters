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

        obituary "$OB_EVILSPRITE";
        hitobituary "$OB_EVILSPRITE_HIT";
    }

    states {
        spawn:
            FRIT A 0;
        spawn2:
            #### ABCD 6 A_HDLook();
            loop;
        see:
            #### A 0{
                if (!random(0,16)) {
                    vel.z += frandom(-4, 4);
                }
            }
            #### ABCD 4 A_HDChase();
            loop;
        missile:
            #### EEF 5;
            #### F 1 A_StartSound("EvilSprite/spit", CHAN_WEAPON);
            #### G 1 A_SpawnProjectile("SpriteBall", 16);
            #### G 5;
            #### ABCD 2;
            #### ABCD 3;
            #### A 0 SetStateLabel("see");
        pain:
            #### DAB 1;
            #### C 1 A_Recoil(4);
            #### D 1 A_Vocalize(painsound);
            #### ABCD 2 A_FastChase();
            #### ABCD 3;
            goto missile;
        Death:
            #### AABB 1 A_SpawnItemEx(
                "HDSmoke",
                random(-2, 2), random(-2, 2), random(4, 8),
                vel.x, vel.y, vel.z + 2,
                SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
            );
            TNT1 A 1{
                A_SpawnItemEx(
                    "HDExplosion",
                    0, 0, 3,
                    vel.x, vel.y, vel.z + 1,0,
                    SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
                );
                A_Scream();
                A_NoBlocking();
                if (master)master.stamina--;
            }
            TNT1 AA 1 A_SpawnItemEx(
                "HDSmokeChunk",
                0, 0, 3,
                vel.x + frandom(-4, 4), vel.y + frandom(-4, 4), vel.z + frandom(1, 6),
                0,
                SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
            );
            stop;
    }
}

class SpriteBall:HDImpBall{
    default {
        missiletype "ArdentipedeBallTail";
        speed 6;
        scale 0.4;
    }

    states {
        spawn:
            COMT ABC 2;
            loop;
        death:
            TNT1 AAA 0 A_SpawnItemEx("HDSmoke",flags:SXF_NOCHECKPOSITION);
            TNT1 A 0 {if (blockingmobj)A_Immolate(blockingmobj,target,40);}
            COMT DEFGHI 1 A_SpawnItemEx("HDSmoke",flags:SXF_NOCHECKPOSITION);
            goto super::death;
    }
}