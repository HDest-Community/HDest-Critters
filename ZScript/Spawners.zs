class DeadImpSpawnerReplacer:RandomSpawner replaces DeadImpSpawner{
	default{
		+ismonster
		dropitem "DeadSerpentipede",256,5;
		dropitem "DeadRegentipede",256,2;
		dropitem "DeadArdentipede",256,3;
		//dropitem "GibMonsterSpawner",256,2;
		// guess this'll have to do for now
		dropitem "GibMonster",256,2;
		dropitem "Withered",256,1;
		dropitem "EvilSprite",256,1;
	}
}

class DeadDemonSpawnerReplacer:RandomSpawner replaces DeadDemonSpawner{
	default{
		+ismonster
		dropitem "DeadBabuin",256,5;
		dropitem "DeadSpecBabuin",256,2;
		dropitem "DeadSpectre",256,1;
		dropitem "GibMonster",256,2;
		dropitem "Withered",256,1;
		dropitem "EvilSprite",256,1;
	}
}

class CyberGibsReplacer:RandomSpawner replaces CyberGibs{
	default{
		+ismonster
		dropitem "GibMonster",256,1;
		dropitem "CyberGibs2",256,5;
	}
}

class CyberGibs2:CyberGibs{}

// I couldn't figure this out :(
/*class GibMonsterSpawner : actor
{
	Default
	{
	}
	States
	{
	Spawn:
		TNT1 A 0 A_SpawnItemEx("DeadSerpentipede");
		TNT1 A 0 A_SpawnItemEx("GibMonster");
		stop;
	}
}*/

class DecoPusher2:IdleDummy replaces DecoPusher{
	states{
	spawn:
		TNT1 A 0 nodelay{
			int times=random(1,5);
			class<actor> thingy="HDGoreBits";
			if(!random(0,64)){
				if(!random(0,6))thingy="InnocentBarrel";
				else thingy="InnocentFireCan";
			}else if(!random(0,2)){
				times=random(2,6);
				switch(random(0,6)){
				case 0: thingy="HDSpentShell";times*=random(1,3);break;
				case 1: thingy="HDSpent9mm";times*=random(1,5);break;
				case 2: thingy="HDSpent7mm";break;
				case 3: thingy="TerrorCasing";times=random(1,3);break;
				case 4: thingy="GibMonster";times=random(1,3);break;
				case 5: thingy="Withered";break;
				case 6: thingy="EvilSprite";times=random(1,2);break;
				}
			}
			flinetracedata spawnpos;
			for(int i=0;i<times;i++){
				LineTrace(
					frandom(0,360),frandom(0,96),frandom(-45,45),
					offsetz:32,
					data:spawnpos
				);
				actor aaa=spawn(thingy,spawnpos.hitlocation-spawnpos.hitdir,ALLOW_REPLACE);
				if(aaa)aaa.setz(aaa.floorz);
			}
		}stop;
	}
}


class HDGoreBits2:RandomSpawner replaces HDGoreBits{
	default{
		dropitem "DeadDemon",126,1;
		dropitem "DeadDoomImp",126,1;
		dropitem "DeadZombieMan",96,1;
		dropitem "DeadShotgunGuy",96,1;
		dropitem "DeadRifleman",96,1;
		dropitem "ReallyDeadRifleman",46,1;
		dropitem "ColonGibs",256,4;
		dropitem "Gibs",256,6;
		dropitem "SmallBloodPool",256,8;
		dropitem "BarrelGibs",256,8;
		dropitem "HDCasingBits",256,32;
		dropitem "HDFumbledShell",256,8;
		dropitem "HDSMGEmptyMag",256,3;
		dropitem "HDPistolEmptyMag",256,3;
		dropitem "LiberatorEmptyMag",96,1;
		dropitem "HD4mmMagEmpty",256,8;
		dropitem "GibMonster",256,2;
		dropitem "Withered",256,1;
		dropitem "EvilSprite",256,1;
	}
}

class DoggySpawner:RandomSpawner replaces ZombieHideousTrooper{
	default{
		dropitem "ZombieStormtrooper",256,99;
		dropitem "EnemyHERP",256,1;
		dropitem "Doggy",256,1;
	}
}