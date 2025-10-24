 
 
ExAutoCSHS = {
  ver = 1, 
  Class = "",
  Player = "", 
  Loaded = false,
  CurrentOpenMode =0,
  CurrentPrioMode =0,
  CurrentPrioZeal =0, 
  OpenModeAuto 	= 0,
  OpenModeCS 	= 1,
  OpenModeHS 	= 2,
  PrioModeAuto 	= 0,
  PrioModeCS 	= 1,
  PrioModeHS 	= 2,
  Zeal1T = {TS = 0, D = 0},
  Zeal2T =  {TS = 0, D = 0},
  Zeal3T =  {TS = 0, D = 0},
  ZealSpacerT =  {TS = 0, D = 0},
  MightT =  {TS = 0, D = 0},
  MightSpacerT =  {TS = 0, D = 0}


}


function ExAutoCSHS:Onload()

	_ , ExAutoCSHS.Class = UnitClass("player");
	
	if ExAutoCSHS.Class ~= "PALADIN" then
		return
	end
	ExAutoCSHS.Player = (UnitName("player").." of "..GetCVar("realmName"))
 
	if not ExAutoCSHS.Loaded then
  		DEFAULT_CHAT_FRAME:AddMessage("ExAutoCSHS v" .. ExAutoCSHS.ver .. " loaded \n use /AutoCS [openCS/openHS/openAuto] [moreCS/moreHS/moreAuto] [prioZeal] [exorcism]", 0.9, 0.8, 0.0); 
		ExAutoCSHS.Loaded = true
	end
	SLASH_exCSHS1 = "/AutoCS" 
	SLASH_exCSHS2 = "/AutoHS" 
	SlashCmdList["exCSHS"] = function(msg) ExAutoCSHS:EvalCommand(msg)  end
 
 end
 
 
function ExAutoCSHS:EvalCommand(msg) 
	 
	 local opnm = 0
	 local prm = 0
	 local exo =   0
	 local pz =   0
	 if string.find(string.lower(msg),"opencs") then  opnm = ExAutoCSHS.OpenModeCS end
	 if string.find(string.lower(msg),"openhs") then  opnm = ExAutoCSHS.OpenModeHS end
	 if string.find(string.lower(msg),"morecs") then  prm = ExAutoCSHS.PrioModeCS end
	 if string.find(string.lower(msg),"morehs") then  prm = ExAutoCSHS.PrioModeHS end
	 if string.find(string.lower(msg),"priozeal") then pz = 1  end
	 if string.find(string.lower(msg),"exo") then exo = 1  end
	ExAutoCSHS:Eval( opnm, prm, pz,exo);  
end
 
function ExAutoCSHS:SetTimer(Timervals, Duration) 

Timervals.TS = GetTime()
Timervals.D = Duration
end
function ExAutoCSHS:GetTimer(Timervals)
  return GetTime() < Timervals.D+Timervals.TS
end
 
function ExAutoCSHS:OpensWithCS(OpenMode,PrioMode)

	
	if OpenMode == ExAutoCSHS.OpenModeCS then   return true end
	if OpenMode == ExAutoCSHS.OpenModeHS then   return false end
	
   return not ExAutoCSHS:MoreHS(PrioMode)
end
function ExAutoCSHS:HasOffhand()
	return GetInventoryItemQuality("player", 17) ~= nil
end
function ExAutoCSHS:MoreHS(PrioMode)

	if PrioMode == ExAutoCSHS.PrioModeCS then return false end
	if PrioMode == ExAutoCSHS.PrioModeHS then return true end
	local hasoffhand = ExAutoCSHS:HasOffhand()
	 return hasoffhand
end
function ExAutoCSHS:WarnHS()
    -- PlaySound("AuctionWindowClose", "master");  
end
function ExAutoCSHS:WarnCS()
    -- PlaySound("AuctionWindowOpen", "master");
end
function ExAutoCSHS:Warn()
    -- PlaySound("ITEM_REPAIR", "master");
