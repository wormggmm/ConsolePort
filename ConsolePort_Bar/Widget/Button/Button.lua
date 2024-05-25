local _, env, db = ...; db = env.db;

---------------------------------------------------------------
local ProxyIcon = {}; -- LAB custom type dynamic icon textures
---------------------------------------------------------------

function ProxyIcon:SetTexture(texture, ...)
	if (type(texture) == 'function') then
		return texture(self, self:GetParent(), ...)
	end
	return getmetatable(self).__index.SetTexture(self, texture, ...)
end

local function ProxyButtonTextureProvider(buttonID)
	local texture = db('Icons/64/'..buttonID)
	if texture then
		return GenerateClosure(function(set, texture, obj)
			set(obj, texture)
		end, CPAPI.SetTextureOrAtlas, {texture, db.Gamepad.UseAtlasIcons})
	end
	return env.GetAsset([[Textures\Icons\Unbound]]);
end

---------------------------------------------------------------
local ProxyHotkey = {}; env.ProxyHotkey = ProxyHotkey;
---------------------------------------------------------------

function ProxyHotkey:OnLoad(buttonID, iconSize, atlasSize, point, controlID)
	self.controlID = controlID or buttonID;
	self.iconSize  = { iconSize, iconSize };
	self.atlasSize = { atlasSize, atlasSize };
	self:SetPoint(unpack(point))
	self:SetAlpha(not controlID and 1 or 0.75)
	self:OnIconsChanged()
	db:RegisterCallback('OnIconsChanged', self.OnIconsChanged, self)
end

function ProxyHotkey:SetTexture(...)
	self.icon:SetTexture(...)
end

function ProxyHotkey:SetAtlas(...)
	self.icon:SetAtlas(...)
end

function ProxyHotkey:SetAtlasSize(size)
    self.atlasSize = { size, size };
    self:OnIconsChanged()
end

function ProxyHotkey:SetIconSize(size)
    self.iconSize = { size, size };
    self:OnIconsChanged()
end

function ProxyHotkey:OnIconsChanged()
	self.iconID = db.UIHandle:GetUIControlBinding(self.controlID)
	db.Gamepad.SetIconToTexture(self, self.iconID, 32, self.iconSize, self.atlasSize)
end

---------------------------------------------------------------
local ProxyCooldown = {}; env.ProxyCooldown = ProxyCooldown;
---------------------------------------------------------------

function ProxyCooldown:OnLoad()
	local parent = self:GetParent()
	local onCooldownDone = GenerateClosure(parent.OnCooldownClear, parent)
	self:HookScript('OnCooldownDone', onCooldownDone)
end

function ProxyCooldown:SetCooldown(...)
	self:GetParent():OnCooldownSet(self, ...)
	getmetatable(self).__index.SetCooldown(self, ...)
end

function ProxyCooldown:Clear(...)
	self:GetParent():OnCooldownClear(self, ...)
	getmetatable(self).__index.Clear(self, ...)
end

function ProxyCooldown:Hide()
	self:GetParent():OnCooldownClear(self)
	getmetatable(self).__index.Hide(self)
end

---------------------------------------------------------------
local ProxyButton = Mixin({
---------------------------------------------------------------
    Env = {
        UpdateState = [[
            local state = ...; self:SetAttribute('state', state)
            if not state then return end;
            local typeof, numBarButtons = type, ]]..NUM_ACTIONBAR_BUTTONS..[[;

            local type   = self:GetAttribute(format('labtype-%s', state)) or 'empty';
            local action = self:GetAttribute(format('labaction-%s', state))
            local mainBarActionID = (type == 'action' and typeof(action) == 'number' and action <= numBarButtons and action) or 0;
            self:SetID(mainBarActionID)

            self:SetAttribute('type', type)
            if ( type ~= 'empty' and type ~= 'custom' ) then
                local actionField = (type == 'pet') and 'action' or type;
                local actionPage  = self:GetAttribute('actionpage') or 1;

                if ( mainBarActionID > 0 ) then
                    action = action + ((actionPage - 1) * numBarButtons)
                    self:CallMethod('ButtonContentsChanged', state, type, action)
                end

                self:SetAttribute(actionField, action)
                self:SetAttribute('action_field', actionField)
            end
            if IsPressHoldReleaseSpell then
                local pressAndHold = false
                if type == 'action' then
                    self:SetAttribute('typerelease', 'actionrelease')
                    local actionType, id, subType = GetActionInfo(action)
                    if actionType == 'spell' then
                        pressAndHold = IsPressHoldReleaseSpell(id)
                    elseif actionType == 'macro' then
                        if subType == 'spell' then
                            pressAndHold = IsPressHoldReleaseSpell(id)
                        end
                    end
                elseif type == 'spell' then
                    self:SetAttribute('typerelease', nil)
                    pressAndHold = IsPressHoldReleaseSpell(action)
                else
                    self:SetAttribute('typerelease', nil)
                end
                self:SetAttribute('pressAndHoldAction', pressAndHold)
            end
        ]];
        [env.Update('actionpage')] = [[
            self:SetAttribute('actionpage', message)
            if self:GetID() > 0 then
                self::UpdateState(self:GetAttribute('state'))
            end
        ]];
    };
---------------------------------------------------------------
}, CPAPI.SecureEnvironmentMixin); env.ProxyButton = ProxyButton;
---------------------------------------------------------------

function ProxyButton:OnLoad()
    self:CreateEnvironment(ProxyButton.Env)
	Mixin(self.icon, ProxyIcon)
end

function ProxyButton:RefreshBinding(state, binding)
	local actionID = binding and db('Actionbar/Binding/'..binding)
	local stateType, stateAction;
	if actionID then
		stateType, stateAction = self:SetActionBinding(state, actionID)
	elseif binding and binding:len() > 0 then
		stateType, stateAction = self:SetXMLBinding(binding)
	else
		stateType, stateAction = self:SetEligbleForRebind(state)
	end
	self:SetState(state, stateType, stateAction)
end

function ProxyButton:SetActionBinding(state, actionID)
	if self:ShouldOverrideActionBarBinding(state, actionID) then
		env.Manager:RegisterOverride(self, self:GetOverrideBinding(state, actionID), self:GetName())
	end
	return 'action', actionID;
end

function ProxyButton:SetXMLBinding(binding)
	local info = env.GetXMLBindingInfo(binding)
	return 'custom', {
		tooltip = info.tooltip or env.GetBindingName(binding);
		texture = info.texture or env.GetBindingIcon(binding) or ProxyButtonTextureProvider(self.id);
		func    = function() end; -- TODO
	};
end

function ProxyButton:SetEligbleForRebind(state)
    local info = env.GetRebindInfo(self.id)
	return 'custom', {
        tooltip = info.tooltip;
		texture = ProxyButtonTextureProvider(self.id);
		func    = print; -- TODO
	};
end

function ProxyButton:ShouldOverrideActionBarBinding(state, actionID)
    return false; -- override
end

function ProxyButton:GetOverrideBinding(state, actionID)
    return nil; -- override
end