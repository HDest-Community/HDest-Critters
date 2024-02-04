// ------------------------------------------------------------
// "GibMonster"
// ------------------------------------------------------------
class GibMonster : Babuin {

	override void postbeginplay(){
		super.postbeginplay();

		self.meleethreshold=200;
	}

	//this was surprisingly easy
	void A_GiblingSize () {
        CVar size = CVar.FindCVar('sv_giblingsize');

        if(size)
        {
            switch(size.GetBool())
            {
                default:
                case 0: A_SetScale (1); break;
                case 1: break;
            }
        }
    }

	default
	{
		//$Category "Monsters/Hideous Destructor"
		//$Title "GibMonster"
		//$Sprite "IMHDF1"

		translation 0;
		
		scale 1.0;
		speed 8;
		meleerange 20;
		maxtargetrange 128;
		painchance 200;
		maxstepheight 32;maxdropoffheight 32;
		seesound "GibMonster/Sight";painsound "GibMonster/Pain";
		deathsound "GibMonster/Death";activesound "GibMonster/Active";

		tag "$TAG_GIBMONSTER";
		obituary "$OB_GIBMONSTER";
		hitobituary "$OB_GIBMONSTER_HIT";
	}

	states
	{
		spawn:
			IMHD A 0;
			goto idle;
		seeend:
			#### A 0 {
				if(!random(0, 120)) {
					A_Vocalize(seesound);
					A_AlertMonsters();
				}
			}
			#### A 0 givebody(random(2,12));
			#### A 0 A_Jump(256,"see");
		melee:
			#### EE 3{
				A_FaceTarget(0,0);
				A_Vocalize("GibMonster/Bite");
				A_Changevelocity(cos(pitch)*2,0,sin(-pitch)*2,CVF_RELATIVE);
			}
			#### FF 3 A_Changevelocity(cos(pitch)*3,0,sin(-pitch)*3+2,CVF_RELATIVE);
			#### GG 1 TryLatch();
			goto postmelee;
		death:
			#### I 5{
				A_Vocalize(deathsound);
				bpushable = false;
				A_SpawnItemEx("BFGNecroShard",flags:SXF_TRANSFERPOINTERS|SXF_SETMASTER,240);
			}
			goto deathend;
		raise:
			#### NMLKJI 5;
			#### A 0 A_Jump(256,"see");
		ungib:
			TROO U 6;
			TROO UT 8;
			TROO SRQ 6;
			TROO PO 4;
			IMHD A 0 A_GiblingSize();
			#### A 0 A_Jump(256,"see");
		xdeath:
			TROO O 0 A_XScream();
			TROO OPQ 4{spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);}
			TROO RST 4;
			goto xdead;
		xxxdeath:
			TROO O 4 A_XScream();
			TROO PQRST 4;
		xdead:
			TROO U 5 canraise;
			loop;
	}
}
