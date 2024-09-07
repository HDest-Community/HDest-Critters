class Rat : HDMobBase {

    bool scared;
    int feedTics;

    override void PostBeginPlay() {
        super.PostBeginPlay();

        resize(0.666, 1.5);
        voicepitch = 1.6 - scale.x + frandom(-0.1, 0.1);
    }

    Default {
        +FRIENDLY
        +DONTHARMSPECIES
        +NOINFIGHTING
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
        
        tag "$TAG_RAT";
        obituary "$OB_RAT";
        
        seesound "Rat/See";
        activesound "Rat/active";
        painsound "Rat/Pain";
        deathsound "Rat/Death";
    }


    override void Tick() {
        super.Tick();

        // if (hd_debug && !(Level.time % 35)) {
        //     if (target) console.printf("[Rat] Target: "..target.GetClassName());
        //     if (threat) console.printf("[Rat] Threat: "..threat.GetClassName());
        // }

        if (health) {
            threat = null;

            Actor mo;
            for (let iter = BlockThingsIterator.Create(self, random(512, 1024)); iter.Next(); mo = iter.thing) {

                // If the thing doesn't exist, or is the rat itself, or is another rat, skip.
                if (!mo || mo == self || mo.GetClassName() == GetClassName()) continue;
                
                // If the thing is a player or another mob and isn't dead, continue.
                if ((mo is 'HDPlayerPawn' || mo is 'HDMobBase') && !HDMath.IsDead(mo)) {
                
                    // If that thing is close enough and within sight, make it the threat.
                    if (Distance3D(mo) < (random(0, mo.mass / mass) * HDCONST_ONEMETRE) && CheckSight(mo)) {
                        threat = mo;
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
            && HDMath.IsDead(other)
            && CheckSight(other);
    }

    action void A_FindFood() {
        // if (hd_debug) console.printf("[Rat] FeedTics: "..invoker.feedTics);

        Actor corpse;

        // Find closest corpse to eat
        if (invoker.feedTics == 0) {
            double corpseDist = -1.0;
            
            Actor mo;
            for (let iter = BlockThingsIterator.Create(self, 1024); iter.Next(); mo = iter.thing) {

                if (!mo || mo == self || mo.GetClassName() == GetClassName() || !HDMath.IsDead(mo)) continue;

                let dist = Distance3D(mo);

                if (corpseDist < 0 || dist < corpseDist && invoker.CheckSight(mo)) {
                    corpse = mo;
                    corpseDist = dist;
                }
            }
            
            if (corpse && corpseDist >= 0) invoker.target = corpse;
        }

        if (invoker.feedTics < 0 || (corpse && invoker.Distance3D(corpse) < 12)) {
            invoker.feedTics++;
        }

        if (invoker.feedTics >= random()) {
            invoker.target = null;
            invoker.feedTics = -invoker.feedTics;
            invoker.SetStateLabel('Wander');
            return;
        }

        if (invoker.target) {
            invoker.SetStateLabel('Chase');
        }
    }

    States {
        Spawn:
            RATA A 0 ; // A_HDLook();
            goto See;

        See:
            // #### # random(4, 8) A_HDChase();
            #### # 0 A_JumpIf(threat && !random(0, feedTics), 'Flee');
            #### # 0 A_JumpIf(target, 'Chase');
            goto Wander;

        Sniff:
            #### B 2;
            #### B 2 {
                angle += frandom(-20, 20);
                
                if (!random(0, 9)) {
                    A_Vocalize(activesound);
                }
            }
            #### BBBB 4 {
                angle += frandom(-2, 2);

                A_FindFood();
            }
            #### B 2 {
                angle += frandom(-20, 20);
                
                if (!random(0, 9)) {
                    A_Vocalize(activesound);
                }
            }
            #### B 2 {
                if (!random(0, 6)) {
                    SetStateLabel('Wander');
                }
            }
            Loop;

        Wander:
            #### # 0 A_JumpIf(!random(0, 15), 'Sniff');
            #### ABC random(3, 6) A_HDWander();
            goto See;

        Chase:
            #### ABC random(2, 6) A_HDChase();
            goto See;

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
            Stop;
    }
}