end
function ExAutoCSHS:OnSpellCast(arg1)
                if (string.find(arg1, "Holy Strike") ~= nil  ) then 
                    if not ExAutoCSHS:MoreHS(ExAutoCSHS.CurrentPrioMode) then ExAutoCSHS:SetTimer(ExAutoCSHS.MightSpacerT , 13) end
                    ExAutoCSHS:SetMight(ExAutoCSHS.CurrentOpenMode,ExAutoCSHS.CurrentPrioMode)
                    ExAutoCSHS:WarnHS()
                end
                if (string.find(arg1, "Crusader Strike") ~= nil  ) then 
                    ExAutoCSHS:SetZeal(ExAutoCSHS.CurrentPrioMode)
                    if (  EvalCSThrottle() )  then ExAutoCSHS:SetTimer(ExAutoCSHS.ZealSpacerT,22)   ExAutoCSHS:Log("zeal timer set")  end
                    ExAutoCSHS:WarnCS()
                end
end
 
 
function EvalCSThrottle()
	if (ExAutoCSHS.CurrentPrioZeal == 1 and ExAutoCSHS:GetZeal()<3) then
		return false
	end
	if (ExAutoCSHS:MoreHS(ExAutoCSHS.CurrentPrioMode)) then
		return true
	end 
	return true	
end
 
function ExAutoCSHS:Log(m)
--DEFAULT_CHAT_FRAME:AddMessage(m)
end

function ExAutoCSHS:Eval( )   ExAutoCSHS:Eval(0,0,0,0) end 
function ExAutoCSHS:Eval(OpenMode,PrioMode,PrioZeal,UseExorcism)  
	ExAutoCSHS.CurrentOpenMode= OpenMode  
	ExAutoCSHS.CurrentPrioMode= PrioMode 
	ExAutoCSHS.CurrentPrioZeal= PrioZeal
    if not ExAutoCSHS:CanCast() then
        return false
    end
	
	if ( ExAutoCSHS:GetHSCD() == 0 )then 
		local stacks = ExAutoCSHS:GetZeal()
		if ( ExAutoCSHS:OpensWithCS(ExAutoCSHS.CurrentOpenMode,ExAutoCSHS.CurrentPrioMode) or ExAutoCSHS:GetMight()) then
			if stacks>0 then
		  
					if stacks < 3 and not ExAutoCSHS:MoreHS(ExAutoCSHS.CurrentPrioMode) then
						if ExAutoCSHS:GetMight() or ExAutoCSHS.CurrentPrioZeal == 1 then
							ExAutoCSHS:Log("stacks ExAutoCSHS:GetMight()")
							ExAutoCSHS:CS()
						else
							ExAutoCSHS:HS()
						end
					else
						if ExAutoCSHS:GetTimer(ExAutoCSHS.MightSpacerT) and not (ExAutoCSHS:MoreHS(ExAutoCSHS.CurrentPrioMode)  ) then
							ExAutoCSHS:Log("InternalZorlenMiscTimer and not ExAutoCSHS:MoreHS()")
							ExAutoCSHS:CS()
						else
							ExAutoCSHS:HS()
						end
					end
 
			else
				ExAutoCSHS:Log("no stacks")
			ExAutoCSHS:CS()
			end 
		else
			ExAutoCSHS:HS()
		end
	else

		if (UseExorcism) then
			local targettype =  UnitCreatureType("target")
			if targettype == "Undead" or targettype == "Demon" then
				ExAutoCSHS:Excorcism()
			end
		end
	end
end
 
function ExAutoCSHS:GetZeal()
    if ExAutoCSHS:GetTimer(ExAutoCSHS.Zeal3T) then
        return 3
    end
    if ExAutoCSHS:GetTimer(ExAutoCSHS.Zeal2T) then
        return 2
    end
    if ExAutoCSHS:GetTimer(ExAutoCSHS.Zeal1T) then
        return 1
    end
    return 0
end

function ExAutoCSHS:SetZeal(PrioMode)
    local zeal = ExAutoCSHS:GetZeal()
    local u = 24 
    if ExAutoCSHS:MoreHS(PrioMode) then u = 30 end
    ExAutoCSHS:SetTimer(ExAutoCSHS.Zeal1T,u)
    if (zeal > 0) then
        ExAutoCSHS:SetTimer(ExAutoCSHS.Zeal2T,u)
    end    
    if (zeal > 1) then
        ExAutoCSHS:SetTimer(ExAutoCSHS.Zeal3T,u)
    end
