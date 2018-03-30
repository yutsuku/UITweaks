function FCF_LoadChatSubTypes(chatGroup)
	if ( chatGroup ) then
		chatGroup = ChatTypeGroup[chatGroup];
	else
		chatGroup = ChatTypeGroup[UIDROPDOWNMENU_MENU_VALUE];
	end
	local checked
	local messageTypeList = FCF_GetCurrentChatFrame().messageTypeList;
	if ( chatGroup ) then
		for index, value in chatGroup do
			checked = nil;
			if ( messageTypeList ) then
				for joinedIndex, joinedValue in messageTypeList do
					if ( value == joinedValue ) then
						checked = 1;
					end
				end
			end
			info = {};
			info.text = getglobal(value);
			info.value = FCF_StripChatMsg(value);
			chatTypeInfo = ChatTypeInfo[FCF_StripChatMsg(value)];
			-- If no color assigned then make it white
			if ( chatTypeInfo ) then
				-- Disable the button and color the text white
				--info.notClickable = 1;
				-- Set to be notcheckable
				--info.notCheckable = 1;
				
				info.checked = checked;
				info.func = FCFMessageTypeDropDown_OnClick;
				-- Set to keep shown on button click
				info.keepShownOnClick = 1;
				
				-- Set the function to be called when a color is set
				info.swatchFunc = FCF_SetChatTypeColor;
				-- Set the swatch color info
				info.hasColorSwatch = 1;
				info.r = chatTypeInfo.r;
				info.g = chatTypeInfo.g;
				info.b = chatTypeInfo.b;
				-- Set function called when cancel is clicked in the colorpicker
				info.cancelFunc = FCF_CancelFontColorSettings;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
			
		end
	end
end

UITweaks.BattlefieldFrame_Update = nil;
UITweaks.BattlefieldFrame_OnEvent = nil;
UITweaks.UIErrorsFrame_OnEvent = nil;
UITweaks.ClockQueue = {};

function UITweaks:Clock_OnUpdate()
	UITweaksClockFrame.timer = UITweaksClockFrame.timer + arg1

	if table.getn(UITweaks.ClockQueue) == 0 then
		UITweaksClockFrame:Hide()
	else
		for index, value in pairs(UITweaks.ClockQueue) do
			if UITweaks.ClockQueue[index].delay ~= nil and UITweaksClockFrame.timer >= UITweaks.ClockQueue[index].delay then
				if type(UITweaks.ClockQueue[index].func) == "function" then
					if type(UITweaks.ClockQueue[index].args) ~= "nil" then
						UITweaks.ClockQueue[index].func(UITweaks.ClockQueue[index].args)
					else
						UITweaks.ClockQueue[index].func()
					end
					tremove(UITweaks.ClockQueue, index)
				end
			end
		end
	end
end

--[[
	obj = {
		delay: time in seconds,
		func: yourFunctionToRun,
		args: {}
	}
]]
function UITweaks:Clock_Add(obj)
	table.insert(UITweaks.ClockQueue, obj)
	UITweaksClockFrame:Show()
end

