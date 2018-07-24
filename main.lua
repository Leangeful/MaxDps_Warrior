--- @type MaxDps
if not MaxDps then
	return;
end

local Warrior = MaxDps:NewModule('Warrior');

-- Spells
-- Fury
local _Charge = 100;
local _FuriousSlash = 100130;
local _Recklessness = 1719;
local _Siegebreaker = 280772;
local _Rampage = 184367;
local _Execute = 5308;
local _Bloodthirst = 23881;
local _RagingBlow = 85288;
local _DragonRoar = 118000;
local _Bladestorm = 46924;
local _Whirlwind = 190411;
local _Carnage = 202922;
local _VictoryRush = 34428;
local _BattleShout = 6673;
local _FrothingBerserker = 215571;

-- Auras
-- Fury
local _Enrage = 184361;
local _FuriousSlashAura = 202539;
local _SuddenDeathAura = 280776;

-- Talents
-- Fury
local _isFuriousSlash = false;
local _isDragonRoar = false;
local _isBladestorm = false;
local _isSiegebreaker = false;
local _isCaranage = false;
local _isFrothingBerserker = false;

MaxDps.Warrior = {};
local talents = {};

function MaxDps.Warrior.CheckTalents()
	MaxDps:CheckTalents();
	talents = MaxDps.PlayerTalents;
	-- Fury
	_isFuriousSlash = MaxDps:HasTalent(_FuriousSlash);	
	_isDragonRoar = MaxDps:HasTalent(_DragonRoar);
	_isBladestorm = MaxDps:HasTalent(_Bladestorm);
	_isSiegebreaker = MaxDps:HasTalent(_Siegebreaker);
	_isCaranage = MaxDps:HasTalent(_Carnage);
	_isFrothingBerserker = MaxDps:HasTalent(_FrothingBerserker);
end

function Warrior:Enable()
	MaxDps:Print(MaxDps.Colors.Info .. 'Warrior [Arms, Fury, Protection]');
	MaxDps.ModuleOnEnable = MaxDps.Warrior.CheckTalents;
	if MaxDps.Spec == 1 then
		MaxDps.NextSpell = Warrior.Arms;
	elseif MaxDps.Spec == 2 then
		MaxDps.NextSpell = Warrior.Fury;
	elseif MaxDps.Spec == 3 then
		MaxDps.NextSpell = Warrior.Protection;
	end;	
	return true;
end


function Warrior:Fury(timeShift, currentSpell, gcd, talents)
	
	local timeShift, currentSpell, gcd = MaxDps:EndCast();

	local rage = UnitPower('player', 1);		
	
	local rampCost = 85;
	
	if _isCaranage then
		rampCost = 75;
	elseif _isFrothingBerserker then
		rampCost = 95; 
	end
	
	local enrage = MaxDps:Aura(_Enrage, timeShift);
	
	-- CoolDowns
	
	MaxDps:GlowCooldown(_Recklessness, MaxDps:SpellAvailable(_Recklessness, timeShift));
	
	if _isSiegebreaker then
		MaxDps:GlowCooldown(_Siegebreaker, MaxDps:SpellAvailable(_Siegebreaker, timeShift));
	end
	
	
	if _isDragonRoar then		
			MaxDps:GlowCooldown(_DragonRoar, MaxDps:SpellAvailable(_DragonRoar, timeShift));			
	elseif _isBladestorm then
		MaxDps:GlowCooldown(_Bladestorm, MaxDps:SpellAvailable(_Bladestorm, timeShift));
	end
	
	-- Rotation	
	
	if _isFuriousSlash then 
		local fs, fsCount, fsTime = MaxDps:Aura(_FuriousSlashAura, timeShift);		
		if MaxDps:SpellAvailable(_FuriousSlash, timeShift) and (fsTime <= 2 or fsCount < 3) then		
			return _FuriousSlash;
		end
	end
	
	if MaxDps:SpellAvailable(_Rampage, timeShift) and (rage >= 95 or (rage >= rampCost and not enrage)) then
		return _Rampage;
	end
	
	if MaxDps:SpellAvailable(_Execute, timeShift) and enrage then
		return _Execute;
	end	
	
	if MaxDps:SpellAvailable(_Bloodthirst, timeShift) and not enrage then
		return _Bloodthirst;
	end	
	
	local _, rbCharges = MaxDps:SpellCharges(_RagingBlow, timeShift)
	if MaxDps:SpellAvailable(_RagingBlow, timeShift) and rbCharges >= 2 then
		return _RagingBlow;
	end	
	
	if MaxDps:SpellAvailable(_Bloodthirst, timeShift) then
		return _Bloodthirst;
	end	
	
	if MaxDps:SpellAvailable(_RagingBlow, timeShift) and rage <= rampCost then
		return _RagingBlow;
	end
	
	if _isFuriousSlash then 
		if MaxDps:SpellAvailable(_FuriousSlash, timeShift) then
			return _FuriousSlash;
		end
	else
		return _Whirlwind;
	end
	
end