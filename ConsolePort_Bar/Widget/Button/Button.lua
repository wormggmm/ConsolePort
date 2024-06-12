local _, env, db = ...; db = env.db;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------

env:RegisterCallback('Settings/showCooldownText', function(_, show)
	SetCVar('countdownForCooldowns', show)
end)

---------------------------------------------------------------
local SlotButton = Mixin({
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
		[env.Attributes.Update('actionpage')] = [[
			self:SetAttribute('actionpage', message)
			if self:GetID() > 0 then
				self::UpdateState(self:GetAttribute('state'))
			end
		]];
	};
---------------------------------------------------------------
}, CPAPI.SecureEnvironmentMixin); env.SlotButton = SlotButton;
---------------------------------------------------------------

function SlotButton:OnLoad()
	self:CreateEnvironment(SlotButton.Env)

	if CPAPI.IsClassicVersion then
		-- Assert assets on all client flavors
		local skinner = env.LIB.SkinUtility;
		skinner.GetIconMask(self)
		skinner.GetHighlightTexture(self)
		skinner.GetCheckedTexture(self)
		skinner.GetPushedTexture(self)
		skinner.GetCheckedTexture(self)
		skinner.GetSlotBackground(self)
		self:SetSize(45, 45)
		self.IconMask:SetPoint('CENTER', self.icon, 'CENTER', 0, 0)
		self.IconMask:SetSize(46, 46)
		self.IconMask:SetTexture(
			CPAPI.GetAsset([[Textures\Button\EmptyIcon]]),
			'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE'
		);
	end

	self:UpdateLocal(true)
end

function SlotButton:SetActionBinding(state, actionID)
	if self:ShouldOverrideActionBarBinding(state, actionID) then
		env.Manager:RegisterOverride(self:GetParent(), self:GetName(), self:GetOverrideBinding(state, actionID))
	end
	return 'action', actionID;
end

function SlotButton:ShouldOverrideActionBarBinding(state, actionID)
	return false; -- override
end

function SlotButton:GetOverrideBinding(state, actionID)
	return nil; -- override
end

if CPAPI.IsClassicVersion then
	local TextureInfo = {
		NormalTexture = {
			atlas = 'UI-HUD-ActionBar-IconFrame-AddRow';
			size  = {52, 51};
		};
		PushedTexture = {
			atlas = 'UI-HUD-ActionBar-IconFrame-AddRow-Down';
			size  = {52, 51};
		};
		HighlightTexture = {
			atlas = 'UI-HUD-ActionBar-IconFrame-Mouseover';
			size  = {46, 45};
		};
		CheckedTexture = {
			atlas = 'UI-HUD-ActionBar-IconFrame-Mouseover';
			size  = {46, 45};
		};
	};
	function SlotButton:UpdateLocal()
		if self.MasqueSkinned then return end;
		if self.config.hideElements.border then
			self.NormalTexture:SetTexture()
			self.PushedTexture:SetTexture()
			self.icon:RemoveMaskTexture(self.IconMask)
			self.HighlightTexture:SetSize(52, 51)
			self.HighlightTexture:SetPoint('TOPLEFT', self, 'TOPLEFT', -2.5, 2.5)
			self.CheckedTexture:SetSize(52, 51)
			self.CheckedTexture:SetPoint('TOPLEFT', self, 'TOPLEFT', -2.5, 2.5)
			self.cooldown:ClearAllPoints()
			self.cooldown:SetAllPoints()
		else
			for key, info in pairs(TextureInfo) do
				local texture = self[key];
				CPAPI.SetAtlas(texture, info.atlas)
				texture:SetSize(unpack(info.size))
				texture:ClearAllPoints()
				texture:SetPoint('TOPLEFT', 0, 0)
			end
			self.icon:SetAllPoints()
			self.cooldown:ClearAllPoints()
			self.cooldown:SetPoint('TOPLEFT', self, 'TOPLEFT', 3, -2)
			self.cooldown:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -3, 3)
		end
	end
end

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
local ProxyButton = CreateFromMixins(SlotButton); env.ProxyButton = ProxyButton;
---------------------------------------------------------------