end

function ExAutoCSHS:GetMight()
    return ExAutoCSHS:GetTimer(ExAutoCSHS.MightT)  
end
function ExAutoCSHS:SetMight(OpenMode,PrioMode)
    local u = 14 
    if (ExAutoCSHS:OpensWithCS(OpenMode,PrioMode)) and not ExAutoCSHS:MoreHS(PrioMode) then u = 20 end
    ExAutoCSHS:SetTimer(ExAutoCSHS.MightT ,u)
end
function ExAutoCSHS:CS()
local lm = true
local s = true
if(UnitMana("player")<40 and UnitMana("player")>=20) then CastSpellByName("Crusader Strike(Rank 1)",false) 
    else if(UnitMana("player")<130) then CastSpellByName("Crusader Strike(Rank 2)",false)
        else if(UnitMana("player")<170) then CastSpellByName("Crusader Strike(Rank 3)",false)
            else if(UnitMana("player")<200) then CastSpellByName("Crusader Strike(Rank 4)",false)
                else  if(UnitMana("player")>200) then CastSpellByName("Crusader Strike(Rank 5)",false) ; lm = false
                    else s= false
                end
            end 
        end
    end
 CastSpellByName("Crusader Strike",false)
 end
 
function ExAutoCSHS:Excorcism()
 
if(UnitMana("player")<135 and UnitMana("player")>=85) then CastSpellByName("Exorcism(Rank 1)",false) 
    else if(UnitMana("player")<180) then CastSpellByName("Exorcism(Rank 2)",false)
        else if(UnitMana("player")<235) then CastSpellByName("Exorcism(Rank 3)",false)
            else if(UnitMana("player")<285) then CastSpellByName("Exorcism(Rank 4)",false)
                else  if(UnitMana("player")<345) then CastSpellByName("Exorcism(Rank 5)",false)  
                    else  CastSpellByName("Exorcism",false) end 
                end
            end 
        end
    end
 end
 CastSpellByName("Exorcism",false) 
 if (lm) then ExAutoCSHS:Warn() end
end


function ExAutoCSHS:HS()
local lm = true
local s = true
if(UnitMana("player")<12  and UnitMana("player")>=5) then CastSpellByName(" Holy Strike(Rank 1)") 
    else if(UnitMana("player")<25) then CastSpellByName("Holy Strike(Rank 2)")
    else if(UnitMana("player")<38) then CastSpellByName("Holy Strike(Rank 3)")
    else if(UnitMana("player")<51) then CastSpellByName("Holy Strike(Rank 4)")
    else if(UnitMana("player")<64) then CastSpellByName("Holy Strike(Rank 5)")
    else if(UnitMana("player")<75) then CastSpellByName("Holy Strike(Rank 6)")
    else if(UnitMana("player")<90) then CastSpellByName("Holy Strike(Rank 7)")
    else if(UnitMana("player")>90) then  CastSpellByName("Holy Strike(Rank 8)") ; lm=false
    else s = false
end
            end 
        end
    end
 end
end
end
end
CastSpellByName("Holy Strike") 
 if (lm) then ExAutoCSHS:Warn() end
end

 

function ExAutoCSHS:CanCast()
local u = "target"
 return  HasFullControl() and  UnitCanAttack("player","target")   
end
function ExAutoCSHS:GetHSCD() 
	local id = nil
 
		local SpellCount = 0
		local ReturnName = nil  
			while "Holy Strike" ~=  ReturnName  do
				SpellCount = SpellCount + 1
				ReturnName, _ = GetSpellName(SpellCount, "spell")
				if not ReturnName then
					break
				end 
			end	
		if "Holy Strike" ==  ReturnName then
			id = SpellCount
			ExAutoCSHS:Log( (ReturnName or "nil") .. id) 
		end
 
	return GetSpellCooldown(id,"spell")
end
