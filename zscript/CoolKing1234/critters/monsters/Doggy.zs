class Doggy : Babuin {

    override void postbeginplay(){
        super.postbeginplay();

        sprite = getspriteindex("DOG"..random(1, 5));
        self.meleethreshold=200;
    }

    override void CheckFootStepSound(){
        if (bplayingid) {
			HDHumanoid.FootStepSound(self, 0.4, drysound: "Dog/Step/Dry");
        } else if (!frame) {
			A_StartSound("Dog/Step/Wet", 88, CHANF_OVERLAP);
		}
    }

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Doggy"
        //$Sprite "ROTTA2"

        +cannotpush +pushable
        
        translation 0;
        
        health 50;
        speed 18;
        mass 60;
        meleerange 50;
        maxtargetrange 128;
        painchance 128;
        maxstepheight 32;
		maxdropoffheight 32;
        
        seesound "Dog/Sight";
		painsound "Dog/Pain";
        deathsound "Dog/Death";
		activesound "Dog/Active";
        
        damagefactor "hot",1.0;

        tag "$TAG_DOGGY";
        obituary "$OB_DOGGY";
        hitobituary "$OB_DOGGY_HIT";
    }

    states {
		prefetch:
			DOG1 A 0;
			DOG2 A 0;
			DOG3 A 0;
			DOG4 A 0;
			DOG5 A 0;
        spawn:
            DOG1 A 0;
            goto idle;
        spawnsniff:
            #### A 0{
                blookallaround = true;
            }
            #### ZZZZ 4 {
                angle += frandom(-2, 2);
                A_HDLook();
            }
            #### Z 2 {
                angle += frandom(-20, 20);
                if (!random(0, 9)) A_Vocalize(activesound);
            }
            #### ZZZ 2 A_HDLook();
            #### A 0 {
                blookallaround = false;
                if (!random(0, 6)) SetStateLabel("spawnwander");
            }
			loop;
        spawnstill:
            #### ZZ 8 A_HDLook();
            loop;
        seeend:
            #### A 0{
                if (!random(0, 120)) {
                    A_Vocalize(seesound);
                    A_AlertMonsters();
                }
            }
            #### A 0 givebody(random(2, 12));
			goto see;
        death:
            #### I 5{
                A_Vocalize(deathsound);
                bpushable = false;
            }
            goto deathend;
        raise:
            #### NMLKJI 5;
			goto see;
        ungib:
            #### N 6;
            #### NM 8;
            #### LKJ 6;
            #### IH 4;
			goto see;
        gib:
            #### H 0 A_XScream();
            #### HIJ 4 A_GibSplatter();
            #### KLM 4;
            goto gibbed;
        deadgib:
            #### H 4 A_XScream();
            #### IJKLM 4;
        gibbed:
            #### N 5 canraise;
            loop;
    }
}