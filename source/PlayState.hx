package;

import Song.Event;
import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if windows
import Discord.DiscordClient;
#end
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	public static var troll:Character;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it
	public var healthFactor:Float = 0.05;

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 4; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	
	var fog:FlxSprite;
	var cloud:FlxSprite;
	var thunder:FlxSprite;
	var rainFrontA:FlxSprite;
	var rainFrontB:FlxSprite;
	var rainBackA:FlxSprite;
	var rainBackB:FlxSprite;
	var heartbeat:FlxSprite;
	var hue:FlxSprite;
	var streetBackO:FlxSprite;
	var streetO:FlxSprite;
	var jumpIn:FlxSprite;
	
	var factoryBackA:FlxSprite;
	var factoryA:FlxSprite;
	var barA:FlxSprite;
	var chainA:FlxSprite;
	
	var factoryBackB:FlxSprite;
	var factoryB:FlxSprite;
	var barB:FlxSprite;
	var chainB:FlxSprite;
	
	var factoryTransitionBack:FlxSprite;
	var factoryTransition:FlxSprite;
	var barTransition:FlxSprite;
	var chainTransition:FlxSprite;
	
	var factoryBackC:FlxSprite;
	var factoryC:FlxSprite;
	var barC:FlxSprite;
	var chainC:FlxSprite;
	
	var staticScreen:FlxSprite;
	var fadeIn:FlxSprite;
	var sign:FlxSprite;
	var forest:FlxSprite;
	var fireSpark:FlxSprite;
	
	var moveAmount:Array<Int> = [0, 0, 0, 0];
	var moveAmountMemory:Array<Int> = [0, 0, 0, 0];
	var moveTimer:Array<Float> = [0, 0, 0, 0];
	var moveVelocity:Array<Int> = [2, 2, 2, 2];
	
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;
	
	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{

		FlxG.mouse.visible = false;
		instance = this;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		removedVideo = false;

		#if windows
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode) detailsText = "Story Mode: Week " + storyWeek;
		else detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null) SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null) SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
	

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
                var beat:Float = pos;

                var endBeat:Float = Math.POSITIVE_INFINITY;

                TimingStruct.addTiming(beat,value,endBeat, 0); // offset in this case = start time since we don't have a offset
				
                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = beat;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// dialogue shit
		switch (songLowercase)
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2: stageCheck = 'halloween';
				case 3: stageCheck = 'philly';
				case 4: stageCheck = 'limo';
				case 5:
					if (songLowercase == 'winter-horrorland') stageCheck = 'mallEvil';
					else stageCheck = 'mall';
				case 6:
					if (songLowercase == 'thorns') stageCheck = 'schoolEvil';
					else stageCheck = 'school';
					// i should check if its stage (but this is when none is found in chart anyway)
			}
		}
		else stageCheck = SONG.stage;

		if (!PlayStateChangeables.Optimize)
		{
			switch (stageCheck)
			{
				case 'halloween':
				{
					curStage = 'spooky';
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					if(FlxG.save.data.antialiasing) halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
				}
				case 'philly':
				{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions) add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						if(FlxG.save.data.antialiasing) light.antialiasing = true;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					if (FlxG.save.data.distractions) add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
					FlxG.sound.list.add(trainSound);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					add(street);
				}
				case 'limo':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);
					if (FlxG.save.data.distractions)
					{
						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						add(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					if(FlxG.save.data.antialiasing) limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
				}
				case 'mall':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					if(FlxG.save.data.antialiasing) bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					if(FlxG.save.data.antialiasing) upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (FlxG.save.data.distractions) add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					if(FlxG.save.data.antialiasing) bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					if(FlxG.save.data.antialiasing) tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					if(FlxG.save.data.antialiasing) bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (FlxG.save.data.distractions) add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					if(FlxG.save.data.antialiasing) fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					if(FlxG.save.data.antialiasing) santa.antialiasing = true;
					if (FlxG.save.data.distractions) add(santa);
				}
				case 'mallEvil':
				{
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					if(FlxG.save.data.antialiasing) bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					if(FlxG.save.data.antialiasing) evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					if(FlxG.save.data.antialiasing) evilSnow.antialiasing = true;
					add(evilSnow);
				}
				case 'school':
				{
					curStage = 'school';

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (songLowercase == 'roses' && FlxG.save.data.distractions) bgGirls.getScared();

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					if (FlxG.save.data.distractions) add(bgGirls);
				}
				case 'schoolEvil':
				{
					curStage = 'schoolEvil';

					if (!PlayStateChangeables.Optimize)
					{
						var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
						var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
					}

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
				case 'street-sunny':
				{
					defaultCamZoom = 0.7;
					curStage = 'street-sunny';
					
					var streetBack:FlxSprite = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/streetBack-A', 'trollge'));
					streetBack.setGraphicSize(Std.int(streetBack.width * 1.1));
					streetBack.antialiasing = true;
					streetBack.active = false;
					add(streetBack);
		
					var street:FlxSprite = new FlxSprite(-575, -285).loadGraphic(Paths.image('background/street-A', 'trollge'));
					street.antialiasing = true;
					street.active = false;
					add(street);
				}
				case 'street-abandon':
				{
					defaultCamZoom = 0.7;
					curStage = 'street-abandon';
					var streetBack:FlxSprite = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/streetBack-A', 'trollge'));
					streetBack.setGraphicSize(Std.int(streetBack.width * 1.1));
					streetBack.antialiasing = true;
					streetBack.active = false;
					add(streetBack);
					
					var cloudTex = Paths.getSparrowAtlas('background/cloud', 'trollge');
					cloud = new FlxSprite(-575, -650);
					cloud.frames = cloudTex;
					cloud.animation.addByPrefix('cloud', 'Fog', 24, true);
					cloud.animation.play('cloud');
					cloud.antialiasing = true;
					add(cloud);
		
					var street:FlxSprite = new FlxSprite(-575, -285).loadGraphic(Paths.image('background/street-A', 'trollge'));
					street.antialiasing = true;
					street.active = false;
					add(street);
				}
				case 'street-rain':
				{
					defaultCamZoom = 0.7;
					curStage = 'street-rain';
					var streetBack:FlxSprite = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/streetBack-B2', 'trollge'));
					streetBack.setGraphicSize(Std.int(streetBack.width * 1.1));
					streetBack.antialiasing = true;
					streetBack.active = false;
					add(streetBack);
					
					streetBackO = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/streetBack-B', 'trollge'));
					streetBackO.setGraphicSize(Std.int(streetBackO.width * 1.1));
					streetBackO.antialiasing = true;
					streetBackO.active = false;
					add(streetBackO);
					
					var rainTex = Paths.getSparrowAtlas('background/rain', 'trollge');
					rainBackA = new FlxSprite(1060, 270);
					rainBackA.frames = rainTex;
					rainBackA.animation.addByPrefix('rain', 'Rain', 24, true);
					rainBackA.setGraphicSize(Std.int(rainBackA.width * 2));
					rainBackA.blend = LIGHTEN;
					rainBackA.antialiasing = true;
					add(rainBackA);
							
					rainBackB = new FlxSprite(1080, 270);
					rainBackB.frames = rainTex;
					rainBackB.animation.addByPrefix('rain', 'Rain', 24, true);
					rainBackB.setGraphicSize(Std.int(rainBackB.width * 2));
					rainBackB.blend = LIGHTEN;
					rainBackB.antialiasing = true;
					add(rainBackB);

					var cloudTex = Paths.getSparrowAtlas('background/cloud', 'trollge');
					cloud = new FlxSprite(-575, -650);
					cloud.frames = cloudTex;
					cloud.animation.addByPrefix('cloud', 'Fog', 24, true);
					cloud.animation.play('cloud');
					cloud.antialiasing = true;
					add(cloud);
		
					var street:FlxSprite = new FlxSprite(-575, -285).loadGraphic(Paths.image('background/street-B2', 'trollge'));
					street.antialiasing = true;
					street.active = false;
					add(street);
					
					streetO = new FlxSprite(-575, -285).loadGraphic(Paths.image('background/street-B', 'trollge'));
					streetO.antialiasing = true;
					add(streetO);
				}
				case 'street-unused':
				{
					defaultCamZoom = 0.7;
					curStage = 'street-unused';
					var streetBack:FlxSprite = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/streetBack-B', 'trollge'));
					streetBack.setGraphicSize(Std.int(streetBack.width * 1.1));
					streetBack.antialiasing = true;
					streetBack.active = false;
					add(streetBack);
					
					var cloudTex = Paths.getSparrowAtlas('background/cloud', 'trollge');
					cloud = new FlxSprite(-575, -280);
					cloud.frames = cloudTex;
					cloud.animation.addByPrefix('cloud', 'Fog', 24, true);
					cloud.animation.play('cloud');
					cloud.antialiasing = true;
					add(cloud);
		
					var street:FlxSprite = new FlxSprite(-575, -285).loadGraphic(Paths.image('background/street-B', 'trollge'));
					street.antialiasing = true;
					street.active = false;
					add(street);
				}
				case 'void':
				{
					defaultCamZoom = 0.6;
					curStage = 'void';
					
					forest = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/tree', 'trollge'));
					forest.setGraphicSize(Std.int(forest.width * 1.75));
					forest.antialiasing = true;
					forest.active = false;
					forest.visible = false;
					forest.alpha = 0;
					add(forest);
					
					factoryBackC = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/factoryBackC', 'trollge'));
					factoryBackC.setGraphicSize(Std.int(factoryBackC.width * 1.75));
					factoryBackC.antialiasing = true;
					factoryBackC.active = false;
					factoryBackC.visible = false;
					add(factoryBackC);
					
					var staticTex = Paths.getSparrowAtlas('background/Satics', 'trollge');
					staticScreen = new FlxSprite( -575, -235);
					staticScreen.frames = staticTex;
					staticScreen.animation.addByPrefix('static', 'Static', 24, true);
					staticScreen.setGraphicSize(Std.int(staticScreen.width * 3));
					staticScreen.screenCenter();
					staticScreen.alpha = 0;
					staticScreen.active = false;
					staticScreen.visible = false;
					add(staticScreen);
		
					factoryC = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/factoryC', 'trollge'));
					factoryC.setGraphicSize(Std.int(factoryC.width * 1.75));
					factoryC.antialiasing = true;
					factoryC.active = false;
					factoryC.visible = false;
					add(factoryC);
					
					var FTBTex = Paths.getSparrowAtlas('background/factoryBackTran', 'trollge');
					factoryTransitionBack = new FlxSprite( -175, -35);
					factoryTransitionBack.frames = FTBTex;
					factoryTransitionBack.animation.addByPrefix('transition', 'Transition', 24, false);
					factoryTransitionBack.setGraphicSize(Std.int(factoryTransitionBack.width * 3.5));
					factoryTransitionBack.antialiasing = true;
					factoryTransitionBack.active = false;
					factoryTransitionBack.visible = false;
					factoryTransitionBack.setGraphicSize(Std.int(factoryTransitionBack.width * 1.75));
					factoryTransitionBack.animation.finishCallback = function(name:String) {
						factoryTransitionBack.active = false; 
						factoryBackC.visible = true;
						staticScreen.active = true;
						staticScreen.visible = true;
						staticScreen.animation.play('static', true);
						FlxTween.tween(staticScreen, { alpha:0.2 }, 1.5);
						remove(factoryTransitionBack);
					}
					add(factoryTransitionBack);
					
					var FTTex = Paths.getSparrowAtlas('background/factoryTran', 'trollge');
					factoryTransition = new FlxSprite( -175, -35);
					factoryTransition.frames = FTTex;
					factoryTransition.animation.addByPrefix('transition', 'Transition', 24, false);
					factoryTransition.setGraphicSize(Std.int(factoryTransition.width * 3.5));
					factoryTransition.antialiasing = true;
					factoryTransition.active = false;
					factoryTransition.visible = false;
					factoryTransition.animation.finishCallback = function(name:String) {
						factoryTransition.active = false; 
						factoryC.visible = true;
						remove(factoryTransition);
					}
					add(factoryTransition);
					
					factoryBackB = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/factoryBackB', 'trollge'));
					factoryBackB.setGraphicSize(Std.int(factoryBackB.width * 1.75));
					factoryBackB.antialiasing = true;
					factoryBackB.active = false;
					factoryBackB.visible = false;
					add(factoryBackB);
					
					var cloudTex = Paths.getSparrowAtlas('background/fogRED', 'trollge');
					cloud = new FlxSprite(-575, -650);
					cloud.frames = cloudTex;
					cloud.animation.addByPrefix('cloud', 'Fog', 24, true);
					cloud.setGraphicSize(Std.int(cloud.width * 2));
					cloud.animation.play('cloud');
					cloud.visible = false;
					cloud.antialiasing = true;
					add(cloud);
		
					factoryB = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/factoryB', 'trollge'));
					factoryB.setGraphicSize(Std.int(factoryB.width * 1.75));
					factoryB.antialiasing = true;
					factoryB.active = false;
					factoryB.visible = false;
					add(factoryB);
					
					factoryBackA = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/factoryBackA', 'trollge'));
					factoryBackA.setGraphicSize(Std.int(factoryBackA.width * 1.75));
					factoryBackA.antialiasing = true;
					factoryBackA.active = false;
					add(factoryBackA);
		
					factoryA = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/factoryA', 'trollge'));
					factoryA.setGraphicSize(Std.int(factoryA.width * 1.75));
					factoryA.antialiasing = true;
					factoryA.active = false;
					add(factoryA);
				}
				default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					if(FlxG.save.data.antialiasing) bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					if(FlxG.save.data.antialiasing) stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					if(FlxG.save.data.antialiasing) stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
					add(stageCurtains);
				}
			}
		}
		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';
		var curGf:String = '';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4: gfCheck = 'gf-car';
				case 5: gfCheck = 'gf-christmas';
				case 6: gfCheck = 'gf-pixel';
			}
		}
		else gfCheck = SONG.gfVersion;

		switch (gfCheck)
		{
			case 'gf-car': curGf = 'gf-car';
			case 'gf-christmas': curGf = 'gf-christmas';
			case 'gf-pixel': curGf = 'gf-pixel';
			default: curGf = 'gf';
		}

		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		
		//setup trollgeRGB
		if (curStage == 'void')
		{
			troll =  new Character(100, 100, 'trollge_RGB');
			troll.alpha = 0.6;
			troll.visible = false;
			troll.x -= 224;
			troll.y -= 120;
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky": 
				dad.y += 200;
			case "monster": 
				dad.y += 100;
			case 'monster-christmas': 
				dad.y += 130;
			case 'dad': 
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				if (FlxG.save.data.distractions)
				{
					if (!PlayStateChangeables.Optimize)
					{
						var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
						add(evilTrail);
					}
				}
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'trollge01':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge01dark':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge02':
				dad.x -= 124;
				dad.y -= 30;
			case 'trollge02_soaked':
				dad.x -= 124;
				dad.y -= 30;
			case 'trollge02s':
				dad.x -= 124;
				dad.y -= 30;
			case 'trollge03':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge_glitch':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge_eye':
				dad.x -= 124;
				dad.y -= 20;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if (FlxG.save.data.distractions)
				{
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'street-sunny':
				gf.y -= 25;
			case 'street-rain':
				gf.y -= 25;
			case 'street-abandon':
				gf.y -= 25;
			case 'street-unused':
				gf.y -= 25;
		}

		if (!PlayStateChangeables.Optimize)
		{
			if (curStage != 'void') add(gf);
			else add(troll);

			// Shitty layering but whatev it works LOL
			if (curStage == 'limo') add(limo);

			add(dad);
			add(boyfriend);
		}

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		// startCountdown();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty)
			+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep) add(replayTxt);
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if (PlayStateChangeables.botPlay && !loadRep) add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		
		if (curStage == 'street-rain' || curStage == 'street-unused' || curStage == 'void')
		{
			LoadOil();
		}

		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep) replayTxt.cameras = [camHUD];
			
		startingSong = true;

		trace('starting');
		
		if (curStage == 'street-sunny')
		{
			hue = new FlxSprite().loadGraphic(Paths.image('background/mischiefHue', 'trollge'));
			hue.screenCenter();
			hue.scrollFactor.set();
			hue.alpha = 0;
			hue.setGraphicSize(Std.int(hue.width * 1920));
			add(hue);
		}
		
		if (curStage == 'street-rain')
		{
			var rainTex = Paths.getSparrowAtlas('background/rain', 'trollge');
			
			rainFrontA = new FlxSprite(1060, 540);
			rainFrontA.frames = rainTex;
			rainFrontA.animation.addByPrefix('rain', 'Rain', 24, true);
			rainFrontA.setGraphicSize(Std.int(rainFrontA.width * 2.5));
			rainFrontA.blend = LIGHTEN;
			rainFrontA.antialiasing = true;
			add(rainFrontA);

			rainFrontB = new FlxSprite(1080, 540);
			rainFrontB.frames = rainTex;
			rainFrontB.animation.addByPrefix('rain', 'Rain', 24, true);
			rainFrontB.setGraphicSize(Std.int(rainFrontB.width * 2.5));
			rainFrontB.blend = LIGHTEN;
			rainFrontB.antialiasing = true;
			add(rainFrontB);
				
			var fogTex = Paths.getSparrowAtlas('background/fog', 'trollge');
			fog = new FlxSprite(0, -200);
			fog.frames = fogTex;
			fog.animation.addByPrefix('fog', 'Fog', 12, false);
			fog.animation.play('fog', true, false, 2560);
			fog.antialiasing = true;
			fog.setGraphicSize(Std.int(fog.width * 2));
			fog.flipX = true;
			add(fog);
			
			var thunderTex = Paths.getSparrowAtlas('background/thunder', 'trollge');
			thunder = new FlxSprite(1080, 540);
			thunder.frames = thunderTex;
			thunder.animation.addByPrefix('thunder', 'Thunder', 48, false);
			thunder.antialiasing = true;
			thunder.scrollFactor.set();
			thunder.alpha = 0;
			thunder.setGraphicSize(Std.int(thunder.width * 2.5));
			thunder.animation.finishCallback = function(name:String) {FlxTween.tween(thunder, { alpha:0 }, 1.5);}
			add(thunder);
			
			hue = new FlxSprite().loadGraphic(Paths.image('background/ominousHue', 'trollge'));
			hue.screenCenter();
			hue.scrollFactor.set();
			hue.alpha = 0;
			hue.setGraphicSize(Std.int(hue.width * 1920));
			add(hue);
			
			var jumpTex = Paths.getSparrowAtlas('background/jumpscare', 'trollge');
			jumpIn = new FlxSprite();
			jumpIn.frames = jumpTex;
			jumpIn.animation.addByPrefix('jump', 'Jump', 36, false);
			jumpIn.screenCenter();
			jumpIn.scrollFactor.set();
			jumpIn.setGraphicSize(Std.int(jumpIn.width * 2));
			jumpIn.alpha = 0;
			jumpIn.antialiasing = true;
			jumpIn.cameras = [camHUD];
			jumpIn.animation.finishCallback = function(name:String) {
				healthFactor = 0.01;
				climax = true;
				remove(streetO);
				remove(streetBackO);
				remove(thunder);
				remove(jumpIn);
			}
			add(jumpIn);
		}
		
		if (curStage == 'void')
		{
			sign = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/sign', 'trollge'));
			sign.setGraphicSize(Std.int(sign.width * 1.75));
			sign.alpha = 0;
			sign.antialiasing = true;
			sign.active = false;
			sign.visible = false;
			add(sign);
			
			LoadBlob();
			LoadEye();
			
			barC = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/barC', 'trollge'));
			barC.setGraphicSize(Std.int(barC.width * 1.75));
			barC.antialiasing = true;
			barC.active = false;
			barC.visible = false;
			barC.scrollFactor.set( 0.7, 0.7);
			add(barC);
			
			var ChainCTex = Paths.getSparrowAtlas('background/chainC', 'trollge');
			chainC = new FlxSprite( -575, -235);
			chainC.frames = ChainCTex;
			chainC.animation.addByPrefix('static', 'Static', 24, true);
			chainC.setGraphicSize(Std.int(chainC.width * 1.75));
			chainC.antialiasing = true;
			chainC.active = false;
			chainC.visible = false;
			chainC.scrollFactor.set( 0.75, 0.75);
			add(chainC);
			
			var BarTex = Paths.getSparrowAtlas('background/barTran', 'trollge');
			barTransition = new FlxSprite( -575, -235);
			barTransition.frames = BarTex;
			barTransition.animation.addByPrefix('transition', 'Transition', 24, false);
			barTransition.setGraphicSize(Std.int(barTransition.width * 1.75));
			barTransition.antialiasing = true;
			barTransition.active = false;
			barTransition.visible = false;
			barTransition.scrollFactor.set( 0.7, 0.7);
			barTransition.animation.finishCallback = function(name:String) {
				barTransition.active = false;
				barC.visible = true;
				remove(barTransition);
			}
			add(barTransition);
			
			var ChainTex = Paths.getSparrowAtlas('background/chainTran', 'trollge');
			chainTransition = new FlxSprite( -575, -235);
			chainTransition.frames = ChainTex;
			chainTransition.animation.addByPrefix('transition', 'Transition', 24, false);
			chainTransition.setGraphicSize(Std.int(chainTransition.width * 1.75));
			chainTransition.antialiasing = true;
			chainTransition.active = false;
			chainTransition.visible = false;
			chainTransition.scrollFactor.set( 0.75, 0.75);
			chainTransition.animation.finishCallback = function(name:String) {
				chainTransition.active = false; 
				chainC.active = true;
				chainC.visible = true;
				chainC.animation.play('static', true);
				remove(chainTransition);
			}
			add(chainTransition);
			
			barB = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/barB', 'trollge'));
			barB.setGraphicSize(Std.int(barB.width * 1.75));
			barB.antialiasing = true;
			barB.active = false;
			barB.visible = false;
			barB.scrollFactor.set( 0.7, 0.7);
			add(barB);
			
			chainB = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/chainB', 'trollge'));
			chainB.setGraphicSize(Std.int(chainB.width * 1.75));
			chainB.antialiasing = true;
			chainB.active = false;
			chainB.visible = false;
			chainB.scrollFactor.set( 0.75, 0.75);
			add(chainB);
				
			barA = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/barA', 'trollge'));
			barA.setGraphicSize(Std.int(barA.width * 1.75));
			barA.antialiasing = true;
			barA.active = false;
			barA.scrollFactor.set( 0.7, 0.7);
			add(barA);
			
			chainA = new FlxSprite( -575, -235).loadGraphic(Paths.image('background/chainA', 'trollge'));
			chainA.setGraphicSize(Std.int(chainA.width * 1.75));
			chainA.antialiasing = true;
			chainA.active = false;
			chainA.scrollFactor.set( 0.75, 0.75);
			add(chainA);
			
			var fogTex = Paths.getSparrowAtlas('background/fogRED', 'trollge');
			fog = new FlxSprite(0, -200);
			fog.frames = fogTex;
			fog.animation.addByPrefix('fog', 'Fog', 12, false);
			fog.animation.play('fog', true, false, 2560);
			fog.antialiasing = true;
			fog.visible = false;
			fog.setGraphicSize(Std.int(fog.width * 2));
			fog.flipX = true;
			add(fog);
			
			var sparkTex = Paths.getSparrowAtlas('background/sparks', 'trollge');
			fireSpark = new FlxSprite();
			fireSpark.frames = sparkTex;
			fireSpark.animation.addByPrefix('float', 'Float', 18, false);
			fireSpark.screenCenter();
			fireSpark.scrollFactor.set();
			fireSpark.setGraphicSize(Std.int(fireSpark.width * 2));
			fireSpark.alpha = 0;
			fireSpark.antialiasing = true;
			
			hue = new FlxSprite().loadGraphic(Paths.image('background/incidentHue', 'trollge'));
			hue.screenCenter();
			hue.scrollFactor.set();
			hue.alpha = 0;
			hue.setGraphicSize(Std.int(hue.width * 2560));
			add(hue);
			
			var jumpTex = Paths.getSparrowAtlas('background/screamer', 'trollge');
			jumpIn = new FlxSprite();
			jumpIn.frames = jumpTex;
			jumpIn.animation.addByPrefix('jump', 'scream', 36, false);
			jumpIn.screenCenter();
			jumpIn.scrollFactor.set();
			jumpIn.setGraphicSize(Std.int(jumpIn.width * 2));
			jumpIn.alpha = 0;
			jumpIn.antialiasing = true;
			jumpIn.cameras = [camHUD];
			jumpIn.animation.finishCallback = function(name:String) {
				remove(factoryBackA);
				remove(factoryA);
				remove(barA);
				remove(chainA);
				hue.alpha = 0.15;
				factoryBackB.visible = true;
				factoryB.visible = true;
				barB.visible = true;
				chainB.visible = true;
				cloud.visible = true;
				fog.visible = true;
				defaultCamZoom = 0.55;
				FlxTween.tween(jumpIn, { alpha:0 }, 0.1, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ remove(jumpIn); }});
			}
			add(jumpIn);
			
			fadeIn = new FlxSprite().loadGraphic(Paths.image('background/fadeIn', 'trollge'));
			fadeIn.screenCenter();
			fadeIn.scrollFactor.set();
			fadeIn.setGraphicSize(Std.int(hue.width * 2560));
			add(fadeIn);
		}
		
		if (curStage == 'street-rain' || curStage == 'street-sunny'|| curStage == 'void')
		{
			var heartTex = Paths.getSparrowAtlas('background/heartbeat', 'trollge');
			heartbeat = new FlxSprite();
			heartbeat.screenCenter();
			heartbeat.frames = heartTex;
			heartbeat.animation.addByPrefix('beat', 'Heart', 48, false);
			heartbeat.setGraphicSize(Std.int(heartbeat.width * 2));
			heartbeat.alpha = 0;
			heartbeat.antialiasing = true;
			heartbeat.scrollFactor.set();
			heartbeat.cameras = [camHUD];
			add(heartbeat);
		}
		
		LoadBlob();


		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
				{
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				}
				case 'senpai':
				{
					schoolIntro(doof);
				}
				case 'roses':
				{
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				}	
				case 'thorns':
				{
					schoolIntro(doof);
				}
				default:
					startCountdown();
			}
		}
		else
		{
			startCountdown();
		}

		if (!loadRep) rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'roses'
			|| StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
		{
			remove(black);

			if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	
	var luaWiggles:Array<WiggleEffect> = [];

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		appearStaticArrows();
		//generateStaticArrows(0);
		//generateStaticArrows(1);

		playerStrums.forEach(function(spr:FlxSprite) {
			trace(spr.y);
		});
		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		#if windows
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					trace(value + " - " + curStage);
					introAlts = introAssets.get(value);
					if (curStage.contains('school'))
						altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if (curStage == 'street-rain'|| curStage == 'street-unused')
						FlxG.sound.play(Paths.sound('3_sam'), 0.6);
					else if (curStage == 'void')
						FlxG.sound.play(Paths.sound('3_demon'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					
					if (curStage == 'street-rain'|| curStage == 'street-unused')
						FlxG.sound.play(Paths.sound('2_sam'), 1);
					else if (curStage == 'void')
						FlxG.sound.play(Paths.sound('2_demon'), 1);
					else
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
						
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					
					if (curStage == 'street-rain'|| curStage == 'street-unused')
						FlxG.sound.play(Paths.sound('1_sam'), 1);
					else if (curStage == 'void')
						FlxG.sound.play(Paths.sound('1_demon'), 1);
					else
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
						
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					
					if (curStage == 'street-rain'|| curStage == 'street-unused')
						FlxG.sound.play(Paths.sound('go_sam'), 1);
					else if (curStage == 'void')
						FlxG.sound.play(Paths.sound('go_demon'), 1);
					else
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.10;
		}
	}

	var songStarted = false;
	var ambiance:FlxSound;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
			
			if (curStage == 'street-rain' || curStage == 'street-unused')
				ambiance = FlxG.sound.load(Paths.sound('rain'), 1);
			else if (curStage == 'street-sunny' || curStage == 'street-abandon')
				ambiance = FlxG.sound.play(Paths.sound('wind'), 1);
			
			if (ambiance != null)
						ambiance.play();
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	var debugNum:Int = 0;
	var ArrowCounter:Int = 0;
	var ArrowCounts:Array<Int> = [];

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		var songPath = 'assets/data/' + songLowercase + '/';
		
		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		for (section in noteData)
		{
			ArrowCounter = 0;
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}
				
				var notetype:Int = Std.int(songNotes[3]);

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, notetype);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;
				ArrowCounter += 1;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, notetype);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			ArrowCounts.push(ArrowCounter);
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					if(FlxG.save.data.antialiasing)
						{
							babyArrow.antialiasing = true;
						}
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				//babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			if (ambiance != null)
				ambiance.pause();

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}
			if (ambiance != null)
			{
				ambiance.play();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;
	
	var SectionCounter:Int = 0;
	var SectionIdentifier:Int = 0;
	var healthtrack:Float = 1;
	var healthloss:Float;
	
	var noteDoClose:Array<Bool> = [true, true, true, true];
	var noteCloseTime:Array<Float> = [0, 0, 0, 0];
	var closeTime:Float = 0.25;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (blobInitialize && blobMenifest) blobOnScreen();
		if (eyeInitialize && eyeMenifest) eyeOnScreen();
		
		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();
	
			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;
	
					var endBeat:Float = Math.POSITIVE_INFINITY;
	
					TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}
	
					currentIndex++;
				}
			}
			updateFrame++;
		}
		else if (updateFrame != 5) updateFrame++;
	

		var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
	
		if (timingSeg != null)
		{
			var timingSegBpm = timingSeg.bpm;
	
			if (timingSegBpm != Conductor.bpm)
			{
				trace("BPM CHANGE to " + timingSegBpm);
				Conductor.changeBPM(timingSegBpm, false);
			}
		}

		var newScroll = PlayStateChangeables.scrollSpeed;

		for(i in SONG.eventObjects)
		{
			switch(i.type)
			{
				case "Scroll Speed Change":
					if (i.position < curDecimalBeat)
						newScroll = i.value;
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;
	
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (i in luaWiggles)
			{
				trace('wiggle le gaming');
				i.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2) health = 2;
		
		if (healthBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 2;
		}
		else if (healthBar.percent > 80)
		{
			iconP1.animation.curAnim.curFrame = 2;
			iconP2.animation.curAnim.curFrame = 1;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
		}

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		
		if (FlxG.keys.justPressed.TWO)  //Go 10 seconds into the future, credit: Shadow Mario#9396
		{
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition) 
					{
						daNote.active = false;
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime - 500 >= Conductor.songPosition) {
						break;
					}
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
			}
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom' | 'mom-car':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel) 
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
		
		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				if (PlayStateChangeables.useDownscroll)
				{
					if (moveAmount[daNote.noteData] > 0)
					{
						switch(daNote.noteData)
						{
							case 0: daNote.y -= moveVelocity[daNote.noteData];
							case 1:	daNote.y -= moveVelocity[daNote.noteData];
							case 2:	daNote.y -= moveVelocity[daNote.noteData];
							case 3:	daNote.y -= moveVelocity[daNote.noteData];
						}
					}
					else if ((Math.floor(moveTimer[daNote.noteData]) > 3) && (moveAmountMemory[daNote.noteData] > 0))
					{
						switch(daNote.noteData)
						{
							case 0: daNote.y += 2;
							case 1:	daNote.y += 2;
							case 2:	daNote.y += 2;
							case 3:	daNote.y += 2;
						}
					}
				}
				else
				{
					if (moveAmount[daNote.noteData] > 0)
					{
						switch(daNote.noteData)
						{
							case 0: daNote.y += moveVelocity[daNote.noteData];
							case 1:	daNote.y += moveVelocity[daNote.noteData];
							case 2:	daNote.y += moveVelocity[daNote.noteData];
							case 3:	daNote.y += moveVelocity[daNote.noteData];
						}
					}
					else if ((Math.floor(moveTimer[daNote.noteData]) > 3) && (moveAmountMemory[daNote.noteData] > 0))
					{
						switch(daNote.noteData)
						{
							case 0: daNote.y -= 2;
							case 1:	daNote.y -= 2;
							case 2:	daNote.y -= 2;
							case 3:	daNote.y -= 2;
						}
					}
				}
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					SectionCounter += 1;
					
					if (SectionCounter >= ArrowCounts[SectionIdentifier])
					{
						SectionIdentifier += 1;
						SectionCounter = 0;
					}
					
					healthtrack = health;
	
					if (daNote.ArrowType == 'normal' || daNote.ArrowType == 'magnetic')
					{
						if (daNote.isSustainNote) 
						{
							if (healthFactor != 0 && healthFactor > 0.02)
							{
								switch(storyDifficulty)
								{
									case 2: healthloss = 0.02 * 1 * ((Math.floor(accuracy) / 200 + 1/2));
									case 1: healthloss = 0.02 * 0.8 * ((Math.floor(accuracy) / 200 + 1/2));
									case 0: healthloss = 0.02 * 0.6 * ((Math.floor(accuracy) / 200 + 1/2));
								}
							}
							else if (healthFactor != 0)
							{
								switch(storyDifficulty)
								{
									case 2: healthloss = healthFactor * 1 * ((Math.floor(accuracy) / 200 + 1/2));
									case 1: healthloss = healthFactor * 0.8 * ((Math.floor(accuracy) / 200 + 1/2));
									case 0: healthloss = healthFactor * 0.6 * ((Math.floor(accuracy) / 200 + 1/2));
								}
							}
						}
						else
						{
							switch(storyDifficulty)
							{
								case 2: healthloss = 3 * ((healthFactor / Math.log(ArrowCounts[SectionIdentifier]))) * ((Math.floor(accuracy) / 200 + 1/2));
								case 1: healthloss = 2.6 * ((healthFactor / Math.log(ArrowCounts[SectionIdentifier]))) * ((Math.floor(accuracy) / 200 + 1/2));
								case 0: healthloss = 2.4 * ((healthFactor / Math.log(ArrowCounts[SectionIdentifier]))) * ((Math.floor(accuracy) / 200 + 1/2));
							}
						}

						if ((healthtrack - healthloss) <= 0) health = 0.005;
						else health -= healthloss;
					}

					if (SONG.song != 'Tutorial') camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) altAnim = '-alt';
					
					// Accessing the animation name directly to play it
					var singData:Int = Std.int(Math.abs(daNote.noteData));
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
					
					if (troll != null && troll.visible) troll.playAnim('sing' + dataSuffix[singData] + altAnim, true);

					if (FlxG.save.data.cpuStrums)
					{
						if (!daNote.isSustainNote)
						{
							noteCloseTime[daNote.noteData] = 0;
							noteDoClose[daNote.noteData] = false;
							cpuStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
						}
						else
						{
							noteCloseTime[daNote.noteData] = 0;
							noteDoClose[daNote.noteData] = false;
						}
					}

					#if windows
					if (luaModchart != null) luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
					#end

					dad.holdTimer = 0;

					if (SONG.needsVoices) vocals.volume = 1;

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (PlayState.curStage.startsWith('school'))
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate && PlayStateChangeables.useDownscroll) && (daNote.mustPress))
				{
					if (daNote.ArrowType == 'normal' || daNote.ArrowType == 'magnet')
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							health += 0.10;
							daNote.kill();
							notes.remove(daNote, true);
						}
						else
						{
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									if (!daNote.isSustainNote)
										health -= 0.10;
									vocals.volume = 0;
									if (theFunne && !daNote.isSustainNote)
										noteMiss(daNote.noteData, daNote);
									if (daNote.isParent)
									{
										health -= 0.20; // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
									}
									else
									{
										if (!daNote.wasGoodHit && daNote.isSustainNote && daNote.sustainActive && daNote.spotInLine != daNote.parent.children.length)
										{
											health -= 0.20; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
												misses++;
											updateAccuracy();
										}
									}
								}
							}
							else
							{
								if (!daNote.isSustainNote)
									health -= 0.10;
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
									noteMiss(daNote.noteData, daNote);

								if (daNote.isParent)
								{
									health -= 0.20; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
										trace(i.alpha);
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										health -= 0.20; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
											trace(i.alpha);
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
									}
								}
							}
						}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (PlayStateChangeables.useDownscroll)
				{
					if (moveAmount[spr.ID] > 0)
					{
						switch(spr.ID)
						{
							case 0: spr.y -= moveVelocity[spr.ID];
							case 1:	spr.y -= moveVelocity[spr.ID];
							case 2:	spr.y -= moveVelocity[spr.ID];
							case 3:	spr.y -= moveVelocity[spr.ID];
						}
						moveAmount[spr.ID] -= moveVelocity[spr.ID];
						moveVelocity[spr.ID] = Std.int(Math.ceil(1.5 * moveAmount[spr.ID] / 50));
						moveTimer[spr.ID] = 0;
					}
					else if(moveAmount[spr.ID] == 0)
					{
						if (Math.floor(moveTimer[spr.ID]) > 3)
						{
							if (moveAmountMemory[spr.ID] > 0)
							{
								switch(spr.ID)
								{
									case 0: spr.y += 2;
									case 1:	spr.y += 2;
									case 2:	spr.y += 2;
									case 3:	spr.y += 2;
								}
								moveAmountMemory[spr.ID] -= 2;
							}
						}
						else moveTimer[spr.ID] += elapsed;
					}
				}
				else
				{
					if (moveAmount[spr.ID] > 0)
					{
						switch(spr.ID)
						{
							case 0: spr.y += moveVelocity[spr.ID];
							case 1:	spr.y += moveVelocity[spr.ID];
							case 2:	spr.y += moveVelocity[spr.ID];
							case 3:	spr.y += moveVelocity[spr.ID];
						}
						moveAmount[spr.ID] -= moveVelocity[spr.ID];
						moveVelocity[spr.ID] = Std.int(Math.ceil(1.5 * moveAmount[spr.ID] / 50));
						moveTimer[spr.ID] = 0;
					}
					else if(moveAmount[spr.ID] == 0)
					{
						if (Math.floor(moveTimer[spr.ID]) > 3)
						{
							if (moveAmountMemory[spr.ID] > 0)
							{
								switch(spr.ID)
								{
									case 0: spr.y -= 1;
									case 1:	spr.y -= 1;
									case 2:	spr.y -= 1;
									case 3:	spr.y -= 1;
								}
								moveAmountMemory[spr.ID] -= 1;
							}
						}
						else moveTimer[spr.ID] += elapsed;
					}
				}
			});
		}
		
		for (i in 0...4)
		{
			if (noteCloseTime[i] > closeTime)
			{
				noteCloseTime[i] = 0;
				noteDoClose[i] = true;
			}
			if (!noteDoClose[i]) noteCloseTime[i] += elapsed;
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished && noteDoClose[spr.ID])
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}
		
		if (arrowShakeInitialize == true)
		{
			arrowShake();
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (isStoryMode)
			campaignMisses = misses;

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						FlxG.switchState(new StoryMenuState());
					}

					#if windows
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat)
					{
						case 'Dad-Battle':
							songFormat = 'Dadbattle';
						case 'Philly-Nice':
							songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen) 
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
				}
				else
					FlxG.switchState(new FreeplayState());
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		if (daNote.ArrowType == 'normal' || daNote.ArrowType == 'magnet')
		{
			var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
			var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
			var placement:String = Std.string(combo);

			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//

			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch (daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					health -= 0.04;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.02;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					health += 0.02;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.06;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}
			
			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
			{
				songScore += Math.round(score);
				songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
				
				if (songScore < 0) songScore = 0;

				var pixelShitPart1:String = "";
				var pixelShitPart2:String = '';

				if (curStage.startsWith('school'))
				{
					pixelShitPart1 = 'weeb/pixelUI/';
					pixelShitPart2 = '-pixel';
				}

				rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
				rating.screenCenter();
				rating.y -= 50;
				rating.x = coolText.x - 125;

				if (FlxG.save.data.changedHit)
				{
					rating.x = FlxG.save.data.changedHitX;
					rating.y = FlxG.save.data.changedHitY;
				}
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);

				var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
				if (PlayStateChangeables.botPlay && !loadRep)
					msTiming = 0;

				if (loadRep)
					msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

				if (currentTimingShown != null)
					remove(currentTimingShown);

				currentTimingShown = new FlxText(0, 0, 0, "0ms");
				timeShown = 0;
				switch (daRating)
				{
					case 'shit' | 'bad':
						currentTimingShown.color = FlxColor.RED;
					case 'good':
						currentTimingShown.color = FlxColor.GREEN;
					case 'sick':
						currentTimingShown.color = FlxColor.CYAN;
				}
				currentTimingShown.borderStyle = OUTLINE;
				currentTimingShown.borderSize = 1;
				currentTimingShown.borderColor = FlxColor.BLACK;
				currentTimingShown.text = msTiming + "ms";
				currentTimingShown.size = 20;

				if (msTiming >= 0.03 && offsetTesting)
				{
					// Remove Outliers
					hits.shift();
					hits.shift();
					hits.shift();
					hits.pop();
					hits.pop();
					hits.pop();
					hits.push(msTiming);

					var total = 0.0;

					for (i in hits)
						total += i;

					offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
				}

				if (currentTimingShown.alpha != 1)
					currentTimingShown.alpha = 1;

				if (!PlayStateChangeables.botPlay || loadRep)
					add(currentTimingShown);

				var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
				comboSpr.screenCenter();
				comboSpr.x = rating.x;
				comboSpr.y = rating.y + 100;
				comboSpr.acceleration.y = 600;
				comboSpr.velocity.y -= 150;

				currentTimingShown.screenCenter();
				currentTimingShown.x = comboSpr.x + 100;
				currentTimingShown.y = rating.y + 100;
				currentTimingShown.acceleration.y = 600;
				currentTimingShown.velocity.y -= 150;

				comboSpr.velocity.x += FlxG.random.int(1, 10);
				currentTimingShown.velocity.x += comboSpr.velocity.x;
				if (!PlayStateChangeables.botPlay || loadRep)
					add(rating);

				if (!curStage.startsWith('school'))
				{
					rating.setGraphicSize(Std.int(rating.width * 0.7));
					if(FlxG.save.data.antialiasing)
						{
							rating.antialiasing = true;
						}
					comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
					if(FlxG.save.data.antialiasing)
						{
							comboSpr.antialiasing = true;
						}
				}
				else
				{
					rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
					comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
				}

				currentTimingShown.updateHitbox();
				comboSpr.updateHitbox();
				rating.updateHitbox();

				currentTimingShown.cameras = [camHUD];
				comboSpr.cameras = [camHUD];
				rating.cameras = [camHUD];

				var seperatedScore:Array<Int> = [];

				var comboSplit:Array<String> = (combo + "").split('');

				if (combo > highestCombo)
					highestCombo = combo;

				// make sure we have 3 digits to display (looks weird otherwise lol)
				if (comboSplit.length == 1)
				{
					seperatedScore.push(0);
					seperatedScore.push(0);
				}
				else if (comboSplit.length == 2)
					seperatedScore.push(0);

				for (i in 0...comboSplit.length)
				{
					var str:String = comboSplit[i];
					seperatedScore.push(Std.parseInt(str));
				}

				var daLoop:Int = 0;
				for (i in seperatedScore)
				{
					var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
					numScore.screenCenter();
					numScore.x = rating.x + (43 * daLoop) - 50;
					numScore.y = rating.y + 100;
					numScore.cameras = [camHUD];

					if (!curStage.startsWith('school'))
					{
						if(FlxG.save.data.antialiasing)
							{
								numScore.antialiasing = true;
							}
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					}
					else
					{
						numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
					}
					numScore.updateHitbox();

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);

					add(numScore);

					FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						onComplete: function(tween:FlxTween)
						{
							numScore.destroy();
						},
						startDelay: Conductor.crochet * 0.002
					});

					daLoop++;
				}
				/* 
					trace(combo);
					trace(seperatedScore);
				 */

				coolText.text = Std.string(seperatedScore);
				// add(coolText);

				FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001,
					onUpdate: function(tween:FlxTween)
					{
						if (currentTimingShown != null)
							currentTimingShown.alpha -= 0.02;
						timeShown++;
					}
				});

				FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						coolText.destroy();
						comboSpr.destroy();
						if (currentTimingShown != null && timeShown >= 20)
						{
							remove(currentTimingShown);
							currentTimingShown = null;
						}
						rating.destroy();
					},
					startDelay: Conductor.crochet * 0.001
				});

				curSection += 1;
			}
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		#if windows
		if (luaModchart != null)
		{
			if (controls.LEFT_P)
			{
				luaModchart.executeState('keyPressed', ["left"]);
			};
			if (controls.DOWN_P)
			{
				luaModchart.executeState('keyPressed', ["down"]);
			};
			if (controls.UP_P)
			{
				luaModchart.executeState('keyPressed', ["up"]);
			};
			if (controls.RIGHT_P)
			{
				luaModchart.executeState('keyPressed', ["right"]);
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					trace(daNote.sustainActive);
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						boyfriend.playAnim('idle');
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!keys[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if cpp
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (daNote.ArrowType != 'paper')
		{
			if (!boyfriend.stunned)
			{
				combo = 0;
				misses++;

				if (daNote != null)
				{
					if (!loadRep)
					{
						saveNotes.push([
							daNote.strumTime,
							0,
							direction,
							166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
						]);
						saveJudge.push("miss");
					}
				}
				else if (!loadRep)
				{
					saveNotes.push([
						Conductor.songPosition,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
					]);
					saveJudge.push("miss");
				}

				// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
				// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

				if (FlxG.save.data.accuracyMod == 1)
					totalNotesHit -= 1;

				if (daNote != null)
				{
					if (!daNote.isSustainNote)
						songScore -= 150;
				}
				else songScore -= 150;
				
				if (songScore < 0) songScore = 0;
				
				if(FlxG.save.data.missSounds)
				{
					if (curStage == 'street-rain' || curStage == 'street-unused')
						FlxG.sound.play(Paths.soundRandom('missnotedistort', 1, 3), FlxG.random.float(0.1, 0.2));
					else if (curStage == 'void')
						FlxG.sound.play(Paths.soundRandom('missed', 1, 3), FlxG.random.float(0.1, 0.2));
					else
						FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
					// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
					// FlxG.log.add('played imss note');
				}

					// Hole switch statement replaced with a single line :)
				boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
				#end

				updateAccuracy();
					
				switch(daNote.ArrowType)
				{
					case 'oil':
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					case 'troll':
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}	
					case 'magnet':
					{
						moveAmount[daNote.noteData] += 50;
						moveAmountMemory[daNote.noteData] += 50;
						moveVelocity[daNote.noteData] = Std.int(Math.ceil(2 * moveAmount[daNote.noteData] / 50));
						
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								var noteActive:FlxSprite = new FlxSprite(spr.x - 140, spr.y - 240);
								switch(daNote.noteData)
								{
									case 0: 
										noteActive.frames = Paths.getSparrowAtlas('magnetic_note_activate_purple');
										noteActive.animation.addByPrefix('activate', 'Purple', 48, false);
									case 1: 
										noteActive.frames = Paths.getSparrowAtlas('magnetic_note_activate_blue');
										noteActive.animation.addByPrefix('activate', 'Blue', 48, false);
									case 2: 
										noteActive.frames = Paths.getSparrowAtlas('magnetic_note_activate_green');
										noteActive.animation.addByPrefix('activate', 'Green', 48, false);

									case 3: 
										noteActive.frames = Paths.getSparrowAtlas('magnetic_note_activate_red');
										noteActive.animation.addByPrefix('activate', 'Red', 48, false);
								}
								noteActive.setGraphicSize(Std.int(noteActive.width * 0.8));
								noteActive.animation.play('activate');
								noteActive.cameras = [camHUD];
								add(noteActive);
								noteActive.animation.finishCallback = function(name:String) { remove(noteActive); }
							}
						});
					}
				}
			}
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (note.ArrowType != 'paper')
		{
			if (mashing != 0)
				mashing = 0;

			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

			if (loadRep)
			{
				noteDiff = findByTime(note.strumTime)[3];
				note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
			}
			else
				note.rating = Ratings.CalculateRating(noteDiff);

			if (note.rating == "miss")
				return;

			// add newest note to front of notesHitArray
			// the oldest notes are at the end and are removed first
			if (!note.isSustainNote)
				notesHitArray.unshift(Date.now());

			if (!resetMashViolation && mashViolations >= 1)
				mashViolations--;

			if (mashViolations < 0)
				mashViolations = 0;

			switch(note.ArrowType)
			{
				case 'oil':
				{
					noteMiss(note.noteData, note);
					oilOnScreen();
				}
				case 'troll':
				{
					noteMiss(note.noteData, note);
					trolling();
					if (!note.isSustainNote)
					{
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(note.noteData) == spr.ID)
							{
								var noteBreak:FlxSprite = new FlxSprite(spr.x - 20, spr.y - 18);
								noteBreak.frames = Paths.getSparrowAtlas('troll_note_vanish');
								switch(note.noteData)
								{
									case 0: noteBreak.animation.addByPrefix('breaking', 'Purple', 48, false);
									case 1: noteBreak.animation.addByPrefix('breaking', 'Blue', 48, false);
									case 2: noteBreak.animation.addByPrefix('breaking', 'Green', 48, false);
									case 3: noteBreak.animation.addByPrefix('breaking', 'Red', 48, false);
								}
								noteBreak.animation.play('breaking');
								noteBreak.cameras = [camHUD];
								add(noteBreak);
								FlxTween.tween(noteBreak.scale, { x:2, y:2 }, 0.25);
								noteBreak.animation.finishCallback = function(name:String) { remove(noteBreak); }
							}
						});
						popUpScore(note);
						combo += 1;
					}
				}
				default:
				{
					if (!note.wasGoodHit)
					{
						if (!note.isSustainNote)
						{
							playerStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(note.noteData) == spr.ID) spr.animation.play('confirm', true);
							});
							popUpScore(note);
							combo += 1;
						}
						else
						{
							totalNotesHit += 1;
							if (health < 2) health += 0.01;
						}

						switch (note.noteData)
						{
							case 2:
								boyfriend.playAnim('singUP', true);
							case 3:
								boyfriend.playAnim('singRIGHT', true);
							case 1:
								boyfriend.playAnim('singDOWN', true);
							case 0:
								boyfriend.playAnim('singLEFT', true);
						}

						#if windows
						if (luaModchart != null)
							luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
						#end

						if (!loadRep && note.mustPress)
						{
							var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
							if (note.isSustainNote)
								array[1] = -1;
							saveNotes.push(array);
							saveJudge.push(note.rating);
						}

						note.kill();
						notes.remove(note, true);
						note.destroy();

						updateAccuracy();
					}
				}
			}
		}
	}
	
	//straight from bob mod
	function shakescreen(Magnitude:Int)
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int( -1 * Magnitude, Magnitude),Lib.application.window.y + FlxG.random.int( -1 * Magnitude, Magnitude));
		}, 50);
	}
	
	var arrowShakeInitialize:Bool = false;
	
	var commandOnX:String = '';
	var commandOnY:String = '';
	
	var commandOnXMemory:String = '';
	var commandOnYMemory:String = '';
	
	var xOffset:Array<Float> = [0, 0, 0, 0];
	var yOffset:Array<Float> = [0, 0, 0, 0];
	
	var xPhaseDiff:Array<Float> = [0, 0, 0, 0];
	var yPhaseDiff:Array<Float> = [0, 0, 0, 0];
	
	var xDelta:Array<Float> = [0, 0, 0, 0];
	var yDelta:Array<Float> = [0, 0, 0, 0];
	
	var xPeriod:Int = 1;
	var yPeriod:Int = 1;
	
	var xAmplitude:Float = 1;
	var yAmplitude:Float = 1;
	
	var countingSteps:Int = 0;
	var reverse: Bool = false;
	
	//arrow offset y = 50, x = 1026 914 802 690 386 274 162 50
	
	function arrowReturn(?close:Bool, ?reverse:Bool)
	{
		var playerCoordinateReference = [0, 0, 0, 0];
		var cpuCoordinateReference = [0, 0, 0, 0];
		if (reverse == null || !reverse)
		{
			playerCoordinateReference = [690, 802, 914, 1026];
			cpuCoordinateReference = [50, 162, 274, 386];
		}
		else if (reverse != null && reverse)
		{
			playerCoordinateReference = [1026, 914, 802, 690];
			cpuCoordinateReference = [386, 274, 162, 50];
		}
		var playerDeltaX:Array<Float> = [0, 0, 0, 0];
		var playerDeltaY:Array<Float> = [0, 0, 0, 0];
		var cpuDeltaX:Array<Float> = [0, 0, 0, 0];
		var cpuDeltaY:Array<Float> = [0, 0, 0, 0];
		
		var arrowY:Int = 40;
		if (PlayStateChangeables.useDownscroll) arrowY = 545;
		
		playerStrums.forEach(function(spr:FlxSprite) {
			playerDeltaX[spr.ID] = spr.x - playerCoordinateReference[spr.ID];
			playerDeltaY[spr.ID] = spr.y - arrowY;
			FlxTween.tween(spr, { x:playerCoordinateReference[spr.ID], y:arrowY }, 0.5, { ease:FlxEase.cubeOut });
		});
		cpuStrums.forEach(function(spr:FlxSprite) {
			cpuDeltaX[spr.ID] = spr.x - playerCoordinateReference[spr.ID];
			cpuDeltaY[spr.ID] = spr.y - arrowY;
			FlxTween.tween(spr, { x:cpuCoordinateReference[spr.ID], y:arrowY }, 0.5, { ease:FlxEase.cubeOut });
		});
		notes.forEachAlive(function(daNote:Note) { FlxTween.tween(daNote, { x: daNote.x - playerDeltaX[daNote.noteData], y: daNote.y - playerDeltaY[daNote.noteData] }, 0.5, { ease:FlxEase.cubeOut }); });
		commandOnXMemory = commandOnX;
		xOffset = [0, 0, 0, 0];
		commandOnYMemory = commandOnY;
		yOffset = [0, 0, 0, 0];
		if (close != null && close)
		{
			arrowShakeInitialize = false;
		}
	}
	
	function arrowShake()
	{
		countingSteps++;
		
		if (commandOnX != commandOnXMemory)
		{
			arrowReturn(false, reverse);
		}
		else
		{
			switch (commandOnX)
			{
				case '':
				case 'sine':
				{
					if (xPeriod != 0)
					{
						notes.forEachAlive(function(daNote:Note) { daNote.x += xAmplitude * FlxMath.fastSin((((countingSteps % xPeriod) * 2 * Math.PI) / xPeriod) + xPhaseDiff[daNote.noteData]); });
						playerStrums.forEach(function(spr:FlxSprite) { spr.x += xAmplitude * FlxMath.fastSin((((countingSteps % xPeriod) * 2 * Math.PI) / xPeriod) + xPhaseDiff[spr.ID]); });
						cpuStrums.forEach(function(spr:FlxSprite) { spr.x += xAmplitude * FlxMath.fastSin((((countingSteps % xPeriod) * 2 * Math.PI) / xPeriod) + xPhaseDiff[spr.ID]); });
					}
				}
				case 'cosine':
				{
					if (xPeriod != 0)
					{
						notes.forEachAlive(function(daNote:Note) { daNote.x += xAmplitude * FlxMath.fastCos((((countingSteps % xPeriod) * 2 * Math.PI) / xPeriod) + xPhaseDiff[daNote.noteData]); });
						playerStrums.forEach(function(spr:FlxSprite) { spr.x += xAmplitude * FlxMath.fastCos((((countingSteps % xPeriod) * 2 * Math.PI) / xPeriod) + xPhaseDiff[spr.ID]); });
						cpuStrums.forEach(function(spr:FlxSprite) { spr.x += xAmplitude * FlxMath.fastCos((((countingSteps % xPeriod) * 2 * Math.PI) / xPeriod) + xPhaseDiff[spr.ID]); });
					}
				}
				case 'jitter':
				{
					for (i in 0...4)
					{
						xDelta[i] = xAmplitude * (Math.random() - ((xOffset[i] / 50) * 0.5 + 0.5));
						xOffset[i] += xDelta[i];
					}
					notes.forEachAlive(function(daNote:Note) { daNote.x += xDelta[daNote.noteData]; });
					playerStrums.forEach(function(spr:FlxSprite) { spr.x += xDelta[spr.ID]; });
					cpuStrums.forEach(function(spr:FlxSprite) { spr.x += xDelta[spr.ID]; });
				}
			}
		}
		
		if (commandOnY != commandOnYMemory)
		{
			arrowReturn(false, reverse);
		}
		else
		{
			switch (commandOnY)
			{
				case '':
				case 'sine':
				{
					if (yPeriod != 0)
					{
						notes.forEachAlive(function(daNote:Note) { daNote.y += yAmplitude * FlxMath.fastSin((((countingSteps % yPeriod) * 2 * Math.PI) / yPeriod) + yPhaseDiff[daNote.noteData]); });
						playerStrums.forEach(function(spr:FlxSprite) { spr.y += yAmplitude * FlxMath.fastSin((((countingSteps % yPeriod) * 2 * Math.PI) / yPeriod) + yPhaseDiff[spr.ID]); });
						cpuStrums.forEach(function(spr:FlxSprite) { spr.y += yAmplitude * FlxMath.fastSin((((countingSteps % yPeriod) * 2 * Math.PI) / yPeriod) + yPhaseDiff[spr.ID]); });
					}
				}
				case 'cosine':
				{
					if (yPeriod != 0)
					{
						notes.forEachAlive(function(daNote:Note) { daNote.y += yAmplitude * FlxMath.fastCos((((countingSteps % yPeriod) * 2 * Math.PI) / yPeriod) + yPhaseDiff[daNote.noteData]); });
						playerStrums.forEach(function(spr:FlxSprite) { spr.y += yAmplitude * FlxMath.fastCos((((countingSteps % yPeriod) * 2 * Math.PI) / yPeriod) + yPhaseDiff[spr.ID]); });
						cpuStrums.forEach(function(spr:FlxSprite) { spr.y += yAmplitude * FlxMath.fastCos((((countingSteps % yPeriod) * 2 * Math.PI) / yPeriod) + yPhaseDiff[spr.ID]); });
					}
				}
				case 'jitter':
				{
					for (i in 0...4)
					{
						yDelta[i] = yAmplitude * (Math.random() - ((yOffset[i] / 50) * 0.5 + 0.5));
						yOffset[i] += yDelta[i];
					}
					notes.forEachAlive(function(daNote:Note) { daNote.y += yDelta[daNote.noteData]; });
					playerStrums.forEach(function(spr:FlxSprite) { spr.y += yDelta[spr.ID]; });
					cpuStrums.forEach(function(spr:FlxSprite) { spr.y += yDelta[spr.ID]; });
				}
			}
		}
	}
	
	var oilList:Array<FlxSprite> = [];
	var oilTween:Array<FlxTween> = [];
	var oilRandom:Int = 0;
	var oilIndex:Int = 0;
	
	//loading heavy stuff(lagging hazard caution)
	function LoadOil()
	{
		for (i in 0...20)
		{
			var oil:FlxSprite = new FlxSprite();
			if (i < 8)
			{
				var oilTex = Paths.getSparrowAtlas('background/oil/oil' + Std.string(i + 1), 'trollge');
				oil.frames = oilTex;
			}
			else
			{
				var oilTex = Paths.getSparrowAtlas('background/oil/oil' + Std.string(Math.floor(Math.random() * 7.99) + 1), 'trollge');
				oil.frames = oilTex;
			}	
			oil.animation.addByPrefix('splash', 'Oil', 24, false);
			oil.alpha = 1;
			oil.setGraphicSize(Std.int(oil.width * 1.5));
			oil.antialiasing = true;
			oil.scrollFactor.set();
			oil.blend = DIFFERENCE;
			oil.cameras = [camHUD];
			add(oil);
			oilList.push(oil);
			
			var tween = FlxTween.tween(oil, { y:840+(Math.random()*120-60), alpha:0 }, 6, { ease:FlxEase.sineOut, type:FlxTweenType.PERSIST });
			oilTween.push(tween);
		}
	}
	
	var blobList:Array<FlxSprite> = [];
	var blobIndex:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
	var blobIndexx:Int = 0;
	var blobRandom:Int = 0;
	var blobInitialize:Bool = false;
	var blobMenifest:Bool = false;
	
	function LoadBlob()
	{
		for (i in 0...15)
		{
			var blob:FlxSprite = new FlxSprite();
			var blobTex = Paths.getSparrowAtlas('background/blob', 'trollge');
			blob.frames = blobTex;
			blob.animation.addByPrefix('sustain', 'Sus', 24, true);
			blob.screenCenter();
			blob.alpha = 0;
			blob.setGraphicSize(Std.int(blob.width * 2));
			blob.antialiasing = true;
			blob.scrollFactor.set();
			add(blob);
			blobList.push(blob);
		}
		blobInitialize = true;
	}
	
	var eyeList:Array<FlxSprite> = [];
	var eyeIndex:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
	var eyeIndexx:Int = 0;
	var eyeRandom:Int = 0;
	var eyeInitialize:Bool = false;
	var eyeMenifest:Bool = false;
	
	function LoadEye()
	{
		for (i in 0...15)
		{
			var eye:FlxSprite = new FlxSprite();
			var eyeTex = Paths.getSparrowAtlas('background/eye', 'trollge');
			eye.frames = eyeTex;	
			eye.animation.addByPrefix('blink', 'Blink', 24, true);
			eye.screenCenter();
			eye.alpha = 0;
			eye.setGraphicSize(Std.int(eye.width * 2));
			eye.antialiasing = true;
			eye.scrollFactor.set();
			add(eye);
			eyeList.push(eye);
		}
		
		eyeInitialize = true;
	}
	
	//handle things when you hit oily note
	function oilOnScreen()
	{
		//get the oil on screen
		if (oilList.length != 0) oilRandom = Std.int(Math.floor(Math.random() * (oilList.length - 1)));
		else oilRandom = Std.int(Math.floor(Math.random() * 19.999));
		
		oilList[oilRandom].x = Math.random() * 360 - 60;
		oilList[oilRandom].y = 0 ;
		oilList[oilRandom].alpha = 1;
		oilList[oilRandom].animation.play('splash', false);
		oilTween[oilRandom].start();
		
		//oil splash sound effect
		FlxG.sound.play(Paths.soundRandom('splat_', 1, 5));
	}
	
	function blobOnScreen()
	{
		if ((Math.random() < 0.01) && (blobIndex.length != 0))
		{
			blobRandom = Std.int(Math.floor(Math.random() * (blobList.length - 1)));
			blobIndexx = blobIndex[blobRandom];
			blobIndex.remove(blobIndexx);

			blobList[blobIndexx].resetSizeFromFrame();
			
			blobList[blobIndexx].x = Math.random() * 1920 - 575;
			blobList[blobIndexx].y = Math.random() * 1080 - 235;
			blobList[blobIndexx].setGraphicSize(Std.int(blobList[blobIndexx].width * (1 + Math.random())));
			blobList[blobIndexx].alpha = Math.random() * 0.3 + 0.7;
			blobList[blobIndexx].animation.play('sustain', true);
			
			FlxTween.tween(blobList[blobIndexx].scale, { x:Math.random() * 0.3 + 1.2, y:Math.random() * 0.3 + 1.2 }, 2, { ease: FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(blobList[blobIndexx], { alpha: Math.random() * 0.3 + 0.7 }, 1.5);}})
			.then(FlxTween.tween(blobList[blobIndexx].scale, { x:Math.random() * 0.3 + 0.6, y:Math.random() * 0.3 + 0.6  }, 2, { ease:FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(blobList[blobIndexx], { alpha: 0 }, 1.5); }}))
			.then(FlxTween.tween(blobList[blobIndexx].scale, { x:Math.random() * 0.3 + 1.2, y:Math.random() * 0.3 + 1.2 }, 2, { ease: FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(blobList[blobIndexx], { alpha: Math.random() * 0.3 + 0.7 }, 1.5); }}))
			.then(FlxTween.tween(blobList[blobIndexx].scale, { x:Math.random() * 0.3 + 0.6, y:Math.random() * 0.3 + 0.6  }, 2, { ease:FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(blobList[blobIndexx], { alpha: 0 }, 1.5); }}))	
			.then(FlxTween.tween(blobList[blobIndexx].scale, { x:0, y:0}, 0.25, { ease: FlxEase.quadOut, 
				onComplete: function(tween:FlxTween) {blobIndex.push(blobIndexx); }}));
		}
	}
	
	function eyeOnScreen()
	{
		if ((Math.random() < 0.01) && (eyeIndex.length != 0))
		{
			eyeRandom = Std.int(Math.floor(Math.random() * (eyeList.length - 1)));
			eyeIndexx = eyeIndex[eyeRandom];
			eyeIndex.remove(eyeIndexx);

			eyeList[eyeIndexx].resetSizeFromFrame();
			
			eyeList[eyeIndexx].x = Math.random() * 1920 - 575;
			eyeList[eyeIndexx].y = Math.random() * 1080 - 235;
			eyeList[eyeIndexx].setGraphicSize(Std.int(eyeList[eyeIndexx].width * (0.5 + Math.random()*0.5)));
			eyeList[eyeIndexx].alpha = Math.random() * 0.3 + 0.7;
			eyeList[eyeIndexx].animation.play('blink', true);
			
			FlxTween.tween(eyeList[eyeIndexx].scale, { x:Math.random() * 0.3 + 1.2, y:Math.random() * 0.3 + 1.2 }, 2, { ease: FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(eyeList[eyeIndexx], { alpha: Math.random() * 0.3 + 0.7 }, 1.5);}})
			.then(FlxTween.tween(eyeList[eyeIndexx].scale, { x:Math.random() * 0.3 + 0.6, y:Math.random() * 0.3 + 0.6  }, 2, { ease:FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(eyeList[eyeIndexx], { alpha: 0 }, 1.5); }}))
			.then(FlxTween.tween(eyeList[eyeIndexx].scale, { x:Math.random() * 0.3 + 1.2, y:Math.random() * 0.3 + 1.2 }, 2, { ease: FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(eyeList[eyeIndexx], { alpha: Math.random() * 0.3 + 0.7 }, 1.5); }}))
			.then(FlxTween.tween(eyeList[eyeIndexx].scale, { x:Math.random() * 0.3 + 0.6, y:Math.random() * 0.3 + 0.6  }, 2, { ease:FlxEase.sineOut, 
				onComplete: function(tween:FlxTween) {FlxTween.tween(eyeList[eyeIndexx], { alpha: 0 }, 1.5); }}))	
			.then(FlxTween.tween(eyeList[eyeIndexx].scale, { x:0, y:0}, 0.25, { ease: FlxEase.quadOut, 
				onComplete: function(tween:FlxTween) {eyeIndex.push(eyeIndexx); }}));
		}
	}
	
	function trolling()
	{
		//handle things when you hit the trolling note
		//laughing sound effect
		
		//wood break sound effect
		FlxG.sound.play(Paths.soundRandom('TrollNoteBreaking_', 1, 3));
	}
	
	var climax:Bool = false;
	
	function mischiefEvent()
	{
		switch(curStep)
		{
			case 10:
			{
				healthFactor = 0;
				if (climax) climax = false;
			}
			case 1024:
			{
				FlxTween.tween(heartbeat, { alpha:1 }, 2);
				FlxTween.tween(hue, { alpha:0.15 }, 60);
				healthFactor = 0.03;
				climax = true;
				defaultCamZoom = 0.8;
				FlxG.camera.zoom = 0.85;
				camHUD.zoom = 0.85;
				
				//Setup the arrow shake
				arrowShakeInitialize = true;
				commandOnX = 'sine';
				commandOnY = 'jitter';
				xPhaseDiff = [0, 0.3 * Math.PI, 0.6 * Math.PI, 0.9 * Math.PI];
				xPeriod = 120;
				xAmplitude = 1;
				yAmplitude = 5;	
			}
			case 1152:
			{
				defaultCamZoom = 0.7;
				FlxTween.tween(heartbeat, { alpha:0 }, 2);
				healthFactor = 0.02;
				climax = false;
				FlxG.camera.zoom = 0.7;
				
				//turning off the arrow shake
				commandOnX = '';
				commandOnY = '';
				arrowReturn(true, false);
			}
			{/*
			case 959:
			{
				FlxTween.tween(heartbeat, { alpha:1 }, 2);
				FlxTween.tween(hue, { alpha:0.15 }, 60);
				healthFactor = 0.02;
				climax = true;
				defaultCamZoom = 0.8;
				FlxG.camera.zoom = 0.85;
				camHUD.zoom = 0.85;
				
				//Setup the arrow shake
				arrowShakeInitialize = true;
				commandOnX = 'sine';
				commandOnY = 'jitter';
				xPhaseDiff = [0, 0.3 * Math.PI, 0.6 * Math.PI, 0.9 * Math.PI];
				xPeriod = 120;
				xAmplitude = 1;
				yAmplitude = 5;	
			}
			case 1216:
			{
				defaultCamZoom = 0.7;
				FlxTween.tween(heartbeat, { alpha:0 }, 2);
				healthFactor = 0;
				climax = false;
				FlxG.camera.zoom = 0.7;
				
				//turning off the arrow shake
				commandOnX = '';
				commandOnY = '';
				arrowReturn(true, false);
			}
			case 1272: healthFactor = 0.04;
			case 1280: healthFactor = 0;
			case 1400: healthFactor = 0.04;
			case 1406: healthFactor = 0;
			case 1592: healthFactor = 0.05;
			case 1600: healthFactor = 0;
			case 1664: healthFactor = 0.05; */}
		}
	}
	
	var thunderTrack:Int = 0;
	
	function changeCharacter(character:String, ?fade:Bool)
	{
		remove(dad);
		dad = new Character( 100, 100, character);
		switch (character)
		{
			case 'trollge01':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge01dark':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge02':
				dad.x -= 124;
				dad.y -= 30;
			case 'trollge02_soaked':
				dad.x -= 124;
				dad.y -= 30;
			case 'trollge02s':
				dad.x -= 124;
				dad.y -= 30;
			case 'trollge03':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge_glitch':
				dad.x -= 124;
				dad.y -= 20;
			case 'trollge_eye':
				dad.x -= 124;
				dad.y -= 20;
		}
		if (fade != null && fade)
		{
			dad.alpha = 0;
			FlxTween.tween(dad, { alpha:1 }, 0.75, { ease:FlxEase.sineOut});
		}
		add(dad);
	}
	
	function ominousEvent()
	{
		//healthfactor manipulation
		switch(curStep)
		{
			case 0: 
			{
				if (climax) climax = false;
				healthFactor = 0.01;
				rainFrontA.animation.play('rain', true);
			}
			case 9:	rainBackA.animation.play('rain', true);
			case 18: rainFrontB.animation.play('rain', true);
			case 27: rainBackB.animation.play('rain', true);
			case 126: healthFactor = 0.01;
			case 320: healthFactor = 0.015;
			case 502: changeCharacter('trollge02s');
			case 524: changeCharacter('trollge02');
			case 575: healthFactor = 0.02;
			case 588: changeCharacter('trollge02s');
			case 608: changeCharacter('trollge02');
			case 654: changeCharacter('trollge02s');
			case 672: changeCharacter('trollge02');
			case 716: changeCharacter('trollge02s');
			case 736: changeCharacter('trollge02');
			case 764: changeCharacter('trollge02s');
			case 800: changeCharacter('trollge02');
			case 832: healthFactor = 0.025;
			case 954: 
			{
				changeCharacter('trollge02s');
				FlxTween.tween(hue, { alpha:0.15 }, 30);
				FlxTween.tween(heartbeat, { alpha:1 }, 2);
			}
			case 1088: FlxG.sound.play(Paths.sound('jump'));
			case 1092:
			{
				jumpIn.alpha = 1;
				jumpIn.animation.play('jump', false);
				
				//Setup the arrow shake
				arrowShakeInitialize = true;
				commandOnX = 'sine';
				commandOnY = 'cosine';
				xPhaseDiff = [0, 0.3 * Math.PI, 0.6 * Math.PI, 0.9 * Math.PI];
				yPhaseDiff = [0.9 * Math.PI, 0.6 * Math.PI, 0.3 * Math.PI, 0];
				xPeriod = 160;
				yPeriod = 120;
				xAmplitude = 1.2;
				yAmplitude = 0.3;
			}
			case 1424: healthFactor = 0.025;
			case 1800: healthFactor = 0.03;
			case 1920: healthFactor = 0.025;
			case 2058: healthFactor = 0.03;
			case 2178: healthFactor = 0.04;
		}
		
		//thundering
		if (((thunderTrack == 0) || ((curStep - thunderTrack) > 400)) && (curStep <= 1000))
		{
			if (Math.random() < (curStep % 600) / 600)
			{
				thunder.alpha = 1;
				FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
				thunderTrack = curStep;
				thunder.animation.play('thunder', false);
			}
		}
	}
	
	var doShake:Bool = false;
	var justShake:Bool = false;

	function incidentEvent()
	{
		//healthfactor manipulation
		switch(curStep)
		{
			case 1:
			{
				healthFactor = 0.03;
				FlxTween.tween(fadeIn, { alpha:0 }, 1, { ease:FlxEase.sineOut });
				FlxG.camera.zoom = 3;
				FlxTween.tween(FlxG.camera, { zoom:0.6 }, 1, { ease:FlxEase.sineOut });
				
				//Setup the arrow shake
				arrowShakeInitialize = true;
				commandOnX = 'jitter';
				commandOnY = 'jitter';
				xAmplitude = 7;
				yAmplitude = 7;
				reverse = true;
			}
			case 528: healthFactor = 0.03;
			case 599: FlxG.sound.play(Paths.sound('scream'));
			case 600:
			{
				jumpIn.alpha = 1;
				jumpIn.animation.play('jump', false);
				
				//Setup the arrow shake
				arrowShakeInitialize = true;
				commandOnX = 'jitter';
				commandOnY = 'sine';
				yPhaseDiff = [0, 0.5 * Math.PI, Math.PI, 1.5 * Math.PI];
				yPeriod = 120;
				xAmplitude = 12;
				yAmplitude = 0.3;
				reverse = false;
				
				healthFactor = 0.03;
			}
			case 840: healthFactor = 0.03;
			case 980: healthFactor = 0.04;
			case 992:
			{
				remove(factoryBackB);
				remove(factoryB);
				remove(barB);
				remove(chainB);
				
				FlxTween.tween(hue, { alpha:0 }, 1.5, { ease:FlxEase.elasticOut, onComplete: function(twn:FlxTween){ remove(hue); } });
				FlxTween.tween(cloud, { alpha:0 }, 1.5, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ remove(cloud); }});
				FlxTween.tween(fog, { alpha:0 }, 1.5, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ remove(fog); }});
				FlxTween.tween(heartbeat, { alpha:1 }, 1.5, { ease:FlxEase.elasticOut });
				
				factoryTransition.visible  = true;
				factoryTransitionBack.visible  = true;
				barTransition.visible = true;
				chainTransition.visible  = true;
				
				factoryTransition.active  = true;
				factoryTransitionBack.active  = true;
				barTransition.active = true;
				chainTransition.active  = true;
				
				factoryTransition.animation.play('transition', false);
				factoryTransitionBack.animation.play('transition', false);
				barTransition.animation.play('transition', false);
				chainTransition.animation.play('transition', false);
				
				climax = true;
				doShake = true;
			}
			case 1504:
			{
				FlxTween.tween(heartbeat, { alpha:0 }, 1.5, { ease:FlxEase.elasticOut });
				FlxTween.tween(factoryC, { alpha:0 }, 0.75, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ remove(factoryC); } });
				FlxTween.tween(factoryBackC, { alpha:0 }, 0.75, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ remove(factoryBackC); }});
				FlxTween.tween(barC, { alpha:0 }, 0.75, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ remove(barC); }});
				FlxTween.tween(chainC, { alpha:0 }, 0.75, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ remove(chainC); }});
				FlxTween.tween(staticScreen, { alpha:0 }, 0.75, { ease:FlxEase.sineOut});
				FlxTween.tween(FlxG.camera, { zoom:0.7 }, 1, { ease:FlxEase.sineOut, onComplete: function(twn:FlxTween){ defaultCamZoom = 0.7; } });
				
				climax = false;
				doShake = false;
				healthFactor = 0.01;
				arrowReturn(true, false);
				changeCharacter('trollge_eye', true);
			}
			
			case 1665:
			case 1681:
			case 1728:
			case 1745:
			case 1753:
			case 1758:
				
			case 1880: healthFactor = 0.015;
			case 1886:
			{
				defaultCamZoom = 0.6;
				FlxTween.tween(staticScreen, { alpha:0.25 }, 0.75, { ease:FlxEase.sineOut});
				changeCharacter('trollge_glitch');
				blobMenifest = true;
				eyeMenifest = true;
				troll.visible = true;
				climax = true;
			}
			case 1894:
			{
				climax = false;
			}
			case 2160:
			{
				healthFactor = 0.02;
				climax = true;
				doShake = true;
			}
			case 2224:
			case 2240:
			case 2256:
			case 2272:
			case 2274:
			case 2288:	
			case 2304: 
			{
				healthFactor = 0.01;
				
			}
			case 2432:
			case 2560: healthFactor = 0.02;
			case 2688:
			case 2816:
			case 2944:
			case 3072: healthFactor = 0.03;
			case 3200:
			case 3328:
			case 3456:
		}

		//camera movement
		
		//climax event
	}
	
	function loreEvent()
	{
		switch(curStep)
		{
			case 1: {
				healthFactor = 0;
				blobMenifest = true;
			}
			case 64: healthFactor = 0.01;
			case 192: healthFactor = 0.025;
			case 320: healthFactor = 0.03;
			case 768: healthFactor = 0.02;
			case 1151: healthFactor = 0.035;
		}
	}
	
	function insanityEvent()
	{
		switch(curStep)
		{
			case 1: healthFactor = 0.025;
			case 192: healthFactor = 0.025;
			case 520: healthFactor = 0;
			case 560: healthFactor = 0.025;
			case 1071: healthFactor = 0.03;
			case 1522: healthFactor = 0;
			case 1584: healthFactor = 0.04;
			case 1839: healthFactor = 0.025;
			case 2095: healthFactor = 0;
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20) resyncVocals();
		
		switch(curSong.toLowerCase())
		{
			case 'mischief': mischiefEvent();
			case 'ominous': ominousEvent();
			case 'incident': incidentEvent();
			case 'lore': loreEvent();
			case 'insanity': insanityEvent();
		}
		
		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

			#if windows
			if (executeModchart && luaModchart != null)
			{
				luaModchart.setVar('curBeat', curBeat);
				luaModchart.executeState('beatHit', [curBeat]);
			}
			#end

			if (curSong == 'Tutorial' && dad.curCharacter == 'gf')
			{
				if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
					dad.playAnim('danceLeft');
				if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
					dad.playAnim('danceRight');
			}

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				// else
				// Conductor.changeBPM(SONG.bpm);

				// Dad doesnt interupt his own notes
				if ((SONG.notes[Math.floor(curStep / 16)].mustHitSection || !dad.animation.curAnim.name.startsWith("sing")) && dad.curCharacter != 'gf')
				{
					if (curBeat % idleBeat == 0 || dad.curCharacter == "spooky")
					{
						dad.dance(idleToBeat);
						if (troll != null && troll.visible) troll.dance();
					}
				}
			}
			// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
			wiggleShit.update(Conductor.crochet);

			if (FlxG.save.data.camzoom)
			{
				// HARDCODING FOR MILF ZOOMS!
				if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
				}

				if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
				{
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
				}
				
				if (curSong.toLowerCase() == 'mischief' && curStep >= 954 && curBeat < 1216 && camZooming && FlxG.camera.zoom < 1.35 && climax)
				{
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
				}

			}

			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();

			if (curBeat % gfSpeed == 0)
			{
				gf.dance();
			}

			if (!boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % idleBeat == 0)
			{
				boyfriend.playAnim('idle', idleToBeat);
			}

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}

			if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				boyfriend.playAnim('hey', true);
				dad.playAnim('cheer', true);
			}

			switch (curStage)
			{
				case 'school':
					if (FlxG.save.data.distractions)
					{
						bgGirls.dance();
					}

				case 'mall':
					if (FlxG.save.data.distractions)
					{
						upperBoppers.animation.play('bop', true);
						bottomBoppers.animation.play('bop', true);
						santa.animation.play('idle', true);
					}

				case 'limo':
					if (FlxG.save.data.distractions)
					{
						grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
					}
				case "philly":
					if (FlxG.save.data.distractions)
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							curLight = FlxG.random.int(0, phillyCityLights.length - 1);

							phillyCityLights.members[curLight].visible = true;
							// phillyCityLights.members[curLight].alpha = 1;
						}
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						if (FlxG.save.data.distractions)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
						}
					}
			}
			
			if (climax)
			{
				switch (curStage)
				{
					case 'street-sunny': 
						FlxG.camera.shake(0.005, 0.5);
						heartbeat.animation.play('beat', false);
					case "street-rain":
						heartbeat.animation.play('beat', false);
					case 'void': 
						heartbeat.animation.play('beat', false);
						if (!SONG.notes[Math.floor(curStep / 16)].mustHitSection && doShake)
						{
							shakescreen(2);
							FlxG.camera.shake(0.025, 0.2);	
						}
				}
			}
			
			if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
			{
				if (FlxG.save.data.distractions)
				{
					lightningStrikeShit();
				}
			}
		}
	}

	var curLight:Int = 0;
}