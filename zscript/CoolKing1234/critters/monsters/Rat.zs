class Rat : HDMobBase {

    Default {
        +FRIENDLY
        -COUNTKILL

        +CANNOTPUSH
        -ACTIVATEIMPACT
        -CANPUSHWALLS
        -CANUSEWALLS
        -ACTIVATEMCROSS

        health 8;
        gibhealth 8;
        radius 4;
        height 4;
        mass 10;
        speed 12;
        scale 0.333;
        maxstepheight 8;
        maxdropoffheight 64;
        meleerange 12;
        hdmobbase.seedist 10 * HDCONST_ONEMETRE;
        
        tag "$TAG_RAT";
        obituary "$OB_RAT";
        
        seesound "Rat/See";
        activesound "Rat/active";
        painsound "Rat/Pain";
        deathsound "Rat/Death";
    }

    override void PostBeginPlay() {
        super.PostBeginPlay();

        sprite = getSpriteIndex("RAT"..random(1, 2));
        resize(0.666, 1.5);
        voicepitch = 1.6 - scale.x + frandom(-0.1, 0.1);
    }

    override void CollidedWith(Actor other, bool passive) {
        super.CollidedWith(other, passive);

        // If that thing collided into the rat, is big enough, and is standing on top of the rat, crush rat.
        if (passive && other.mass >= (mass * 10) && other.pos.z == pos.z + height) A_Die();
    }

    States {
        PreFetch:
            RAT1 A 0;
            RAT2 A 0;
        Spawn:
            RAT1 A 0 A_HDLook(LOF_NOSOUNDCHECK);
            goto See;

        See:
            #### # 0 A_JumpIf(threat, 'Flee');
            #### # 0 A_JumpIf(target, 'Chase');
            goto Wander;

        Sniff:
            #### B 2;
            #### B 2 {
                angle += frandom(-20, 20);
            }
            #### BBBB 4 {
                angle += frandom(-2, 2);

                A_HDLook(LOF_NOJUMP);
            }
            #### B 2 {
                angle += frandom(-20, 20);
            }
            #### B 2 {
                if (!random(0, 9)) A_Vocalize(activesound);
            }
            #### # 0 A_JumpIf(target || threat, 'See');
            #### # 0 A_JumpIf(!random(0, 6), 'Wander');
            loop;

        Wander:
            #### # 0 A_JumpIf(!random(0, 15), 'Sniff');
            #### ABC random(3, 6) A_HDWander();
            goto See;

        Chase:
            #### ABC random(2, 6) A_HDChase(null, null);
            goto See;

        Flee:
            #### ABC random(2, 4) A_HDChase(null, null, CHF_FLEE);
            goto See;

        Pain:
            #### # 0 A_Vocalize(painsound);
            goto See;

        Death:
        Gib:
            #### # 0 A_Vocalize(deathsound);
            #### DEF 4 A_GibSplatter();
            stop;
    }
}