function ProxyButton:OnLoad()
	SlotButton.OnLoad(self)
	env:RegisterCallback('OnConfigChanged', self.UpdateConfig, self)
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

---------------------------------------------------------------
local Button = {}; env.Button = Button;
---------------------------------------------------------------

Button.OnConfigChanged = CPAPI.Debounce(function(self)
	env:TriggerEvent('OnConfigChanged', self:CreateConfig())
end, Button)

function Button:OnDataChanged()
	self:OnConfigChanged()
end

function Button:GetConfig()
	if not self.config then
		return self:CreateConfig();
	end
	return self.config;
end

function Button:CreateConfig()
	self.config = {
		clickOnDown           = env('LABclickOnDown');
		tooltip               = env('LABtooltip'):lower();
		showGrid              = true;
		colors                = {
			range             = { env:GetColorRGBA('LABcolorsRange') };
			mana              = { env:GetColorRGBA('LABcolorsMana') };
		};
		hideElements          = {
			macro             = env('LABhideElementsMacro');
			equipped          = false;
			hotkey            = true;
			border            = false;
			borderIfEmpty     = false;
		};
		text                  = {
			hotkey            = {
				color         = { env:GetColorRGBA('LABhotkeyColor') };
				justifyH      = env('LABhotkeyJustifyH');
				font          = {
					size      = env('LABhotkeyFontSize');
					flags     = env('LABhotkeyFontFlags');
				};
				position      = {
					anchor    = env('LABhotkeyPositionAnchor');
					relAnchor = env('LABhotkeyPositionRelAnchor');
					offsetX   = env('LABhotkeyPositionOffsetX');
					offsetY   = env('LABhotkeyPositionOffsetY');
				};
			};
			count             = {
				color         = { env:GetColorRGBA('LABcountColor') };
				justifyH      = env('LABcountJustifyH');
				font          = {
					size      = env('LABcountFontSize');
					flags     = env('LABcountFontFlags');
				};
				position      = {
					anchor    = env('LABcountPositionAnchor');
					relAnchor = env('LABcountPositionRelAnchor');
					offsetX   = env('LABcountPositionOffsetX');
					offsetY   = env('LABcountPositionOffsetY');
				};
			};
			macro             = {
				color         = { env:GetColorRGBA('LABmacroColor') };
				justifyH      = env('LABmacroJustifyH');
				font          = {
					size      = env('LABmacroFontSize');
					flags     = env('LABmacroFontFlags');
				};
				position      = {
					anchor    = env('LABmacroPositionAnchor');
					relAnchor = env('LABmacroPositionRelAnchor');
					offsetX   = env('LABmacroPositionOffsetX');
					offsetY   = env('LABmacroPositionOffsetY');
				};
			};
		};
	};
	return self.config;
end

env:RegisterCallbacks(Button.OnDataChanged, Button,
	'Settings/LABclickOnDown',
	'Settings/LABtooltip',
	'Settings/LABcolorsRange',
	'Settings/LABcolorsMana',
	'Settings/LABhideElementsMacro',
	'Settings/LABhotkeyColor',
	'Settings/LABhotkeyJustifyH',
	'Settings/LABhotkeyFontSize',
	'Settings/LABhotkeyFontFlags',
	'Settings/LABhotkeyPositionAnchor',
	'Settings/LABhotkeyPositionRelAnchor',
	'Settings/LABhotkeyPositionOffsetX',
	'Settings/LABhotkeyPositionOffsetY',
	'Settings/LABcountColor',
	'Settings/LABcountJustifyH',
	'Settings/LABcountFontSize',
	'Settings/LABcountFontFlags',
	'Settings/LABcountPositionAnchor',
	'Settings/LABcountPositionRelAnchor',
	'Settings/LABcountPositionOffsetX',
	'Settings/LABcountPositionOffsetY',
	'Settings/LABmacroColor',
	'Settings/LABmacroJustifyH',
	'Settings/LABmacroFontSize',
	'Settings/LABmacroFontFlags',
	'Settings/LABmacroPositionAnchor',
	'Settings/LABmacroPositionRelAnchor',
	'Settings/LABmacroPositionOffsetX',
	'Settings/LABmacroPositionOffsetY'
);