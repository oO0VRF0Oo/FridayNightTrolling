package;

import flixel.FlxG;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		if(FlxG.save.data.antialiasing)
			{
				antialiasing = true;
			}
		if (char == 'sm')
		{
			loadGraphic(Paths.image("stepmania-icon"));
			return;
		}
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);
		animation.add('bf', [0, 1, 24], 0, false, isPlayer);
		animation.add('bf-1', [0, 1, 24], 0, false, isPlayer);
		animation.add('bf-2', [0, 1, 24], 0, false, isPlayer);
		animation.add('bf-car', [0, 1, 24], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1, 24], 0, false, isPlayer);
		animation.add('bf-pixel', [21, 21, 21], 0, false, isPlayer);
		animation.add('spooky', [2, 3, 2], 0, false, isPlayer);
		animation.add('pico', [4, 5, 4], 0, false, isPlayer);
		animation.add('mom', [6, 7, 6], 0, false, isPlayer);
		animation.add('mom-car', [6, 7, 6], 0, false, isPlayer);
		animation.add('tankman', [8, 9, 8], 0, false, isPlayer);
		animation.add('face', [10, 11, 10], 0, false, isPlayer);
		animation.add('dad', [12, 13, 12], 0, false, isPlayer);
		animation.add('senpai', [22, 22, 22], 0, false, isPlayer);
		animation.add('senpai-angry', [22, 22, 22], 0, false, isPlayer);
		animation.add('spirit', [23, 23, 23], 0, false, isPlayer);
		animation.add('bf-old', [14, 15, 14], 0, false, isPlayer);
		animation.add('gf', [16, 16, 16], 0, false, isPlayer);
		animation.add('gf-1', [16, 16, 16], 0, false, isPlayer);
		animation.add('gf-2', [16, 16, 16], 0, false, isPlayer);
		animation.add('gf-christmas', [16, 16, 16], 0, false, isPlayer);
		animation.add('gf-pixel', [16, 16, 16], 0, false, isPlayer);
		animation.add('parents-christmas', [17, 18, 18], 0, false, isPlayer);
		animation.add('monster', [19, 20, 20], 0, false, isPlayer);
		animation.add('monster-christmas', [19, 20, 20], 0, false, isPlayer);
		animation.add('trollge01', [25, 26, 27], 0, false, isPlayer);
		animation.add('trollge01ori', [25, 26, 27], 0, false, isPlayer);
		animation.add('trollge02', [25, 26, 27], 0, false, isPlayer);
		animation.add('trollge02s', [25, 26, 27], 0, false, isPlayer);
		animation.add('trollge02_soaked', [25, 26, 27], 0, false, isPlayer);
		animation.add('trollge03', [25, 26, 27], 0, false, isPlayer);
		animation.play(char);

		switch(char)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				antialiasing = false;
		}

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
