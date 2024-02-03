// ------------------------------------------------------------
// EvilSprite
// ------------------------------------------------------------
class EvilSprite:HDMobBase{
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Sprite"
		//$Sprite "FRITA0"

		monster; +nogravity +float +floatbob
		+avoidmelee +lookallaround
		+pushable +dontfall +cannotpush +thruspecies
		+hdmobbase.doesntbleed
		-telestomp -solid
		species "BaronOfHell";
		tag "evilsprite";
		damagefactor "Thermal", 1.2;
		damagefactor "Balefire", 0.1;
		health 35;
		radius 11;
		height 32;
		scale 0.333;
		speed 4;
		mass 33;
		painchance 120;
		obituary "%o got their teeth stolen";
		seesound "EvilSprite/see";
		painsound "EvilSprite/pain";
		deathsound "putto/death";
		//translation 0;
	}
	states{
	spawn:
		FRIT A 0; /*nodelay{
			if(Wads.CheckNumForName("BOSFA0",wads.ns_sprites,-1,false)<0)
				sprite=getspriteindex("PINVA0");
		}*/
	spawn2:
		#### ABCD 6 A_Look();
		loop;
	see:
		#### A 0{
			if(!random(0,16))vel.z+=frandom(-4,4);
		}
		#### ABCD 4{hdmobai.chase(self);}
		loop;
	missile:
		#### EEF 5;
		#### F 1 A_StartSound("putto/spit",CHAN_WEAPON);
		#### G 1 A_SpawnProjectile("SpriteBall",16);
		#### G 5;
		#### ABCD 2;
		#### ABCD 3;
		---- A 0 setstatelabel("see");
	pain:
		#### DAB 1;
		#### C 1 A_Recoil(4);
		#### D 1 A_Pain;
		#### ABCD 2 A_FastChase();
		#### ABCD 3;
		goto missile;
	Death:
		#### AABB 1 A_SpawnItemEx(
			"HDSmoke", random(-2,2),random(-2,2),random(4,8),
			vel.x,vel.y,vel.z+2, flags:SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
		);
		TNT1 A 1{
			A_SpawnItemEx("HDExplosion",0,0,3,
				vel.x,vel.y,vel.z+1,0,
				SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
			);
			A_Scream();
			A_NoBlocking();
			if(master)master.stamina--;
		}
		TNT1 AA 1 A_SpawnItemEx("HDSmokeChunk",0,0,3,
			vel.x+frandom(-4,4),vel.y+frandom(-4,4),vel.z+frandom(1,6),
			0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
		);
		stop;
	}
}

class SpriteBall:HDImpBall{
	default{
		missiletype "ArdentipedeBallTail";
		speed 6;
		scale 0.4;
	}
/*	override void A_HDIBFly(){
		roll=frandom(0,360);
		if(tracer){
			vel*=0.86;
			if(!A_FBSeek(512))vel+=(frandom(-1,1),frandom(-1,1),frandom(-1,1));
		}
	}*/
	states{
	spawn:
		COMT ABC 2;
		loop;
	death:
		TNT1 AAA 0 A_SpawnItemEx("HDSmoke",flags:SXF_NOCHECKPOSITION);
		TNT1 A 0 {if(blockingmobj)A_Immolate(blockingmobj,target,40);}
		COMT DEFGHI 1 A_SpawnItemEx("HDSmoke",flags:SXF_NOCHECKPOSITION);
		goto super::death;
	}
}