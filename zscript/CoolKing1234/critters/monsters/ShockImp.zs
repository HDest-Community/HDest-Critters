
// ------------------------------------------------------------
// Thunderballer
// ------------------------------------------------------------
class ShockImp : FighterImp {
    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Shock Imp"
        //$Sprite "TROOA1"

        -missilemore
        translation 0;

        HDMobBase.downedframe 22;
        
        damagefactor "hot", 0.825;
        damagefactor "electrical", 0.5;

        seesound "shockimp/sight";
        painsound "shockimp/pain";
        deathsound "shockimp/death";
        activesound "shockimp/active";
        meleesound "shockimp/melee";

        obituary "$OB_SHIMP";
        hitobituary "$OB_SHIMP_HIT";
        tag "$TAG_SHIMP";
    }

    override void Tick() {
        super.Tick();

        if (health > 0 && !random(0, health)) A_ShimpZapArc();
    }

    action void A_ShimpZapArc(
        double rad = 0.0,
        int maxdamage = 8,
        bool indiscriminate = false
    ) {
        Array<Actor> zappables;
        zappables.clear();

        if(!rad) rad = frandom(32, 128);

        foreach (it : BlockThingsIterator.Create(invoker, rad)) {
            if (
                it != invoker
                && !(it is "ShockImp")
                && it.bshootable
                && invoker.bFRIENDLY != it.bFRIENDLY
                && invoker.Distance3DSquared(it) <= (rad * rad)
                && invoker.CheckSight(it)
            ) {
                zappables.push(it);
            }
        }

        Actor itt;
        if (zappables.size()) {
            itt = zappables[random(0, zappables.size() - 1)];
        }

        
        if (itt) {
            ZapArc(invoker, itt, 0, rad, rad * 0.3, dev: 0.8);
            itt.damagemobj(invoker, invoker, random(1, maxdamage), "electrical");
        } else {
            ZapArc(invoker, null, ARC2_RANDOMDEST, rad, rad * 0.3, dev: 0.8);
        }
    }

    states {
        spawn:
            SLHV A 0;
        recharge:
            #### A 6;
            #### ABCD 4 {
                HDMobAI.wander(self, true);
                if (!random(0, 2)) {
                    stamina = stamina >> 1;
                }
            }
            goto see;

        shoot:
            #### E 0 A_Jump(16,"hork");
            goto lead;

        lead:
            #### # 0 A_Strafe();
            #### E 4 A_FaceLastTargetPos(40, gunheight);
            #### # 0 A_Strafe();
            #### E 1 A_FaceLastTargetPos(20, gunheight);
            #### # 0 A_Strafe();
            #### FG random(6, 8) A_LeadTarget(min(20, lasttargetdist / getdefaultbytype("ShockImpBall").speed));
            #### # 0 A_JumpIf(!HDMobAI.TryShoot(self, gunheight, 256, 10, 10, flags: HDMobAI.TS_GEOMETRYOK), "see");
            #### HIJK random (4, 6) A_ShimpZapArc();
            #### L 6 A_SpawnProjectile("ShockImpBall", 34, 0, 0, CMF_AIMDIRECTION, pitch - frandom(0, 0.1));
            #### # 0 A_ShimpZapArc();
            #### M 4 A_ChangeVelocity(0, frandom(-3, 3), 0, CVF_RELATIVE);
            #### # 0 A_JumpIfTargetInsideMeleeRange("melee");
            #### # 0 A_JumpIf(!HDMobAI.TryShoot(self, gunheight, 512, 10, 10, flags: HDMobAI.TS_GEOMETRYOK), "see");
            #### # 0 A_Jump(16, "see");
            #### E 0 A_Jump(140, "coverfire");
            goto see;

        spam:
            #### E random(4, 6);
            #### # 0 A_Strafe();
            #### F 2 A_ShimpZapArc();
            #### # 0 A_Strafe();
            #### G 2 A_ShimpZapArc();
            #### HIJK random(6, 8) A_ShimpZapArc();
            #### L 6 A_SpawnProjectile("ShockImpBall", gunheight, 0, frandom(-3, 4), CMF_AIMDIRECTION, pitch + frandom(-2, 1.8));
            #### M 4 A_ShimpZapArc();
            #### # 0 A_JumpIf(firefatigue > HDCONST_MAXFIREFATIGUE, "pain");
        coverfire:
            #### # 0 A_JumpIfTargetInLOS("see");
            #### EEEEE 3 A_Coverfire("coverdecide");
            goto see;

        coverdecide:
            #### # 0 A_JumpIf(!HDMobAI.TryShoot(self, 32, 512, 10, 10, flags: HDMobAI.TS_GEOMETRYOK), "see");
            #### # 0 A_Jump(180, "spam");
            #### # 0 A_Jump(90, "hork");
            goto missile;

        juke:
            #### ABCD 4 {
                A_Strafe();
                A_TurnToAim(40, gunheight);
            }
            loop;
            
        melee:
            #### EFG random(6, 8) A_FaceLastTargetPos();
            #### HIJK random(4, 6) A_ShimpZapArc();
            #### L 8 bright A_FireballerScratch("ShockImpBall", random(10, 30));
            #### M 4 A_ShimpZapArc();
            goto see;

        missile:
            #### # 0 A_JumpIf(stamina > random(5, 10), "recharge");
            #### # 0 A_JumpIf(health < random(0, 200), 1);
            goto juke;
            #### # 4 A_Jump(8, "missile");
            #### EFG random(6, 8) {
                A_FaceLastTargetPos(3, 32, FLTP_TOP);
                A_LeadTarget(lasttargetdist * 0.15, maxturn: 45);
            }
            #### HIJK random(4, 6) A_ShimpZapArc();
            #### L 8 bright A_SpawnProjectile("ShockImpBall", flags: CMF_AIMDIRECTION, pitch);
            #### M 4 A_ShimpZapArc();
            goto see;

        hork:
            #### # 0 A_Jump(156, "spam");
            #### # 0 A_FaceLastTargetPos(40, gunheight);
            #### E 2 A_Strafe();
            #### # 0 A_Vocalize(seesound);
            #### EEEEE 2 A_SpawnItemEx("ReverseShockImpBallTail", 4, 24, gunheight, 1, 0, 0, 0, 160);
            #### EFG 2 A_Strafe();
            #### HIJK random(4, 6) A_ShimpZapArc();
            #### # 0 A_ShimpZapArc();
            #### # 0 A_SpawnProjectile("ShockImpBall", gunheight, 0, (frandom(-2, 10)), CMF_AIMDIRECTION, pitch + frandom(-4, 3.6));
            #### # 0 A_ShimpZapArc();
            #### # 0 A_SpawnProjectile("ShockImpBall", gunheight, 0, (frandom(-4, 4)), CMF_AIMDIRECTION, pitch + frandom(-4, 3.6));
            #### # 0 A_ShimpZapArc();
            #### # 0 A_SpawnProjectile("ShockImpBall", gunheight, 0, (frandom(-2, -10)), CMF_AIMDIRECTION, pitch + frandom(-4, 3.6));
            #### L 8;
            #### M 4 A_ShimpZapArc();
            #### # 0 A_JumpIf(!HDMobAI.TryShoot(self, 32, 256, 10, 10, flags: HDMobAI.TS_GEOMETRYOK), "see");
            #### # 0 A_Watch();
            goto see;

        pain:
            #### N 3 A_GiveInventory("HDFireEnder", 3);
            #### N 3 A_Vocalize(painsound);
            #### # 0 A_ShoutAlert(0.4, SAF_SILENT);
            #### A 2 A_FaceTarget();
            #### BCD 2 A_FastChase();
            #### # 0 A_JumpIf(firefatigue > (HDCONST_MAXFIREFATIGUE * 1.6), "see");
            goto missile;

        death:
            #### O 6 A_Gravity();
            #### P 6 A_Vocalize(deathsound);
            #### QRSTUV 5;
        dead:
        death.spawndead:
            #### V 3 canraise A_JumpIf(abs(vel.z) < 2, 1);
            loop;
            #### W 5 canraise A_JumpIf(abs(vel.z) >= 2, "Dead");
            loop;

        gib:
            #### # 0 A_Gravity();
            #### X 0 A_GibSplatter();
            #### Y 5 A_XScream();
            #### # 0 A_GibSplatter();
            #### Z 5 A_GibSplatter();
            #### [] 5;
        gibbed:
            #### ] 5 canraise A_JumpIf(abs(vel.z) < 2, 1);
            wait;
            SLHW A 5 canraise A_JumpIf(abs(vel.z) >= 2, "gibbed");
            wait;

        raise:
            #### V 4;
            #### UTS 6;
            #### RQPO 4;
            goto see;

        ungib:
            SLHW A 6;
            SLHV ][ 8;
            #### ZYX 6;
            #### A 4;
            goto see;

        falldown:
            #### N 5;
            #### O 5 A_Vocalize(deathsound);
            #### PQRST 2 A_SetSize(-1, max(deathheight, height - 10));
            #### U 2 A_SetSize(-1, deathheight);
            #### V 10 A_KnockedDown();
            wait;

        standup:
            #### VUTSRQ 5;
            #### # 0 A_Jump(64, 2);
            #### # 0 A_Vocalize(seesound);
            #### PO 4 {
                vel.xy -= (cos(angle), sin(angle)) * 0.3;
            }
            #### NE 5;
            goto see;
    }
}


