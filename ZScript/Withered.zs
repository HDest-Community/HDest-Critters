// ------------------------------------------------------------
// Withered
// ------------------------------------------------------------

class Withered : Serpentipede {

	override void postbeginplay() {
		super.postbeginplay();

		resize(0.8, 1.1);
	}

	override void deathdrop() {
		if (!bfriendly) A_DropItem("HDSpent7mmSpawner", -1, 40);
	}

	default
	{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Withered"
		//$Sprite "ZFODF1"

		mass 75;
		health 10;
		gibhealth 50;

		SeeSound "ZombieFodder/Sight";
		PainSound "ZombieFodder/Pain";
		DeathSound "ZombieFodder/Death";
		ActiveSound "ZombieFodder/Active";
		meleesound "ZombieFodder/Melee";


		tag "$TAG_WITHERED";
		obituary "$OB_WITHERED";
		hitobituary "$OB_WITHERED_HIT";
	}

	states
	{
		spawn:
			ZFOD A 0;

		missile:
		shoot:
		lead:
		spam:
		coverfire:
		coverdecide:
		hork:
			goto see;
	}
}

class HDSpent7mmSpawner : Actor {
	States
	{
		Spawn:
			ZFOD AAAAAAAAA 0 A_DropItem("HDSpent7mm", -1, 200);
			stop;
	}
}