function UITweaks_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	
	this.isInCombat = false;
	this.displayGarbage = false;
	
	this.fadeInTime = UITweaks.fadeInTime;
	this.fadeOutTime = UITweaks.fadeOutTime;
	this.timer = 0;
	this.counter = 0;
	this.frames = {};
	
	for index,value in ipairs(UITweaks.actionBars) do
		local actionbar = getglobal(value)
		if type(actionbar) == "table" then
			tinsert(this.frames, actionbar)
		end
	end
	
	local mapButtons = UITweaks.minimapButtons;
	UITweaks.minimapButtons = {};
	
	for index,value in ipairs(mapButtons) do
		local button = getglobal(value)
		if type(button) == "table" then
			tinsert(UITweaks.minimapButtons, button)
		end
	end
	
	if UITweaks.hideErrors then
		seterrorhandler(function() end)
	end
	
	-- reposition Minimap Battleground Button to Character -> Honor Frame
	if UITweaks.moveBGButton then
		-- need to hook function, otherwise the icon won't move
		-- there should be a better way but... this works too
		UITweaks.BattlefieldFrame_OnEvent = BattlefieldFrame_OnEvent
		function BattlefieldFrame_OnEvent()
			UITweaks.BattlefieldFrame_OnEvent()
			MiniMapBattlefieldFrame:SetParent(HonorFrame)
			MiniMapBattlefieldFrame:ClearAllPoints()
			MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", "HonorFrame", -32, -38)
			BattlefieldFrame_OnEvent = UITweaks.BattlefieldFrame_OnEvent
		end
	end
	
	-- disable tooltip for players/npcs
	if UITweaks.hidePlayersTooltip then
		GameTooltip:SetScript('OnShow', function()
			if UnitName('mouseover') then
				this:Hide()
			end
		end)
	end
	
	if UITweaks.moveTicketFrame then
		-- moves ticket frame "you have an open ticket"
		-- to bottom of game menu
		TicketStatusFrame:SetParent(GameMenuFrame)
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint("TOP", "GameMenuFrame", "BOTTOM", 0, 0)
		
		HelpFrameOpenTicketText:SetMaxLetters(50000)
	end
	
	if UITweaks.lagMeter then
		do
			local frame = CreateFrame('Frame', nil, UIParent)
			local lagframe = CreateFrame('Frame', nil, GameMenuFrame)
			frame.lagframe = lagframe
			lagframe:SetWidth(256)
			lagframe:SetHeight(20)
			lagframe:SetPoint('BOTTOM', 'GameMenuFrame', 'TOP', 0, 10)

			frame.lag = lagframe:CreateFontString(nil, "BACKGROUND", "GameFontWhite")
			frame.lag:SetWidth(200);
			frame.lag:SetPoint("CENTER", 0, 0)
			frame.lag:SetJustifyH("CENTER")
			
			frame.elapsed = 0
			frame.n = 1
			frame.avg = 0
			frame:SetScript('OnUpdate', function()
				this.elapsed = this.elapsed + arg1
				if this.elapsed >= 29 then
					this.elapsed = 0
					local _,_, lag = GetNetStats()
					this.avg = this.avg + (lag - this.avg) / this.n
					this.n = this.n + 1
					this.lag:SetText('Ping: '..lag..' ms, average: '..ceil(this.avg)..' ms')
				end
			end)
		end
	end
	
	if UITweaks.chatBG then
		do
			local _G = getfenv()
			local f = CreateFrame('Frame', 'LOLFADE', UIParent)
			f:SetFrameStrata('BACKGROUND')
			f:SetPoint('BOTTOM', 'UIParent', 0, 0)
			f:SetPoint('LEFT', 'UIParent', 0, 0)
			f:SetPoint('RIGHT', 'UIParent', 0, 0)
			--f:SetPoint('LEFT', 'UIParent', 'RIGHT', 0, 0)
			f:SetHeight(181)
			f:SetBackdrop({
				bgFile=[[Interface\Addons\UITweaks\textures\background-gradient]],
				tile = false,
			})
			f.ChatFrame_OnEvent = ChatFrame_OnEvent
			f:SetAlpha(0)
			f:Hide()
			
			for i=1,7,1 do
				_G['ChatFrame'..i].__AddMessage = _G['ChatFrame'..i].AddMessage
				_G['ChatFrame'..i].AddMessage = function(self, text, r, g, b, id)
					if self:IsVisible() and text then
						do
							local fadeInfo = {}
							local holdTime
							holdTime = 4
							if text then
								holdTime = 2 * strlen(text) / (strlen(text) / 8)
								if holdTime < 4 then
									holdTime = 4
								end
								
							end
							self:SetTimeVisible(holdTime - 2)
							fadeInfo.mode = 'IN'
							fadeInfo.timeToFade = 0.1
							fadeInfo.startAlpha = f:GetAlpha()
							fadeInfo.endAlpha = 1.0
							fadeInfo.fadeHoldTime = holdTime
							fadeInfo.finishedArg1 = f
							fadeInfo.finishedFunc = function(f)
								local fadeInfo = {}
								fadeInfo.mode = 'OUT'
								fadeInfo.timeToFade = 2
								fadeInfo.startAlpha = 1.0
								fadeInfo.endAlpha = 0.0
								UIFrameFade(f, fadeInfo)
							end
							UIFrameFade(f, fadeInfo)
						end
					end
					return self:__AddMessage(text, r, g, b, id)
				end
			end
			
			--[[function ChatFrame_OnEvent(event)
				if this:IsVisible() then
					if strsub(event, 1, 8) == 'CHAT_MSG' then
						do
							local fadeInfo = {}
							local holdTime
							holdTime = 4
							if arg1 then
								holdTime = 2 * strlen(arg1) / (strlen(arg1) / 8)
								if holdTime < 4 then
									holdTime = 4
								end
								
							end
							this:SetTimeVisible(holdTime - 2)
							fadeInfo.mode = 'IN'
							fadeInfo.timeToFade = 0.1
							fadeInfo.startAlpha = f:GetAlpha()
							fadeInfo.endAlpha = 1.0
							fadeInfo.fadeHoldTime = holdTime
							fadeInfo.finishedArg1 = f
							fadeInfo.finishedFunc = function(f)
								local fadeInfo = {}
								fadeInfo.mode = 'OUT'
								fadeInfo.timeToFade = 2
								fadeInfo.startAlpha = 1.0
								fadeInfo.endAlpha = 0.0
								UIFrameFade(f, fadeInfo)
							end
							UIFrameFade(f, fadeInfo)
						end
					end
				end
				f.ChatFrame_OnEvent(event)
			end]]
		
		end
	end
	
	if UITweaks.tooltipGuild then
	
		local SetUnit
		
		if UITweaks.tooltipClassColor then
			function SetUnit(this,unit,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
				local g = GetGuildInfo(unit)
				local _, class = UnitClass(unit)
				
				this.class_r, this.class_g, this.class_b = nil
				
				if UnitIsPlayer(unit) and class and RAID_CLASS_COLORS[class] then
					this.class_r = RAID_CLASS_COLORS[class].r
					this.class_g = RAID_CLASS_COLORS[class].g
					this.class_b = RAID_CLASS_COLORS[class].b
					GameTooltipTextLeft1:SetTextColor(this.class_r, this.class_g, this.class_b)
				end
				
				if g then
					GameTooltip:AddLine('<'..g..'>', 1, 1, 1)
				end
				
				-- resize tooltip
				GameTooltip:Show()
			end
		else
			function SetUnit(this,unit,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
				local g = GetGuildInfo(unit)
				
				if g then
					GameTooltip:AddLine('<'..g..'>', 1, 1, 1)
				end
				
				-- resize tooltip
				GameTooltip:Show()
			end
		end
		
		-- used by target frame (OnEnter)
		local UITWEAKS_GameTooltip_SetUnit = GameTooltip.SetUnit
		
		GameTooltip.SetUnit = function(this,unit,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
			UITWEAKS_GameTooltip_SetUnit(this,unit,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
			SetUnit(this,unit,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
		end
		
		-- reset class
		local OnShow = GameTooltip:GetScript('OnShow')
		GameTooltip:SetScript('OnShow', function()
			this.class_r, this.class_g, this.class_b = nil
			if ( OnShow ) then
				OnShow()
			end
		end)
		
		-- dirty hack for coloring player names (target frame OnEnter)
		local UITWEAKS_GameTooltipTextLeft1_SetTextColor = GameTooltipTextLeft1.SetTextColor
		
		GameTooltipTextLeft1.SetTextColor = function(this, r, g, b, a)
			if ( GameTooltip.class_r and GameTooltip.class_g and GameTooltip.class_b ) then
				UITWEAKS_GameTooltipTextLeft1_SetTextColor(this, GameTooltip.class_r, GameTooltip.class_g, GameTooltip.class_b, a)
				--DEFAULT_CHAT_FRAME:AddMessage(format('class: %f, %f, %f', r, g, b))
			else
				UITWEAKS_GameTooltipTextLeft1_SetTextColor(this, r, g, b, a)
				--DEFAULT_CHAT_FRAME:AddMessage(format('normal: %f, %f, %f', r, g, b))
			end
		end
		
		-- event driven update
		local f = CreateFrame('Frame')
		f:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
		f:SetScript('OnEvent', function()
			GameTooltip.class_r, GameTooltip.class_g, GameTooltip.class_b = nil
			SetUnit(GameTooltip, 'mouseover')
		end)
	end
	
	if UITweaks.joinAsGroupButton then
		UITweaks.BattlefieldFrame_Update = BattlefieldFrame_Update;
		function BattlefieldFrame_Update()
			UITweaks.BattlefieldFrame_Update();
			BattlefieldFrameGroupJoinButton:Show();
		end
	end
	
	if UITweaks.filterCommonErrors then
		UITweaks.UIErrorsFrame_OnEvent = UIErrorsFrame_OnEvent;
		local messages = UITweaks.filterMessages
		
		function UIErrorsFrame_OnEvent(event, message)
			for i,k in ipairs(messages) do
				if message == messages[i] then
					return
				end
			end
			UITweaks.UIErrorsFrame_OnEvent(event, message)
		end
		
	end
	
	if UITweaks.easyBandages then
		SlashCmdList["BANDAGE_SLASHCMD"] = function()
		
			-- casts proper bandage depends on which zone
			-- the player is in, or just normal one if he's out of special ones
			-- or none if there aren't any at all
			
			local bandage_warsong, bandage_arathi, bandage_alterac,
				bandage_normal,
				wsg,ab,av,bandage,zone,
				bandage_normal_b,bandage_normal_s,
				haveBGBandage;
				
			local function id(link)
				if not link then return 0 end
				local a,b = string.find(link,"item:%d+:")
				if not a or not b then return 0 end
				return tonumber(string.sub(link,a+5,b-1))
			end

			bandage_warsong = 19066 -- Warsong Gulch Runecloth Bandage
			bandage_arathi = 20234 -- Defiler's Runecloth Bandage
			bandage_alterac = 19307 -- Alterac Heavy Runecloth Bandage
			bandage_normal = 14530 -- Heavy Runecloth Bandage
			
			-- may need translation for non-english clients
			wsg = "Warsong Gulch"
			ab = "Arathi Basin"
			av = "Alterac Valley"
			
			haveBGBandage = false

			zone = GetRealZoneText()

			if zone == wsg then
				bandage = bandage_warsong
			elseif zone == ab then
				bandage = bandage_arathi
			elseif zone == av then
				bandage = bandage_alterac
			else
				bandage = bandage_normal
			end

			for b=0,4 do
				for s=1,GetContainerNumSlots(b) do
					if id(GetContainerItemLink(b,s)) == bandage_normal then
						bandage_normal_b = b;
						bandage_normal_s = s;
					end
					if id(GetContainerItemLink(b,s)) == bandage then
						haveBGBandage = true
						UseContainerItem(b,s);
						--DEFAULT_CHAT_FRAME:AddMessage("UITweaks: found ID-" .. bandage .. " in bag " .. b .. " at slot " .. s)
						b=4
						break
					end
				end
			end
			
			if haveBGBandage == false and bandage_normal_b and bandage_normal_s then
				UseContainerItem(bandage_normal_b,bandage_normal_s);
			end
			
		end
		
		SLASH_BANDAGE_SLASHCMD1 = '/heal'
		SLASH_BANDAGE_SLASHCMD2 = '/bandage'
	end
    
	if UITweaks.enableBGCalendar then
		local localOffset = (24-GetGameTime()) - (24 - date("%H"))
		local offset
		
		if localOffset > 0 then
			offset = -(localOffset * 3600)
		elseif localOffset < 0 then
			offset = abs(localOffset) * 3600
		else
			offset = 0
		end
		
		local now = time() + offset
		local date = date

		local wsg_start, ab_start, av_start
		local occurence = 60 * 60 * 24 * 28 -- 28 days
		local length = 60 * 60 * 24 * 4 + 28800 -- 4 days, 8 hours

		ab_start = 1470362400 -- 16/08/26 02:00
		av_start = 1471572000 -- 16/08/05 02:00
		wsg_start = 1472176800 -- 16/08/19 02:00

		local current_wsg, current_ab, current_av
		local next_wsg, next_ab, next_av

		next_wsg = wsg_start
		next_ab = ab_start
		next_av = av_start

		while true do
			if now-next_wsg < occurence and next_wsg >= now-length then
				if next_wsg <= now then
					current_wsg = next_wsg
					next_wsg = next_wsg + occurence
				end
				break
			else
				next_wsg = next_wsg + occurence
			end
		end

		while true do
			if now-next_ab < occurence and next_ab >= now-length then
				if next_ab <= now then
					current_ab = next_ab
					next_ab = next_ab + occurence
				end
				break
			else
				next_ab = next_ab + occurence
			end
		end

		while true do
			if now-next_av < occurence and next_av >= now-length then
				if next_av <= now then
					current_av = next_av
					next_av = next_av + occurence
				end
				break
			else
				next_av = next_av + occurence
			end
		end
		
		local calendar = {};
		
		calendar.dateFormat = "!%Y-%m-%d %H:%M"; -- UTC
		calendar.humanFormat = {
			months = "In %d months",
			month = "In next month",
			weeks = "In %d weeks",
			week = "In next week",
			days = "In %d days",
			day = "Tomorrow",
			hours = "In %d hours",
			hour = "In less than an hour",
			minutes = "In %d minutes",
			minute = "In less than a minute",
			seconds = "In %d seconds",
			second = "In less than a second",
			now = "Currently in progress",
		};
		
		calendar.frame = CreateFrame("Frame", nil, HonorFrame);
		calendar.frame:SetWidth(256);
		calendar.frame:SetHeight(128);
		calendar.frame:SetPoint("TOPLEFT", "HonorFrame", "TOPRIGHT", -35, -32);
		calendar.frame:EnableMouse(true);
		calendar.frame:SetHitRectInsets(9, 90, 4, 40);
		
		calendar.background = calendar.frame:CreateTexture(nil, "BACKGROUND");
		calendar.background:SetAllPoints(calendar.frame);
		calendar.background:SetTexture("Interface\\MoneyFrame\\UI-MoneyFrame2");
		
		calendar.title = calendar.frame:CreateFontString(nil, "OVERLAY", "GameFontWhite");
		calendar.title:SetWidth(138);
		calendar.title:SetPoint("TOPLEFT", 18, -16);
		calendar.title:SetJustifyH("CENTER");
		calendar.title:SetText("Bonus Weekends");
		
		local function GetHumanTime(timestamp)
			local function round(number)
				return tonumber(format("%.0f", number));
			end
			
			local now = time();
			local t = timestamp - now;
			local minute = 60;
			local hour = minute * 60;
			local day = hour * 24;
			local week = day * 7;
			local month = week * 4; -- ... more or less, doesn't matter to humans
			
			if t <= 0 then
				return calendar.humanFormat.now
			elseif t < minute then
				if t > 1 then
					return format(calendar.humanFormat.seconds, t);
				else
					return calendar.humanFormat.second;
				end
			elseif t < hour then
				t = round(t / minute)
				if t > 1 then
					return format(calendar.humanFormat.minutes, t);
				else
					return calendar.humanFormat.minutee;
				end
			elseif t < day then
				t = round(t / hour)
				if t > 1 then
					return format(calendar.humanFormat.hours, t);
				else
					return calendar.humanFormat.hour;
				end
			elseif t < week then
				t = round(t / day)
				if t > 1 then
					return format(calendar.humanFormat.days, t);
				else
					return calendar.humanFormat.day;
				end
			elseif t < month then
				t = round(t / week)
				if t > 1 then
					return format(calendar.humanFormat.weeks, t);
				else
					return calendar.humanFormat.week;
				end
			elseif t < month then
				t = round(t / month)
				if t > 1 then
					return format(calendar.humanFormat.months, t);
				else
					return calendar.humanFormat.month;
				end
			end
			
		end
		
		local function CreateLabel(parent)
			if not parent.labelCount then
				parent.labelCount = 0
			end
			
			parent.labelCount = parent.labelCount + 1
			
			local label = "label" .. parent.labelCount;
			local prev = "label" .. parent.labelCount-1;
			
			parent[label] = CreateFrame("Frame", nil, parent);
	
			parent[label]:SetWidth(138);
			parent[label]:SetHeight(11);
			if parent.labelCount > 1 then
				parent[label]:SetPoint("TOPLEFT", parent[prev], "BOTTOMLEFT", 0, -2);
			else
				parent[label]:SetPoint("TOPLEFT", 18, -38);
			end
			parent[label]:EnableMouse(true);
			
			parent[label].tooltip = nil;
			parent[label].bg = parent[label]:CreateTexture(nil, "BACKGROUND");
			parent[label].bg:SetAllPoints(parent[label]);
			parent[label].bg:SetTexture(0, 0, 0, 0.3);
			
			parent[label].text = parent[label]:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
			parent[label].text:SetWidth(104);
			parent[label].text:SetPoint("LEFT", 0, 0);
			parent[label].text:SetJustifyH("LEFT");
			
			parent[label].value = parent[label]:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
			parent[label].value:SetWidth(64);
			parent[label].value:SetPoint("RIGHT", 0, 0);
			parent[label].value:SetJustifyH("RIGHT");
			
			parent[label].elapsed = 0;
			
			parent[label]:SetScript("OnEnter", function()
				if this.tooltip then
					this.tooltipUpdate = true
					GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
					GameTooltip:SetText(this.tooltip, 1.0,1.0,1.0 );
				end
			end)
			
			parent[label]:SetScript("OnLeave", function()
				if this.tooltip then
					this.tooltipUpdate = nil
					GameTooltip:Hide();
				end
			end)
			
			parent[label]:SetScript("OnUpdate", function()
				this.elapsed = this.elapsed + arg1
				if this.elapsed > 1 and this.tooltipUpdate then
					this.elapsed = 0
					this.tooltip = "Starts: " .. GetHumanTime(this.next) .. "\nEnds: " .. date(calendar.dateFormat, this.next + length)

					GameTooltip:SetText(this.tooltip, 1.0,1.0,1.0 );
				end
			end)
			
			return parent[label];
		end
		
		calendar.events = {
			{
				name = "WSG",
				next = current_wsg or next_wsg,
				inProgress = current_wsg,
				tooltip = "premade, again",
			},
			{
				name = "AB",
				next = current_ab or next_ab,
				inProgress = current_ab,
				tooltip = "RUSH BS GUYS",
			},
			{
				name = "AV",
				next = current_av or next_av,
				inProgress = current_av,
				tooltip = "just let them win already",
			},
		};
		
		sort(calendar.events, function(a, b)
			return a.next < b.next;
		end)
		
		local label1 = CreateLabel(calendar.frame);
		local label2 = CreateLabel(calendar.frame);
		local label3 = CreateLabel(calendar.frame);
		
		
		if calendar.events[1].inProgress then
			calendar.events[1].next = calendar.events[1].inProgress;
			label1.text:SetTextColor(0.1, 1.0, 0.1);
			label1.value:SetTextColor(0.1, 1.0, 0.1);
		end
		
		if calendar.events[2].inProgress then
			calendar.events[2].next = calendar.events[2].inProgress;
			label2.text:SetTextColor(0.1, 1.0, 0.1);
			label2.value:SetTextColor(0.1, 1.0, 0.1);
		end
		
		if calendar.events[3].inProgress then
			calendar.events[3].next = calendar.events[3].inProgress;
			label3.text:SetTextColor(0.1, 1.0, 0.1);
			label3.value:SetTextColor(0.1, 1.0, 0.1);
		end
		
		label1.text:SetText(date(calendar.dateFormat, calendar.events[1].next));
		label1.value:SetText(calendar.events[1].name);
		label1.tooltip = GetHumanTime(calendar.events[1].next);
		label1.next = calendar.events[1].next;
		
		label2.text:SetText(date(calendar.dateFormat, calendar.events[2].next));
		label2.value:SetText(calendar.events[2].name);
		label2.tooltip = GetHumanTime(calendar.events[2].next);
		label2.next = calendar.events[2].next;
		
		label3.text:SetText(date(calendar.dateFormat, calendar.events[3].next));
		label3.value:SetText(calendar.events[3].name);
		label3.tooltip = GetHumanTime(calendar.events[3].next);
		label3.next = calendar.events[3].next;

		calendar.frame:Show();
	end
	
	if UITweaks.showAllBuffs then
		local _G = getfenv()
		local btn_suffix = 24
		local __this = this
		for i = 16, 31, 1 do
			local fontString = _G['BuffFrame']:CreateFontString('BuffButton'..btn_suffix..'Duration', 'ARTWORK', 'BuffButtonDurationTemplate')
			local button = CreateFrame('Button', 'BuffButton'..btn_suffix, BuffFrame, 'BuffButtonHelpful')
			button:SetID(i)
			--DEFAULT_CHAT_FRAME:AddMessage(format('creating %s (ID: %d)', 'BuffButton'..btn_suffix, i))
			if i == 16 then
				button:SetPoint('RIGHT', BuffButton7, 'LEFT')
			else
				button:SetPoint('RIGHT', _G['BuffButton'..(btn_suffix-1)], 'LEFT')
			end
			this = button
			BuffButton_OnLoad()
			btn_suffix = btn_suffix + 1
		end
		this = __this
	end
	
	if UITweaks.bigDebuffs then
		local _G = getfenv()
		_G['BuffButton16']:SetScale(2)
		_G['BuffButton17']:SetScale(2)
		_G['BuffButton18']:SetScale(2)
		_G['BuffButton19']:SetScale(2)
		_G['BuffButton20']:SetScale(2)
		_G['BuffButton21']:SetScale(2)
		_G['BuffButton22']:SetScale(2)
		_G['BuffButton23']:SetScale(2)
	end
	
	-- Bardenter lazy support
	if Bartender then
		UTTweaks_BartendeAceEvent_FullyInitialized_org = Bartender.AceEvent_FullyInitialized;
		Bartender.AceEvent_FullyInitialized = function()
			Bartender:EnableAllBars();
			UITweaks_OnEvent("DISPLAY_GARBAGE", UITweaks.displayGarbage);
			Bartender.AceEvent_FullyInitialized = UTTweaks_BartendeAceEvent_FullyInitialized_org;
		end
	else
		UITweaks_OnEvent("DISPLAY_GARBAGE", UITweaks.displayGarbage);
	end
	
	
	if UITweaks.debugEvents then
		local events = CreateFrame('Frame')
		events.active = false
		function events:OnEvent()
			DEFAULT_CHAT_FRAME:AddMessage(event)
			if arg1 and strlen(arg1) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg1: "' .. arg1 .. '"') end
			if arg2 and strlen(arg2) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg2: "' .. arg2 .. '"') end
			if arg3 and strlen(arg3) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg3: "' .. arg3 .. '"') end
			if arg4 and strlen(arg3) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg4: "' .. arg4 .. '"') end
			if arg5 and strlen(arg3) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg5: "' .. arg5 .. '"') end
			if arg6 and strlen(arg3) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg6: "' .. arg6 .. '"') end
			if arg7 and strlen(arg3) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg7: "' .. arg7 .. '"') end
			if arg8 and strlen(arg3) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg8: "' .. arg8 .. '"') end
			if arg9 and strlen(arg3) > 0 then DEFAULT_CHAT_FRAME:AddMessage('- arg9: "' .. arg9 .. '"') end
		end
		events:SetScript('OnEvent', function()
			this:OnEvent(this)
		end)
		SLASH_UITWEAKSDEBUG1, SLASH_UITWEAKSDEBUG2 = '/debugevents', '/uitweaksdebug'
		function SlashCmdList.UITWEAKSDEBUG(arg)
			if events.active then
				events.active = false
				events:UnregisterAllEvents()
				DEFAULT_CHAT_FRAME:AddMessage('disabled event logging')
			else
				events.active = true
				events:RegisterAllEvents()
				DEFAULT_CHAT_FRAME:AddMessage('enabled event logging')
			end
		end
	end
end

function UITweaks_OnEvent(event, arg1, arg2)
	if ( event == "ADDON_LOADED" and arg1 == "UITweaks" ) then
		if UITweaks.hideBuffs then
			BuffFrame:Hide();
			TemporaryEnchantFrame:Hide();
		end
		for i,k in ipairs(this.frames) do
			this.frames[i]:SetAlpha(0);
			this.frames[i]:Hide();
		end
		-- minimap buttons
		for i,k in ipairs(UITweaks.minimapButtons) do
			UITweaks.minimapButtons[i]:SetAlpha(0);
			UITweaks.minimapButtons[i]:Hide();
		end
		Minimap:SetScript("OnEnter", UITweaks_Minimap_OnEnter)
		Minimap:SetScript("OnLeave", UITweaks_Minimap_OnLeave)
	end
	
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if UITweaks.hideBuffs then
			BuffFrame:Hide();
			TemporaryEnchantFrame:Hide();
		end
		for i,k in ipairs(this.frames) do
			this.frames[i]:SetAlpha(0);
			this.frames[i]:Hide();
		end
		-- minimap buttons
		for i,k in ipairs(UITweaks.minimapButtons) do
			UITweaks.minimapButtons[i]:SetAlpha(0);
			UITweaks.minimapButtons[i]:Hide();
		end
	end
	
	if ( event == "PLAYER_REGEN_DISABLED" ) then
		this.isInCombat = true;
		UITweaks_OnEvent("DISPLAY_GARBAGE", true);
	end
	
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		this.isInCombat = false;
		UITweaks_OnEvent("DISPLAY_GARBAGE", false);
	end
	
	if ( event == "UNIT_HEALTH" and arg1 == "player" ) then
		local max_health = UnitHealthMax("player");
		local health = UnitHealth("player");
		local percent = ceil((health / max_health)*100)
		if ( percent >= UITweaks.hideBarsHPPct ) then
			this.recoveringHP = false;
			if ( this.isInCombat ) then
				-- never hide garbage when in combat
				this.displayGarbage = true;
			else
				this.displayGarbage = false;
			end
		else
			this.recoveringHP = true;
			this.displayGarbage = true;
			--DEFAULT_CHAT_FRAME:AddMessage(health .. "/" .. max_health);
		end

		if tostring(this.recoveringHP_old) ~= tostring(this.recoveringHP) then
			this.recoveringHP_old = tostring(this.recoveringHP)
			UITweaks_OnEvent("DISPLAY_GARBAGE", this.displayGarbage);
		end
	end
	
	if ( event == "DISPLAY_GARBAGE" ) then
		this = UITweaksFrame; -- because event send from hooked Bartender function
		
		if ( this.recoveringHP ) then
		
		else
			if ( this.isShowingLock ) then -- release the lock at full hp, allowing frame to hide
				this.isShowingLock = false;
			end
		end
		
		if ( arg1 ) then
			-- display garbage
			if ( not this.isShowing and not this.isShowingLock ) then
				this.isShowing = true;
				this.isHiding = false;
				if ( this.recoveringHP ) then
					this.isShowingLock = true;
				end
				--DEFAULT_CHAT_FRAME:AddMessage("Displaing garbage");
				this.timer = 0;
				this.counter = this.fadeInTime;
				this.mode = "FadeIn";
				for i,k in ipairs(this.frames) do
					this.frames[i]:SetAlpha(0);
					this.frames[i]:Show();
				end
				this.allFramesShown = true;
				this:Show();
			end
		else
			-- hide garbage			
			if ( not this.isHiding and not this.isShowingLock ) then
				this.isShowing = false;
				this.isHiding = true;
				--DEFAULT_CHAT_FRAME:AddMessage("Hiding garbage");
				this.timer = 0;
				this.counter = this.fadeOutTime;
				this.mode = "FadeOut";
				for i,k in ipairs(this.frames) do
					this.frames[i]:SetAlpha(1);
					this.frames[i]:Show();
				end
				this.allFramesShown = false;
				this:Show();
			end
		end
	end
	
end

function UITweaks_OnUpdate(arg1)
	this.timer = this.timer + arg1;
	--DEFAULT_CHAT_FRAME:AddMessage("UITweaks_OnUpdate: " .. this.timer);
	
	if ( this.timer > this.counter ) then
		if ( this.mode == "FadeIn" ) then
			-- fade in animation finished
			--DEFAULT_CHAT_FRAME:AddMessage("fade in finished");
			this.isShowing = false;
			this.timer = 0;
			this.counter = 0;
			this:Hide();
		elseif ( this.mode == "FadeOut" ) then
			-- fade out animation finished
			--DEFAULT_CHAT_FRAME:AddMessage("fade out finished");
			for i,k in ipairs(this.frames) do
				this.frames[i]:Hide();
			end
			this.isHiding = false;
			this.timer = 0;
			this.counter = 0;
			this:Hide();
		else
			--DEFAULT_CHAT_FRAME:AddMessage("unknow fade finished (took " .. this.counter .. " second(s))");
			this.timer = 0;
			this.counter = 0;
			this:Hide();
		end
	end
	
	if ( this.mode == "FadeIn" ) then
		--this:SetAlpha( 1 - ( ( (this.timer/this.counter) * 100) / 100)  );
		local alpha = (this.timer/this.counter);
		--DEFAULT_CHAT_FRAME:AddMessage(alpha);
		for i,k in ipairs(this.frames) do
			this.frames[i]:SetAlpha(alpha);
			
		end
	elseif ( this.mode == "FadeOut" ) then
		--this:SetAlpha(( (this.timer/this.counter) * 100) / 100);
		local alpha = 1 - (this.timer/this.counter);
		--DEFAULT_CHAT_FRAME:AddMessage(alpha);
		for i,k in ipairs(this.frames) do
			this.frames[i]:SetAlpha(alpha);
		end
	end
	
end

function UITweaks_Minimap_OnEnter()
	for i,k in ipairs(UITweaks.minimapButtons) do
		local f = getglobal("UITweaksAnimationFrame" .. i)
		if f then f:Hide() end
		UITweaks.minimapButtons[i]:SetAlpha(1);
		UITweaks.minimapButtons[i]:Show();
	end
end

function UITweaks_Minimap_OnLeave()
	for i,k in ipairs(UITweaks.minimapButtons) do
		local obj = {
			delay = 1,
			func = function(index)
				do
					local f = getglobal("UITweaksAnimationFrame" .. index) or CreateFrame("Frame", "UITweaksAnimationFrame" .. index);
					f.time = 0;
					f.animationTime = UITweaks.minimapFadeOutTime;
					
					f:SetScript("OnUpdate", function()
						this.time = this.time + arg1
						local opacity
						opacity = 1 - (this.time / this.animationTime)
						UITweaks.minimapButtons[index]:SetAlpha(opacity);
						if this.time >= this.animationTime then
							UITweaks.minimapButtons[index]:Hide();
							this:Hide()
						end
					end)
					
					f:Show()
				end
			end,
			args = i,
		}
		UITweaks:Clock_Add(obj)
	end
end