class ShockImpBall : Foof {
    default {
        height 12;
        radius 12;
        gravity 0;
        
        decal "BulletScratch";
        
        damagefunction(random(20, 40));
        
        hdfireball.firefatigue int(HDCONST_MAXFIREFATIGUE * 0.25);
    }

    void ZapSomething() {
        roll = frandom(0, 360);
        
        A_StartSound("misc/arczap", CHAN_BODY);
        
        blockthingsiterator it = blockthingsiterator.create(self, 72);
        actor tb = target;
        actor zit = null;
        bool didzap = false;

        while (it.next()) {
            if (it.thing.bshootable && abs(it.thing.pos.z - pos.z) < 72) {
                zit = it.thing;

                if (
                    zit.health>0
                    && checksight(it.thing)
                    && (
                        !tb
                        || zit == tb.target
                        || !(zit is "ShockImp")
                    )
                ) {
                    A_Face(zit, 0, 0, flags: FAF_MIDDLE);
                    ZapArc(self, zit, ARC2_RANDOMDEST);
                    zit.damagemobj(self, tb, random(0, 7), "electrical");
                    didzap = true;
                    break;
                }
            }
        }

        if (!zit || zit == tb) {
            pitch = frandom(-90, 90);
            angle = frandom(0, 360);
        }

        if (!didzap) {
            ZapArc(self, null, ARC2_SILENT, radius: 32, height: 32, pvel: vel);
        }

        A_FaceTracer(4,4);

        if (bmissile && tracer) {
            vector3 vvv = tracer.pos - pos;

            if(vvv.x || vvv.y || vvv.z) {
                vvv *= 1.0 / max(abs(vvv.x), abs(vvv.y), abs(vvv.z));
                vel += vvv;
            }
        }

        if (pos.z - floorz < 24) {
            vel.z += 0.3;
        }
    }

