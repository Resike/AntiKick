local AddonName, Addon = ...

local rawset = rawset
local tostring = tostring

local L = setmetatable({ }, {__index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end})

Addon.L = L

local locale = GetLocale()

if locale == "enUS" or locale == "enGB" then
	
elseif locale == "deDE" then

elseif locale == "esES" then

elseif locale == "esMX" then

elseif locale == "frFR" then

elseif locale == "itIT" then

elseif locale == "koKR" then

elseif locale == "ptBR" then

elseif locale == "ruRU" then

elseif locale == "zhCN" then

elseif locale == "zhTW" then

end
