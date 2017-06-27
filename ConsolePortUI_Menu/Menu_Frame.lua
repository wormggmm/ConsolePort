do
local UI, an, L = ConsolePortUI, ...
local db = ConsolePort:GetData()
local cc = UI.Media.CC
local ICON = 'Interface\\Icons\\%s'
local Button = L.Button

-- Loot header specifics
local LootButton = L.LootButton
local lootButtonProbeScript = L.lootButtonProbeScript
local lootHeaderOnSetScript = L.lootHeaderOnSetScript

local function HideMenu(self)
	if IsOptionFrameOpen() then
		ToggleFrame(GameMenuFrame)
	end
end

local Menu =  UI:CreateFrame('Frame', an, UIParent, 'SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate', {
	BG = {
		Type 	= 'Texture',
		Setup  	= {'BACKGROUND'},
		Texture = UI.Media:GetTexture('Menu_BG'),
		Fill = true,
	},
	Character = {
		Type 	= 'CheckButton',
		Setup 	= {
			'SecureHandlerBaseTemplate',
			'SecureHandlerClickTemplate',
			'CPUIListCategoryTemplate',
		},
		Point 	= {'CENTER', -345, 0},
		Text	= CHARACTER,
		ID = 1,
		SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
		{
			Info  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 1,
				Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
				Desc	= CHARACTER_BUTTON,
				PreClick = HideMenu,
				UpdateLevel = function(self, newLevel)
					local level = newLevel or UnitLevel('player')
					if level < MAX_PLAYER_LEVEL then
						self.Level:SetTextColor(1, 0.8, 0)
						self.Level:SetText(level)
					else
						self.Level:SetTextColor(GetItemLevelColor())
						self.Level:SetText(floor(select(2, GetAverageItemLevel())))
					end
				end,
				OnClick = function(self) ToggleCharacter('PaperDollFrame') end,
				OnEvent = function(self, event, ...)
					if event == 'UNIT_PORTRAIT_UPDATE' then
						local unit = ...
						if unit == 'player' then
							SetPortraitTexture(self.Icon, 'player')
						end
					elseif event == 'PLAYER_LEVEL_UP' then
						self:UpdateLevel(...)
					else
						SetPortraitTexture(self.Icon, 'player')
						self:UpdateLevel(...)
					end
				end,
				Events = {
					'UNIT_PORTRAIT_UPDATE',
					'PLAYER_ENTERING_WORLD',
					'PLAYER_LEVEL_UP',
				},
				{
					Level = {
						Type 	= 'FontString',
						Setup 	= {'OVERLAY'},
						Font 	= {Game12Font:GetFont()},
						AlignH 	= 'RIGHT',
						Point 	= {'RIGHT', -10, 0},
					},
				},
			},
			Inventory  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 2,
				Point 	= {'TOP', 'parent.Info', 'BOTTOM', 0, 0},
				Desc	= INVENTORY_TOOLTIP,
				Img 	= ICON:format('INV_Misc_Bag_29'),
				Events 	= {'BAG_UPDATE'},
				PreClick = HideMenu,
				OnClick = ToggleAllBags,
				OnEvent = function(self, event, ...)
					local totalFree, numSlots, freeSlots, bagFamily = 0, 0
					for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
						freeSlots, bagFamily = GetContainerNumFreeSlots(i)
						if ( bagFamily == 0 ) then
							totalFree = totalFree + freeSlots
							numSlots = numSlots + GetContainerNumSlots(i)
						end
					end
					self.Count:SetFormattedText('%s\n|cFFAAAAAA%s|r', totalFree, numSlots)
				end,
				{
					Count = {
						Type 	= 'FontString',
						Setup 	= {'OVERLAY'},
						Font 	= {Game12Font:GetFont()},
						AlignH 	= 'RIGHT',
						Point 	= {'RIGHT', -10, 0},
					},
				},
			},
			Spec  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 3,
				Point 	= {'TOP', 'parent.Inventory', 'BOTTOM', 0, 0},
				Desc	= TALENTS_BUTTON,
				Img 	= [[Interface\ICONS\ClassIcon_]]..select(2, UnitClass('player')),
				Click 	= TalentMicroButton,
				PreClick = HideMenu,
				EvaluateAlertVisibility = function(self)
					-- If we just unspecced, and we have unspent talent points, it's probably spec-specific talents that were just wiped.  Show the tutorial box.
					if not AreTalentsLocked() and GetNumUnspentTalents() > 0 and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
						self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_TALENTS
						self:SetPulse(true)
						return
					end
					if GetNumUnspentPvpTalents() > 0 and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
						self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_HONOR_TALENTS
						self:SetPulse(true)
						return
					end
				end,
				EnterScript = function(self)
					if self.tooltipText then
						GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
						GameTooltip:SetText(self.tooltipText)
						self.tooltipText = nil
						self.hideTooltipOnLeave = true
					end
				end,
				LeaveScript = function(self)
					if self.hideTooltipOnLeave then
						GameTooltip:Hide()
						self.hideTooltipOnLeave = nil
					end
				end,
				LoadScript = function(self)
					self:RegisterEvent('PLAYER_LEVEL_UP')
					self:RegisterEvent('UPDATE_BINDINGS')
					self:RegisterEvent('PLAYER_TALENT_UPDATE')
					self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
					self:RegisterEvent('HONOR_LEVEL_UPDATE')
					self:RegisterEvent('HONOR_PRESTIGE_UPDATE')
					self:RegisterEvent('PLAYER_PVP_TALENT_UPDATE')
					self:RegisterEvent('PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED')
				end,
				OnEvent = function(self, event, ...)
					self.tooltipText = nil
					if ( event == 'PLAYER_LEVEL_UP' ) then
						local level = ...
						if (level == SHOW_SPEC_LEVEL) then
							self.tooltipText = TALENT_MICRO_BUTTON_SPEC_TUTORIAL
							self:SetPulse(true)
						elseif (level == SHOW_TALENT_LEVEL) then
							self.tooltipText = TALENT_MICRO_BUTTON_TALENT_TUTORIAL
							self:SetPulse(true)
						end
					elseif ( event == 'PLAYER_SPECIALIZATION_CHANGED' ) then
						self:EvaluateAlertVisibility()
					elseif ( event == 'PLAYER_TALENT_UPDATE' or event == 'NEUTRAL_FACTION_SELECT_RESULT' or
						event == 'HONOR_LEVEL_UPDATE' or event == 'HONOR_PRESTIGE_UPDATE' or event == 'PLAYER_PVP_TALENT_UPDATE' ) then
						self:EvaluateAlertVisibility()

						-- On the first update from the server, flash the button if there are unspent points
						-- Small hack: GetNumSpecializations should return 0 if talents haven't been initialized yet
						if (not self.receivedUpdate and GetNumSpecializations(false) > 0) then
							self.receivedUpdate = true;
							local shouldPulseForTalents = GetNumUnspentTalents() > 0 or GetNumUnspentPvpTalents() > 0 and not AreTalentsLocked()
							if (UnitLevel('player') >= SHOW_SPEC_LEVEL and (not GetSpecialization() or shouldPulseForTalents)) then
								self:SetPulse(true)
							end
						end
					elseif ( event == 'PLAYER_CHARACTER_UPGRADE_TALENT_COUNT_CHANGED' ) then
						local prev, current = ...
						if ( prev == 0 and current > 0 ) then
							self.tooltipText = TALENT_MICRO_BUTTON_TALENT_TUTORIAL
							self:SetPulse(true)
						elseif ( prev ~= current ) then
							self.tooltipText = TALENT_MICRO_BUTTON_UNSPENT_TALENTS
							self:SetPulse(true)
						end
					end
				end,
			},
			Spellbook  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 4,
				Point 	= {'TOP', 'parent.Spec', 'BOTTOM', 0, 0},
				Desc	= SPELLBOOK_BUTTON,
				Img 	= [[Interface\Spellbook\Spellbook-Icon]],
				Click 	= SpellbookMicroButton,
				PreClick = HideMenu,
			},
			Collections  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 5,
				Point 	= {'TOP', 'parent.Spellbook', 'BOTTOM', 0, 0},
				Desc	= COLLECTIONS,
				Img 	= ICON:format('MountJournalPortrait'),
				Click 	= CollectionsMicroButton,
				PreClick = HideMenu,
			},
		},
	},
	Gameplay = {
		Type 	= 'CheckButton',
		Setup 	= {
			'SecureHandlerBaseTemplate',
			'SecureHandlerClickTemplate',
			'CPUIListCategoryTemplate',
		},
		Point 	= {'CENTER', -115, 0},
		Text	= GAME,
		ID 	= 2,
		SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
		{
			WorldMap  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 1,
				Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
				Desc	= WORLD_MAP .. ' / ' .. QUEST_LOG,
				Img 	= ICON:format('INV_Misc_Map02'),
				Click 	= QuestLogMicroButton,
				PreClick = HideMenu,
			},
			Guide  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 2,
				Point 	= {'TOP', 'parent.WorldMap', 'BOTTOM', 0, 0},
				Desc	= ADVENTURE_JOURNAL,
				Img 	= [[Interface\ENCOUNTERJOURNAL\UI-EJ-PortraitIcon]],
				Click 	= EJMicroButton,
				PreClick = HideMenu,
				{
					Notice = {
						Type = 'Frame',
						Size = {28, 28},
						Point = {'RIGHT', -10, 0},
						Hide = not EJMicroButton.NewAdventureNotice:IsShown(),
						{
							Texture = {
								Type = 'Texture',
								Setup = {'OVERLAY'},
								Fill = true,
								Atlas = 'adventureguide-microbutton-alert',
							},
						},
						OnLoad = function(self)
							hooksecurefunc('EJMicroButton_UpdateNewAdventureNotice', function()
								if EJMicroButton.NewAdventureNotice:IsShown() then
									self:Show()
								end
							end)
							hooksecurefunc('EJMicroButton_ClearNewAdventureNotice', function()
								self:Hide()
							end)
						end,
					},
				},
			},
			Finder  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 3,
				Point 	= {'TOP', 'parent.Guide', 'BOTTOM', 0, 0},
				Desc	= DUNGEONS_BUTTON,
				Img 	= [[Interface\LFGFRAME\UI-LFG-PORTRAIT]],
				Click 	= LFDMicroButton,
				PreClick = HideMenu,
			},
			Achievements  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 4,
				Point 	= {'TOP', 'parent.Finder', 'BOTTOM', 0, -16},
				Desc	= ACHIEVEMENTS,
				Img 	= ICON:format('ACHIEVEMENT_WIN_WINTERGRASP'),
				Click 	= AchievementMicroButton,
				PreClick = HideMenu,
			},
			WhatsNew  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 5,
				Point 	= {'TOP', 'parent.Achievements', 'BOTTOM', 0, 0},
				Desc	= GAMEMENU_NEW_BUTTON,
				Click 	= GameMenuButtonWhatsNew,
				Img 	= ICON:format('WoW_Token01')
			},
			Shop  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 6,
				Point 	= {'TOP', 'parent.WhatsNew', 'BOTTOM', 0, 0},
				Desc	= BLIZZARD_STORE,
				Click 	= GameMenuButtonStore,
				Img 	= ICON:format('WoW_Store'),
			},
			Teleport  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 7,
				Point 	= {'TOP', 'parent.Shop', 'BOTTOM', 0, 0},
				Img 	= ICON:format('Spell_Shadow_Teleport'),
				SetAttribute = {'condition', 'return PlayerInGroup()'},
				Hooks = {
					OnShow = function(self)
						local isLFG, inDungeon = IsPartyLFG(), IsInLFGDungeon()
						self:SetText(inDungeon and TELEPORT_OUT_OF_DUNGEON or isLFG and TELEPORT_TO_DUNGEON or '|cFF757575'..TELEPORT_TO_DUNGEON)
					end,
				},
				OnClick = function(self)
					LFGTeleport(IsInLFGDungeon())
				end,
			},
		},
	},
	Social = {
		Type 	= 'CheckButton',
		Setup 	= {
			'SecureHandlerBaseTemplate',
			'SecureHandlerClickTemplate',
			'CPUIListCategoryTemplate',
		},
		Point 	= {'CENTER', 115, 0},
		Text	= SOCIAL_BUTTON,
		ID = 3,
		SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
		{	
			Friends  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 1,
				Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
				Desc 	= FRIENDS_LIST,
				Img 	= [[Interface\FriendsFrame\Battlenet-Portrait]],
				Click 	= QuickJoinToastButton,
				PreClick = HideMenu,
				OnEvent = function(self)
					local _, numBNetOnline = BNGetNumFriends()
					local _, numWoWOnline = GetNumFriends()
					self.Count:SetText(numBNetOnline + numWoWOnline)
				end,
				Events = {
					'FRIENDLIST_UPDATE',
					'BN_FRIEND_INFO_CHANGED',
					'PLAYER_ENTERING_WORLD',
				},
				{
					Count = {
						Type 	= 'FontString',
						Setup 	= {'OVERLAY'},
						Font 	= {Game12Font:GetFont()},
						AlignH 	= 'RIGHT',
						Point 	= {'RIGHT', -10, 0},
					},
				},
			},
			Guild  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 2,
				Point 	= {'TOP', 'parent.Friends', 'BOTTOM', 0, 0},
				Desc 	= GUILD,
				Img 	= ICON:format('Achievement_GuildPerk_EverybodysFriend'),
				Click 	= GuildMicroButton,
				PreClick = HideMenu,
			},
			Calendar  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 3,
				Point 	= {'TOP', 'parent.Guild', 'BOTTOM', 0, 0},
				Desc 	= EVENTS_LABEL,
				Img 	= [[Interface\Calendar\MeetingIcon]],
				PreClick = HideMenu,
				Click 	= GameTimeFrame,
			},
			Raid  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 4,
				Point 	= {'TOP', 'parent.Calendar', 'BOTTOM', 0, 0},
				Desc 	= RAID,
				Img 	= [[Interface\LFGFRAME\UI-LFR-PORTRAIT]],
				Scripts = {
					PreClick = HideMenu,
					OnClick = ToggleRaidFrame,
				},
			},
			Party  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 5,
				Point 	= {'TOP', 'parent.Raid', 'BOTTOM', 0, -16},
				Img 	= [[Interface\LFGFRAME\UI-LFG-PORTRAIT]],
				SetAttribute = {'condition', 'return PlayerInGroup()'},
				Hooks 	= {
					OnShow = function(self)
						self:SetText(IsPartyLFG() and INSTANCE_PARTY_LEAVE or PARTY_LEAVE)
					end,
				},
				Scripts = {
					PreClick = HideMenu,
					OnClick = function(self)
						if IsPartyLFG() or IsInLFGDungeon() then
							ConfirmOrLeaveLFGParty()
						else
							LeaveParty()
						end
					end,
				},
			},
		},
	},
	System = {
		Type 	= 'CheckButton',
		Setup 	= {
			'SecureHandlerBaseTemplate',
			'SecureHandlerClickTemplate',
			'CPUIListCategoryTemplate',
		},
		Point 	= {'CENTER', 345, 0},
		Text	= SYSTEMOPTIONS_MENU,
		ID = 4,
		SetAttribute = {'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
		{
			Return  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 1,
				Point 	= {'TOP', 'parent', 'BOTTOM', 0, -16},
				Desc	= RETURN_TO_GAME,
				Click 	= GameMenuButtonContinue,
				Img 	= ICON:format('misc_arrowright'),
			},
			Logout  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 2,
				Point 	= {'TOP', 'parent.Return', 'BOTTOM', 0, 0},
				Desc	= LOGOUT,
				Click 	= GameMenuButtonLogout,
				Img 	= ICON:format('RaceChange'),
			},
			Exit  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 3,
				Point 	= {'TOP', 'parent.Logout', 'BOTTOM', 0, 0},
				Desc	= EXIT_GAME,
				Click 	= GameMenuButtonQuit,
				Img 	= [[Interface\RAIDFRAME\ReadyCheck-NotReady]],
			},
			Controller  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 4,
				Point 	= {'TOP', 'parent.Exit', 'BOTTOM', 0, -16},
				Desc	= CONTROLS_LABEL,
				NoMask 	= true,
				Img 	= db.TEXTURE.CP_X_CENTER,
				PreClick = HideMenu,
				OnClick = function() 
					if InCombatLockdown() then
						ConsolePortConfig:OnShow()
					else
						ConsolePortConfig:Show()
					end
				end,
			},
			System  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 5,
				Point 	= {'TOP', 'parent.Controller', 'BOTTOM', 0, 0},
				Desc	= SYSTEMOPTIONS_MENU,
				Click 	= GameMenuButtonOptions,
				Img 	= ICON:format('Pet_Type_Mechanical'),
			},
			Interface  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 6,
				Point 	= {'TOP', 'parent.System', 'BOTTOM', 0, 0},
				Desc	= UIOPTIONS_MENU,
				Click 	= GameMenuButtonUIOptions,
				Img 	= [[Interface\TUTORIALFRAME\UI-TutorialFrame-GloveCursor]],
			},
			AddOns  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 7,
				Point 	= {'TOP', 'parent.Interface', 'BOTTOM', 0, 0},
				Desc	= ADDONS,
				Click 	= GameMenuButtonAddons,
				Img 	= [[Interface\PaperDollInfoFrame\Character-Plus]],
			},
			Macros  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 8,
				Point 	= {'TOP', 'parent.AddOns', 'BOTTOM', 0, -16},
				Desc	= MACROS,
				Click 	= GameMenuButtonMacros,
				Img 	= ICON:format('Pet_Type_Magical'),
			},
			KeyBindings  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 9,
				Point 	= {'TOP', 'parent.Macros', 'BOTTOM', 0, 0},
				Desc	= KEY_BINDINGS,
				Click 	= GameMenuButtonKeybindings,
				Img 	= [[Interface\MacroFrame\MacroFrame-Icon]],
			},
			Help  = {
				Type 	= 'Button',
				Setup 	= {'SecureActionButtonTemplate'},
				Mixin 	= Button,
				ID 		= 10,
				Point 	= {'TOP', 'parent.KeyBindings', 'BOTTOM', 0, 0},
				Desc	= GAMEMENU_HELP,
				Click 	= GameMenuButtonHelp,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
			},
		},
	},
})

