class StillAliveStick : UndeadHomeboy {

    override void Tick() {
        super.Tick();

        if (health > 0 && !random(0, 15)) {
            A_SpawnItemEx(
                "BloodSplatSilent",
                random(-2, 2), random(-2, 2), frandom(32, 40),
                0, 0, 0, 0,
                SXF_NOCHECKPOSITION,
                192
            );
        }
    }

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Still Alive"
        //$Sprite "PPLA0"

        +NOFEAR
        +LOOKALLAROUND

        speed 0;
        mass int.MAX>>1;
        meleerange 0;
        deathheight HDCONST_PLAYERHEIGHT;

        HDMobBase.downedframe 7; // "H"
        HDMobBase.fov 360;
        HDMobBase.seedist 256;

		tag "$TAG_STILLALIVE";
        obituary "$OB_STILLALIVE";
        hitobituary "$OB_STILLALIVE_HIT";
    }

    states {
        spawn:
            PPL6 A 0;
        spawngrunt:
        spawnswitch:
        spawnwander:
        spawnstill:
        await:
            #### AB random(1, 16) A_HDLook(!random(0, 49) ? 0 : LOF_NOSEESOUND);
            loop;
        see:
            #### AB random(1, 16) A_HDChase(null, "missile", !random(0, 49) ? 0 : CHF_NOPLAYACTIVE);
            loop;
        falldown:
        standup:
        pain:
            #### C 8 A_Vocalize(painsound);
            goto see;
        melee:
        missile:
            #### C random(6, 12) A_TurnToAim(shootstate: "aiming");
            loop;
		aiming:
            #### D random(6, 12) A_StartAim();
            #### D 0 A_JumpIf(noammo(), "reload");
        shoot:
            #### D 1 A_SetTics(min(1, int(lasttargetdist) >> 5));
            #### D 2 A_LeadTarget(lasttargetdist * 0.01, randompick(0, 0, 0, 1));
        fire:
            #### E 1 bright light("SHOT") A_PistolZombieAttack();
        postshot:
            #### D 1;
            #### D 0 A_JumpIf(chamber != 2 || !target, "nope");
            #### D 0 {
                if (firemode > 0) {
                    pitch += frandom(-2.4, 2);
                    angle += frandom(-2, 2);
                    setstatelabel("fire");
                } else {
                    A_SetTics(random(3, 10));
                }
            }
            #### D 0 A_HDMonsterRefire("see", 25);
            goto fire;
        reload:
            #### # 7 A_PistolZombieUnload();
            #### # 8 A_HDReload();
            goto see;
        death:
        gib:
        deadgib:
            #### F 8 A_Scream();
            #### G 8;
        deathend:
        dead:
        gibbed:
        death.spawndead:
            #### H 8 canraise;
            loop;
        raise:
            #### H 4;
            #### G 8;
            #### F 6;
            goto see;
    }
}