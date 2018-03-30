local _msg = [[/say Lurk
/in 2 Blessing of Sleeping Mods
/in 4 Filter Ward
/in 5 Captcha Ward: Pass
/in 7 Spoiler Abuse
/in 8 Greater Ban Potential
/in 10 Greentext
/in 11 False Data: IP
/in 13 Buzzwords
/in 14 Samefag Intuition
/in 15 Greater Strawman
/in 17 Mantle of Gets
/in 18 Cherrypick
/in 20 Feign Retardation
/in 21 Announce Sage
/in 22 Ironic Emotes
/in 24 Australian Power
/in 25 Greater Banter
/in 26 Tripfag Aura
/in 28 Derailment
/in 29 Bait Up
/in 30 Greater False Flag
/in 32 /say  /pol/ Essence
/in 33 Enhanced Maximized Post: Reaction Image
/in 37 Enhanced Post: Meme Misuse
/in 39 Enhanced Maximized Boosted Post: Logical Fallacy
/in 46 Now then, let us begin.]]

function splitStringBy(str, pat)
   local t = {n = 0}
   local fpat = "(.-)"..pat
   local last_end = 1
   local s,e,cap = string.find(str, fpat, 1)
   while s ~= nil do
      if s~=1 or cap~="" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s,e,cap = string.find(str, fpat, last_end)
   end
   if last_end<=string.len(str) then
      cap = string.sub(str,last_end)
      table.insert(t,cap)
   end
   return t
end

function shitpost()
	local text = ChatFrameEditBox:GetText();
	local bodyLines = splitStringBy(_msg,'[\n]+')
	
	for i,v in ipairs(bodyLines) do
	
		ChatFrameEditBox:SetText(v);
		ChatEdit_SendText(ChatFrameEditBox);
	
	end
	
	ChatFrameEditBox:SetText(text);
end