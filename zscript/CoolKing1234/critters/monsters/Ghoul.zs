class HDGhoul : Hatchling {
    default {
        +noblood

        attacksound "Ghoul/attack";
        activesound "Ghoul/active";
        painsound "Ghoul/pain";

        tag "$TAG_GHOUL";
        obituary "$OB_GHOUL";
    }

    states {
        spawn:
            GHUL AB 10 A_HDWander(CHF_LOOK);
            loop;

        see:
            #### AB 4 A_HDChase();
            loop;

        missile:
            #### AB 2;
        aim:
            #### AB 1 A_TurnToAim(20);
            loop;

        shoot:
            #### B 1 bright A_Takeoff(true);
            #### C 1 bright ZapCheck();
            #### D 1 bright A_Takeoff();
        flying:
            #### CD 1 bright A_Flying();
            loop;

        flyend:
            #### CDEDC 1 bright {
                vel.xy *= 0.9;

                if (!(level.time & (1|2))) ZapCheck();
            }
        melee:
            #### CDEDC 2 bright {
                ZapCheck();
                A_FaceTarget();
            }
            #### B 0 A_JumpIf(
                !!target
                && distance3dsquared(target) < (90 * 90)
                && target.bSHOOTABLE
                && (
                    !HDMath.IsDead(target)
                    || random(0, 31)
                ),
                "melee"
            );
            #### BA 2 bright;
            goto see;

        pain:
            #### F 3;
            #### F 3 A_Vocalize(painsound);
            goto see;

        death:
            #### F 2 bright{
                A_SetTranslucent(1, 1);
                vel.z++;
                ZapCheck();
            }
            #### H 0 A_NoBlocking();
            #### HH 1 ZapArc(self);
            #### I 0 A_StartSound("ghoul/death", CHAN_BODY);
            #### II 1 ParticleZigZag(self,
                (pos.xy + (frandom(-radius, radius), frandom(-radius, radius)),
                pos.z + frandom(0, height)),
                (pos.xy, pos.z) + (frandom(-1, 1), frandom(-1, 1), frandom(-1, 1)) * frandom(30, 90)
            );
            #### J 1 {
                HDActor.HDBlast(self,
                    blastradius: 96,
                    blastdamage: random(1, 12),
                    blastdamagetype: "electrical",
                    immolateradius: 96,
                    immolateamount: random(4, 20),
                    immolatechance: 32
                );

                for (int i = 0; i < 4; i++) {
                    ParticleZigZag(self,
                        (pos.xy + (frandom(-radius, radius), frandom(-radius, radius)),
                        pos.z + frandom(0, height)),
                        (pos.xy, pos.z) + (frandom(-1, 1), frandom(-1, 1), frandom(-1, 1)) * frandom(30, 90)
                    );
                }
            }
            #### KKLL 1 A_FadeOut(0.2);
            stop;
    }
}