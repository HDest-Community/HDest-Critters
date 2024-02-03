class Doggy : Babuin {

	override void postbeginplay(){
		super.postbeginplay();

		self.meleethreshold=200;
	}

	action void A_CheckFreedoomSprite(){
		// No-op
	}

	override void CheckFootStepSound(){
		if (bplayingid)HDHumanoid.FootStepSound(self,0.4,drysound:"Dog/Step/Dry");
		else if (!frame)A_StartSound("Dog/Step/Wet",88,CHANF_OVERLAP);
	}

	default
	{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Doggy"
		//$Sprite "ROTTA2"

		+cannotpush +pushable
		
		translation "";
		
		health 50;
		speed 18;
		mass 60;
		meleerange 50;
		maxtargetrange 128;
		painchance 128;
		maxstepheight 32;maxdropoffheight 32;
		
		seesound "Dog/Sight";painsound "Dog/Pain";
		deathsound "Dog/Death";activesound "Dog/Active";
		
		damagefactor "hot",1.0;

		tag "$TAG_DOGGY";
		obituary "$OB_DOGGY";
		hitobituary "$OB_DOGGY_HIT";
	}

	states
	{
		spawn:
			ROTD A 0;
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
			}loop;
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
			#### A 0 A_Jump(256, "see");
		death:
			#### I 5{
				A_Vocalize(deathsound);
				bpushable = false;
			}
			goto deathend;
		raise:
			#### NMLKJI 5;
			#### A 0 A_Jump(256,"see");
		ungib:
			#### N 6;
			#### NM 8;
			#### LKJ 6;
			#### IH 4;
			#### A 0 A_Jump(256,"see");
		xdeath:
			#### H 0 A_XScream();
			#### HIJ 4{spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);}
			#### KLM 4;
			goto xdead;
		xxxdeath:
			#### H 4 A_XScream();
			#### IJKLM 4;
		xdead:
			#### N 5 canraise;
			loop;
	}
}