local lootWireFrame = {
	Loot = {
		Type 	= 'CheckButton',
		Setup 	= {
			'SecureHandlerBaseTemplate',
			'SecureHandlerShowHideTemplate',
			'SecureHandlerClickTemplate',
			'CPUIListCategoryTemplate',
		},
		Point 	= {'CENTER', 490, 0},
		Text	= [[|TInterface\Buttons\UI-GroupLoot-Dice-Up:24:24:0:-2|t]],
		Width 	= 50,
		ID = 5,
		OnLoad = function(self)
			self:SetShown(
				GroupLootFrame1:IsVisible() or
				GroupLootFrame2:IsVisible() or
				GroupLootFrame3:IsVisible() or
				GroupLootFrame4:IsVisible() or
				BonusRollFrame:IsVisible())
		end,
		Multiple = {
			Probe = {
				{GroupLootFrame1, 'showhide'},
				{GroupLootFrame2, 'showhide'},
				{GroupLootFrame3, 'showhide'},
				{GroupLootFrame4, 'showhide'},
			--	{BonusRollFrame, 'showhide'},
			},
			SetAttribute = {
				{'_onclick', 'self:GetParent():RunAttribute("ShowHeader", self:GetID())'},
				{'onheaderset', lootHeaderOnSetScript},
			},
		},
		{
			Loot1  = {
				Type 	= 'Button',
				Setup 	= {'SecureHandlerBaseTemplate', 'SecureActionButtonTemplate'},
				Mixin 	= LootButton,
				ID 		= 1,
				NoMask 	= true,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Obj 	= GroupLootFrame1,
				Probe 	= {GroupLootFrame1, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot2  = {
				Type 	= 'Button',
				Setup 	= {'SecureHandlerBaseTemplate', 'SecureActionButtonTemplate'},
				Mixin 	= LootButton,
				ID 		= 2,
				NoMask 	= true,
				Obj 	= GroupLootFrame2,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame2, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot3  = {
				Type 	= 'Button',
				Setup 	= {'SecureHandlerBaseTemplate', 'SecureActionButtonTemplate'},
				Mixin 	= LootButton,
				ID 		= 3,
				NoMask 	= true,
				Obj 	= GroupLootFrame3,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame3, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			Loot4  = {
				Type 	= 'Button',
				Setup 	= {'SecureHandlerBaseTemplate', 'SecureActionButtonTemplate'},
				Mixin 	= LootButton,
				ID 		= 4,
				NoMask 	= true,
				Obj 	= GroupLootFrame4,
				Img 	= ICON:format('INV_Misc_QuestionMark'),
				Probe 	= {GroupLootFrame4, 'probescript', nil, lootButtonProbeScript},
				RegisterForClicks = {'AnyUp', 'AnyDown'},
				Multiple = {
					SetAttribute = {
						{'circleclick', 'self:CallMethod("OnCircleClicked")'},
						{'squareclick', 'self:CallMethod("OnSquareClicked")'},
						{'triangleclick', 'self:CallMethod("OnTriangleClicked")'},
						{'pc', 0},
						{'condition', 'return false'},
					},
				},
			},
			-- Bonus  = {
			-- 	Type 	= 'Button',
			-- 	Setup 	= {'SecureHandlerBaseTemplate', 'SecureActionButtonTemplate'},
			-- 	Mixin 	= LootButton,
			-- 	ID 		= 5,
			-- 	NoMask 	= true,
			-- 	Obj 	= BonusRollFrame,
			-- 	Img 	= ICON:format('INV_Misc_QuestionMark'),
			-- 	Probe 	= {BonusRollFrame, 'probescript', nil, lootButtonProbeScript},
			-- 	RegisterForClicks = {'AnyUp', 'AnyDown'},
			-- 	Multiple = {
			-- 		SetAttribute = {
			-- 			{'pc', 0},
			-- 			{'condition', 'return false'},
			-- 		},
			-- 	},
			-- },
		},
	},
}

do	
	ConsolePortUIConfig = ConsolePortUIConfig or {}
	ConsolePortUIConfig.Menu = ConsolePortUIConfig.Menu or {}

	local cfg = ConsolePortUIConfig.Menu
	if cfg.lootprobe == nil then cfg.lootprobe = false end
	cfg.scale = cfg.scale or 1
	cfg.anchor = cfg.anchor or {
		point = 'TOP',
		offsetX = 0,
		offsetY = -100,
	}

	if cfg.lootprobe then
		UI:BuildFrame(Menu, lootWireFrame)
	end

	lootWireFrame = nil


	Menu:Execute([[
		headers = newtable()
		hID, bID = 4, 1
	]])

	local NUM_HEADERS = 0
	for _, header in pairs({Menu:GetChildren()}) do
		NUM_HEADERS = NUM_HEADERS + 1
		Menu:SetFrameRef('newheader', header)
		Menu:Execute([[
			local newheader = self:GetFrameRef('newheader')
			headers[newheader:GetID()] = newheader
		]])
		for _, button in pairs({header:GetChildren()}) do
			button:Hide()
			header:SetFrameRef(tostring(button:GetID()), button)
		end
	end

	Menu.GlowLeft = CreateFrame('Frame', nil, Menu, 'CPUILineSheenTemplate')
	Menu.GlowRight = CreateFrame('Frame', nil, Menu, 'CPUILineSheenTemplate')

	Menu.GlowLeft:SetPoint('TOP', Menu, 'BOTTOM', 0, 40)
	Menu.GlowLeft:SetDirection('LEFT', 2.5)

	Menu.GlowRight:SetPoint('TOP', Menu, 'BOTTOM', 0, 40)
	Menu.GlowRight:SetDirection('RIGHT', 2.5)

	Menu:Execute(format('numheaders = %s', NUM_HEADERS))

	Menu.probe = UI:CreateProbe(Menu, GameMenuFrame, 'showhide')
	Menu:SetSize(1024, 128)
	Menu:Hide()
	Menu:SetFrameStrata('FULLSCREEN')

	Menu.HideMenu = HideMenu

	UI:RegisterFrame(Menu, 'Menu', false, true)
	UI:HideFrame(GameMenuFrame)

	Menu:SetScale(cfg.scale)
	Menu:SetPoint(cfg.anchor.point, cfg.anchor.offsetX, cfg.anchor.offsetY)

	L.Menu = Menu
end

end

--[[

Character
	Character Info
	Backpack (inventory)
	Spec&Talents
	Spell book
	Collections
Gameplay
	Quest/Map
	Adventure Guide
	Group Finder
	Achievements
	What's New
	Shop
- 	Teleport
Social
	Friends List
	Guild (guild finder)
	Raid
	Events (Calendar)
-	Leave Group
System
	Return to game
	Logout
	Exit Game

	Controller
	System (settings)
	Interface

	AddOns
	Macros

	Key bindings
	Help
]]