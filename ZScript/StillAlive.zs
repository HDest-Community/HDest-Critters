class StillAliveStick : UndeadHomeboy {
    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Still Alive"
        //$Sprite "PPLA0"

        +solid
        +shootable
        +dontthrust
        +dontgib

        speed 0;
        mass int.MAX;
        meleerange 0;
        deathheight HDCONST_PLAYERHEIGHT;

        HDMobBase.downedframe 8; // "H"
        HDMobBase.fov 360;
        HDMobBase.seedist 256;

		tag "$TAG_STILLALIVE";
        obituary "$OB_STILLALIVE";
        hitobituary "$OB_STILLALIVE_HIT";
    }

    states {
        spawn:
            PPL6 A 0;
            goto spawnstill;
        spawngrunt:
        spawnstill:
        spawnswitch:
        spawnwander:
            #### AB random(1, 16) A_HDLook(!random(0, 49) ? 0 : LOF_NOSEESOUND);
            loop;
        see:
            #### AB random(1, 16) {
                A_SpawnItemEx(
                    "BloodSplatSilent",
                    random(-2, 2), random(-2, 2), frandom(32, 40),
                    0, 0, 0, 0,
                    SXF_NOCHECKPOSITION,
                    192
                );

                A_JumpIf(noammo(), "reload");

                A_HDChase(
                    null, "missile",
                    !random(0, 49) ? 0 : CHF_NOPLAYACTIVE,
					0.0
                );
            }
            loop;
        melee:
        falldown:
        standup:
        pain:
            #### C 8 A_Vocalize(painsound);
            goto see;
        missile:
            #### C random(6, 12) A_JumpIf(lasttargetdist > seedist, "see");
			#### C 0 A_TurnToAim(shootstate: "aiming");
            loop;
		aiming:
            #### D random(6, 12) A_StartAim();
        shoot:
            #### E 1 bright light("SHOT") A_PistolZombieAttack();
			#### D random(6, 12);
            #### C random(6, 12) A_HDMonsterRefire("shoot", 100 * lasttargetdist / seedist);
            goto see;
        reload:
            #### # 7 A_PistolZombieUnload();
            #### # 8 A_HDReload();
            goto see;
        death:
            #### F 8 A_Scream();
            #### G 8;
        deathend:
        dead:
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