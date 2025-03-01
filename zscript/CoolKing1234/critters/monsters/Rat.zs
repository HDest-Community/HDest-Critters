class Rat : HDMobBase {

    int feedTics;

    Default {
        +FRIENDLY
        -COUNTKILL

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

        sprite = getspriteindex("RAT"..random(1, 2));
        resize(0.666, 1.5);
        voicepitch = 1.6 - scale.x + frandom(-0.1, 0.1);
    }

    override void Tick() {
        super.Tick();

        if (health) {
            let threatened = false;
            let prevThreat = threat;

            foreach (mo : BlockThingsIterator.Create(self, seedist)) {

                // If the thing doesn't exist,
                // or is the rat itself,
                // or is another rat,
                // or is dead,
                // or isn't a player or another mob,
                // skip.
                if (!mo
                    || mo == self
                    || mo.GetClassName() == GetClassName()
                    || !(mo is 'HDPlayerPawn' || mo is 'HDMobBase')
                    || HDMath.IsDead(mo)
                ) continue;

                let dist = Distance3D(mo);
                
                // If the rat isn't frightened or that thing is not the current threat,
                // and either there is no current threat or that thing is closer than the current threat,
                // and that thing is within sight,
                // make it the current threat and make the rat frightened.
                if (
                    (!bFRIGHTENED || prevThreat != mo)
                    && (!prevThreat || dist < Distance3D(prevThreat))
                    && CheckSight(mo)
                ) {
                    threatened = true;
                    threat = mo;
                    bFRIGHTENED = true;
                }

                // If that thing is big enough and is standing on top of the rat, crush rat.
                if (
                    mo.mass >= (mass * 10)
                    && mo.pos.z == pos.z + height
                    && Distance2D(mo) < radius + mo.radius
                ) {
                    A_Die();
                    break;
                }
            }

            if (feedTics < 0) feedTics++;

            // If the rat is currently frightened but has no threat,
            // make the rat no longer frightened.
            if (bFRIGHTENED && !threatened) {
                threat = null;
                bFRIGHTENED = false;
            }
        }
    }

    override bool ValidTarget(
		Actor other,
		bool sightCheck,
		double halfLookFOV,
		double minDist,
		double maxDist
    ) {
        return other
            && other.bIsMonster
            && other.GetClassName() != GetClassName()
            && HDMath.IsDead(other)
            && CheckSight(other)
            && (!target || Distance3D(other) < Distance3D(target));
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
                if (!random(0, 9)) {
                    A_Vocalize(activesound);
                }

                if (target || threat) {
                    SetStateLabel('See');
                } else if (!random(0, 6)) {
                    SetStateLabel('Wander');
                }
            }
            loop;

        Wander:
            #### # 0 A_JumpIf(!random(0, 15), 'Sniff');
            #### ABC random(3, 6) A_HDWander();
            goto See;

        Chase:
            #### ABC random(2, 6) A_HDChase('melee', null);
            goto See;

        Melee:
            #### # random(10, 30) {
                if (Distance3D(target) < meleerange) {
                    if (feedTics < random()) {
                        feedTics++;
                    } else {
                        feedTics = -feedTics;
                    }
                } else {
                    SetStateLabel('Chase');
                }
            }
            #### # 0 A_JumpIf(feedTics < 0, 'Wander');
            loop;

        Flee:
            #### ABC random(2, 4) A_HDChase(null, null, CHF_FLEE);
            goto See;

        Pain:
            #### # 0 A_PlaySound(painsound);
            goto See;

        Death:
        Gib:
            #### # 0 A_Vocalize(deathsound);
            #### DEF 4 A_GibSplatter();
            stop;
    }
}