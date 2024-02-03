// ------------------------------------------------------------
// Withered
// ------------------------------------------------------------

class Withered:HDMobBase{
	default{
		//$Category "Monsters/Hideous Destructor"
		//$Title "Withered"
		//$Sprite "ZFODF1"

		mass 75;
		+floorclip
		SeeSound "ZombieFodder/sight";
		PainSound "ZombieFodder/pain";
		DeathSound "ZombieFodder/death";
		ActiveSound "ZombieFodder/active";
		meleesound "imp/melee";
		hdmobbase.downedframe 12;
		Health 10;
		gibhealth 50;
		Radius 14;
		Height 56;
		deathheight 15;
		Speed 12;
		Damage 4;
		MeleeDamage 4;
		PainChance 80;
		hitobituary "%o brain got eaten by Zombie.";
	}
	override void postbeginplay(){
		super.postbeginplay();
		hdmobster.spawnmobster(self);
		if(bplayingid){
			bsmallhead=true;
			bbiped=true;
			A_SetSize(13,54);
		}
		resize(0.8,1.1);
	}
	virtual void A_ImpChase(){
		hdmobai.chase(self);
	}
	override void deathdrop(){
		if(!bfriendly)A_DropItem("HDSpent7mmSpawner", -1, 40);
		
		//if(!bfriendly)A_DropItem("HDHandgunRandomDrop");
	}
	states{
	spawn2:
		#### ABCD 4{
			A_Wander();
			A_Look();
		}
		#### A 0 A_Jump(198,"spawn2");
		#### A 0 A_Recoil(-0.4);
		#### A 0 A_Jump(64,"spawn0");
		loop;
	spawn:
		ZFOD A 0;
	spawn0:
		#### AAABBCCCDD 8 A_Look();
		#### A 0 A_SetAngle(angle+random(-4,4));
		#### A 1 A_SetTics(random(1,3));
		---- A 0 A_Jump(216,2);
		---- A 0 A_StartSound(activesound,CHAN_VOICE);
		#### A 0 A_JumpIf(bambush,"spawn0");
		#### A 0 A_Jump(32,"spawn2");
		loop;
	see:
		#### ABCD 4 A_ImpChase();
		---- A 0 A_Jump(180,"see");
		---- A 0 A_AlertMonsters();
		loop;
	missile:
		goto see;
/*		#### ABCD 4{
			A_FaceTarget(40,40);
			if(A_JumpIfTargetInLOS("null",40))setstatelabel("missile0");
			else if(!A_JumpIfTargetInLOS("null"))setstatelabel("see");
		}loop;
	missile0:
		---- A 0 A_JumpIfTargetInLOS(2);
		---- A 0 A_Jump(256,"spam");
		#### E 0{
			bNODROPOFF=true;
			A_ChangeVelocity(1,random(-1,1)*random(0,3),0,CVF_RELATIVE);
		}
		#### E 0 A_Jump(16,"hork");
		goto lead;
		#### E 0 A_JumpIfCloser(512,"lead");
		goto hork;

	lead:
		#### E 6 A_FaceTarget(40,40);
		#### E 1{
			A_FaceTarget(20,40);
			leadaim1=(angle,pitch);
		}
		#### E 0{
			if(!target)return;
			A_FaceTarget(20,40);
			leadaim2=(angle,pitch);
			leadaim1=(deltaangle(leadaim1.x,leadaim2.x),deltaangle(leadaim2.y,leadaim1.y));

			double dist=min(distance3d(target),512);
			leadaim1*=frandom(0,dist/7); //less than average speed of ball
			leadaim1.x=clamp(leadaim1.x,-30,30);
			leadaim1.y=clamp(leadaim1.y,-12,10);

			angle+=leadaim1.x;
			pitch+=leadaim1.y;
		}
		#### F 4;
		#### G 8 A_SpawnProjectile("HDImpBall",34,0,0,CMF_AIMDIRECTION,pitch);
		#### F 0 A_ChangeVelocity(frandom(-1,1),frandom(-3,3),0,CVF_RELATIVE);
		#### F 6;
		---- A 0 A_JumpIfTargetInsideMeleeRange("melee");
		#### E 0 A_JumpIf(!hdmobai.TryShoot(self,32,256,10,10),"see");
		#### E 0 A_Jump(16,"see");
		#### E 0 A_Jump(40,"spam","hork");
		goto missile;

	spam:
		---- A 0 A_JumpIfTargetInLOS(2);
		---- A 0 A_Jump(256,3);
		#### DD 2 A_FaceTarget(12,24);
		#### E 5 A_SetTics(random(4,6));
		#### E 0 A_JumpIfTargetInLOS(1);
		goto spam2;
		#### E 2 A_FaceTarget(12,24);
	spam2:
		#### F 2;
		#### G 6 A_SpawnProjectile("HDImpBall",35,0,frandom(-5,7),CMF_AIMDIRECTION,pitch+random(-4,4));
		#### F 4;
		#### F 0 A_JumpIfTargetInLOS("spam3");
		#### F 0 A_Jump(256,"coverfire");
	spam3:
		---- A 0 A_Jump(120,"missile");
		---- A 0 A_Jump(256,"see");
	coverfire:
		---- A 0 A_JumpIfTargetInsideMeleeRange("melee");
		#### E random(2,7)A_JumpIfTargetInLOS("Missile");
		---- A 0 A_Jump(180,"missile1a");
		---- A 0 A_Jump(40,"hork");
		---- A 0 A_Jump(40,"see");
		---- A 0 A_Jump(80,1);
		loop;
		#### AABBCCDD 2 A_ImpChase();
		---- A 0 A_Jump(256,"missile");
	hork:
		#### E 0 A_Jump(156,"spam");
		---- A 0 A_JumpIfTargetInLOS(2);
		---- A 0 A_Jump(256,2);
		---- A 0 A_FaceTarget(40,80);
		#### E 2;
		#### E 0 A_StartSound(seesound,CHAN_VOICE);
		#### EEEEE 2 A_SpawnItemEx("ReverseImpBallTail",4,24,random(31,33),1,0,0,0,160);
		#### E 2;
		#### F 2;
		#### G 0 A_SpawnProjectile("HDImpBall",36,0,(frandom(-2,10)),CMF_AIMDIRECTION,pitch+frandom(-4,4));
		#### G 0 A_SpawnProjectile("HDImpBall",36,0,(frandom(-4,4)),CMF_AIMDIRECTION,pitch+frandom(-4,4));
		#### G 0 A_SpawnProjectile("HDImpBall",36,0,(frandom(-2,-10)),CMF_AIMDIRECTION,pitch+frandom(-4,4));
		#### GGFE 5 A_SetTics(random(4,6));
		#### E 0 A_JumpIf(!hdmobai.TryShoot(self,32,256,10,10),"see");
		---- A 0 A_Jump(256,"spam");*/
	melee:
		#### EE 4 A_FaceTarget();
		#### F 2;
		#### G 8 A_CustomMeleeAttack(random(10,30),meleesound,"","claws",true);
		#### F 4;
		---- A 0 setstatelabel("see");
	pain:
		---- A 0 A_GiveInventory("HDFireEnder",3);
		#### H 3 {bNODROPOFF=true;}
		#### H 3 A_Pain();
		---- A 0 A_Jump(180,2);
		---- A 0 A_AlertMonsters();
		#### A 2 A_FaceTarget();
		#### BCD 2 A_FastChase();
		goto missile;
	death:
		#### I 6 A_Gravity();
		#### J 6 A_Scream();
		#### KL 5;
	dead:
	death.spawndead:
		#### L 3 canraise A_JumpIf(abs(vel.z)<2,1);
		loop;
		#### M 5 canraise A_JumpIf(abs(vel.z)>=2,"Dead");
		loop;
	xxxdeath:
		#### N 0 A_SpawnItemEx("MegaBloodSplatter",0,0,34,0,0,0,0,160);
		#### O 5 A_XScream();
		#### PQRS 5;
		#### T 5;
		goto xdead;
	xdeath:
		---- A 0 A_Gravity();
		#### N 0 A_SpawnItemEx("MegaBloodSplatter",0,0,34,0,0,0,0,160);
		#### O 5 A_XScream();
		#### O 0 A_SpawnItemEx("MegaBloodSplatter",0,0,34,0,0,0,0,160);
		#### P 5 A_SpawnItemEx("MegaBloodSplatter",0,0,34,0,0,0,0,160);
		#### QRS 5;
		#### T 5;
	xdead:
		#### T 5 canraise A_JumpIf(abs(vel.z)<2,1);
		wait;
		#### U 5 canraise A_JumpIf(abs(vel.z)>=2,"XDead");
		wait;
	raise:
		#### M 4;
		#### ML 6;
		#### KJI 4;
		goto checkraise;
	ungib:
		#### U 6;
		#### UT 8;
		#### SRQ 6;
		#### PONH 4;
		goto checkraise;
	falldown:
		#### H 5;
		#### I 5 A_Scream();
		#### JJKKL 2 A_SetSize(-1,max(deathheight,height-10));
		#### L 2 A_SetSize(-1,deathheight);
		#### M 10 A_KnockedDown();
		wait;
	standup:
		#### LK 5;
		#### J 0 A_Jump(64,2);
		#### J 0 A_StartSound(seesound,CHAN_VOICE);
		#### JI 4 A_Recoil(-0.3);
		#### HE 5;
		#### A 0 A_Jump(256,"see");
	}
}

class HDSpent7mmSpawner : Actor
{
	Default
	{
	}
	States
	{
	Spawn:
		ZFOD AAAAAAAAA 0 A_DropItem("HDSpent7mm", -1, 200);
		stop;
	}
}