    states {
        spawn:
            BAL2 A 0 ZapSomething();
            BAL2 AB 2 light("PLAZMABX1") A_Corkscrew();
            loop;
        death:
            BAL2 C 0 A_SprayDecal("CacoScorch", radius * 2);
            BAL2 C 0 A_StartSound("misc/fwoosh", 5);
            BAL2 CDE 3 light("BAKAPOST1") ZapSomething();
        death2:
            BAL2 E 0 ZapSomething();
            BAL2 E 3 light("PLAZMABX2") A_FadeOut(0.3);
            loop;
    }
}


class ReverseShockImpBallTail : ReverseImpBallTail {
    default {
        +nointeraction
        +forcexybillboard
        -invisible

        renderstyle "add";
        scale 0.6;
        alpha 0;
    }

    override void Tick() {
        super.Tick();

        A_SpawnParticle(
            "99 44 11",
            0, random(30, 40), frandom(1.2, 2.1),
            0, frandom(-4, 4), frandom(-4, 4),
            frandom(0, 2), frandom(-1, 1), frandom(-1,1),
            frandom(0.9, 1.3)
        );
    }

    states {
        spawn:
            BAL2 EEDC 2 bright {
                A_FadeIn(0.2);

                ZapArc(self, null, ARC2_RANDOMDEST);
            }
        death:
            BAL2 BAB 2 bright {
                A_FadeIn(0.2);

                ZapArc(self, null, ARC2_RANDOMDEST);
            }
            stop;
    }
}