-- Consts
local STICK_SELECT = {'Movement', 'Camera', 'Gyro'};
local MODID_SELECT = {'SHIFT', 'CTRL', 'ALT'};
local MODID_EXTEND = {'SHIFT', 'CTRL', 'ALT', 'CTRL-SHIFT', 'ALT-SHIFT', 'ALT-CTRL'};
local ADVANCED_OPT = RED_FONT_COLOR:WrapTextInColorCode(ADVANCED_OPTIONS);

local unpack, _, db = unpack, ...; db('Data')();
------------------------------------------------------------------------------------------------------------
-- Default cvar data (global)
------------------------------------------------------------------------------------------------------------
db:Register('Variables', {
	showAdvancedSettings = {Bool(false);
		name = 'All Settings';
		desc = 'Display all available settings.';
		hide = true;
	};
	useCharacterSettings = {Bool(false);
		name = 'Character Specific';
		desc = 'Use character specific settings for this character.';
		hide = true;
	};
	--------------------------------------------------------------------------------------------------------
	-- Crosshair:
	--------------------------------------------------------------------------------------------------------
	crosshairEnable = {Bool(true);
		head = 'Crosshair';
		sort = 1;
		name = 'Enable';
		desc = 'Enables a crosshair to reveal your hidden center cursor position at all times.';
		note = 'Use together with [@cursor] macros to place reticle spells in a single click.';
	};
	crosshairSizeX = {Number(24, 1, true);
		head = 'Crosshair';
		sort = 2;
		name = 'Width';
		desc = 'Width of the crosshair, in scaled pixel units.';
		advd = true;
	};
	crosshairSizeY = {Number(24, 1, true);
		head = 'Crosshair';
		sort = 3;
		name = 'Height';
		desc = 'Height of the crosshair, in scaled pixel units.';
		advd = true;
	};
	crosshairCenter = {Number(0.2, 0.05, true);
		head = 'Crosshair';
		sort = 4;
		name = 'Center Gap';
		desc = 'Center gap, as fraction of overall crosshair size.';
		advd = true;
	};
	crosshairThickness = {Number(2, 0.025, true);
		head = 'Crosshair';
		sort = 5;
		name = 'Thickness';
		desc = 'Thickness in scaled pixel units.';
		note = 'Value below two may appear interlaced or not at all.';
		advd = true;
	};
	crosshairColor = {Color('ff00fcff');
		head = 'Crosshair';
		sort = 6;
		name = 'Color';
		desc = 'Color of the crosshair.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Mouse:
	--------------------------------------------------------------------------------------------------------
	mouseHandlingEnabled = {Bool(true);
		head = MOUSE_LABEL;
		sort = 1;
		name = 'Enable Mouse Handling';
		desc = 'Enable custom mouse handling, overriding Blizzard defaults intended for use without addons.';
		note = 'While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.';
		advd = true;
	};
	mouseFreeCursorReticle = {Bool(false);
		head = MOUSE_LABEL;
		sort = 2;
		name = 'Cursor Reticle Targeting';
		desc = 'Reticle targeting uses free cursor instead of staying center-fixed.';
		note = 'Reticle targeting means anything you place on the ground.';
	};
	mouseHideCursorOnMovement = {Bool(false);
		head = MOUSE_LABEL;
		sort = 3;
		name = 'Hide Cursor On Movement';
		desc = 'Cursor hides when you start moving, if free of obstacles.';
		note = 'Requires Settings > Hide Cursor on Stick Input set to None.';
	};
	mouseAlwaysCentered = {Bool(false);
		head = MOUSE_LABEL;
		sort = 5;
		name = 'Always Show Mouse Cursor';
		desc = 'Always keep cursor centered and visible when controlling camera.';
	};
	mouseAutoClearCenter = {Number(2.0, 0.25);
		head = MOUSE_LABEL;
		sort = 6;
		name = 'Automatic Cursor Timeout';
		desc = 'Time in seconds to automatically hide centered cursor.';
		advd = true;
	};
	doubleTapTimeout = {Number(0.25, 0.05, true);
		head = MOUSE_LABEL;
		sort = 7;
		name = 'Double Tap Timeframe';
		desc = 'Timeframe to toggle the mouse cursor when double-tapping a selected modifier.';
		advd = true;
	};
	doubleTapModifier = {Select('<none>', '<none>', unpack(MODID_SELECT));
		head = MOUSE_LABEL;
		sort = 8;
		name = 'Double Tap Modifier';
		desc = 'Which modifier to use to toggle the mouse cursor when double-tapped.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Radial:
	--------------------------------------------------------------------------------------------------------
	radialStickySelect = {Bool(false);
		head = 'Radial Menus';
		sort = 1;
		name = 'Sticky Selection';
		desc = 'Selecting an item on a ring will stick until another item is chosen.';
	};
	radialClearFocusTime = {Number(0.5, 0.025);
		head = 'Radial Menus';
		sort = 2;
		name = 'Focus Timeout';
		desc = 'Time to clear focus after intercepting stick input, in seconds.';
	};
	radialScale = {Number(1, 0.025, true);
		head = 'Radial Menus';
		sort = 3;
		name = 'Ring Scale';
		desc = 'Scale of all radial menus, relative to UI scale.';
		advd = true;
	};
	radialActionDeadzone = {Range(0.5, 0.05, 0, 1);
		head = 'Radial Menus';
		sort = 4;
		name = 'Deadzone';
		desc = 'Deadzone for simple point-to-select rings.';
	};
	radialCosineDelta = {Delta(1);
		head = 'Radial Menus';
		sort = 6;
		name = 'Axis Interpretation';
		desc = 'Correlation between stick position and pie selection.';
		note = '+ Normal\n- Inverted';
		advd = true;
	};
	radialPrimaryStick = {Select('Movement', unpack(STICK_SELECT));
		head = 'Radial Menus';
		sort = 7;
		name = 'Primary Stick';
		desc = 'Stick to use for main radial actions.';
		note = 'Make sure your choice does not conflict with your bindings.';
	};
	radialRemoveButton = {Button('PADRSHOULDER');
		head = 'Radial Menus';
		sort = 9;
		name = 'Remove Button';
		desc = 'Button used to remove a selected item from an editable ring.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Radial:
	--------------------------------------------------------------------------------------------------------
	keyboardEnable = {Bool(false);
		head = 'Radial Keyboard';
		sort = 1;
		name = 'Enable';
		desc = 'Enables a radial on-screen keyboard that can be used to type messages.';
	};
	--------------------------------------------------------------------------------------------------------
	-- Raid cursor:
	--------------------------------------------------------------------------------------------------------
	raidCursorScale = {Number(1, 0.1);
		head = 'Raid Cursor';
		sort = 1;
		name = 'Scale';
		desc = 'Scale of the cursor.';
	};
	raidCursorMode = {Map(1, {'Redirect', FOCUS, TARGET}),
		head = 'Raid Cursor';
		sort = 2;
		name = 'Targeting Mode';
		desc = 'Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.';
		note = 'Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.';
	};
	raidCursorModifier = {Select('<none>', '<none>', unpack(MODID_EXTEND));
		head = 'Raid Cursor';
		sort = 3;
		name = 'Modifier';
		desc = 'Which modifier to use with the movement buttons to move the cursor.';
		note = 'The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.';
	};
	raidCursorUp = {Button('PADDUP', true);
		head = 'Raid Cursor';
		sort = 4;
		name = 'Move Up';
		desc = 'Button to move the cursor up.';
		advd = true;
	};
	raidCursorDown = {Button('PADDDOWN', true);
		head = 'Raid Cursor';
		sort = 5;
		name = 'Move Down';
		desc = 'Button to move the cursor down.';
		advd = true;
	};
	raidCursorLeft = {Button('PADDLEFT', true);
		head = 'Raid Cursor';
		sort = 6;
		name = 'Move Left';
		desc = 'Button to move the cursor left.';
		advd = true;
	};
	raidCursorRight = {Button('PADDRIGHT', true);
		head = 'Raid Cursor';
		sort = 7;
		name = 'Move Right';
		desc = 'Button to move the cursor right.';
		advd = true;
	};
	raidCursorFilter = {String(nil);
		head = 'Raid Cursor';
		sort = 8;
		name = 'Filter Condition';
		desc = 'Filter condition to find raid cursor frames.';
		note = BLUE_FONT_COLOR:WrapTextInColorCode('node') .. ' is the current frame under scrutinization.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	-- Interface cursor:
	--------------------------------------------------------------------------------------------------------
	UIenableCursor = {Bool(true);
		head = 'Interface Cursor';
		sort = 1;
		name = ENABLE;
		desc = 'Enable interface cursor. Disable to use mouse-based interface interaction.';
	};
	UIpointerDefaultIcon = {Bool(true);
		head = 'Interface Cursor';
		sort = 2;
		name = 'Show Default Button';
		desc = 'Show the default mouse action button.';
		advd = true;
	};
	UIpointerAnimation = {Bool(true);
		head = 'Interface Cursor';
		sort = 3;
		name = 'Enable Animation';
		desc = 'Pointer arrow rotates in the direction of travel.';
		advd = true;
	};
	UIaccessUnlimited = {Bool(false);
		head = 'Interface Cursor';
		sort = 4;
		name = 'Unlimited Navigation';
		desc = 'Allow cursor to interact with the entire interface, not only panels.';
		note = 'Combine with use on demand for full cursor control.';
		advd = true;
	};
	UIshowOnDemand = {Bool(false);
		head = 'Interface Cursor';
		sort = 5;
		name = 'Use On Demand';
		desc = 'Cursor appears on demand, instead of in response to a panel showing up.';
		note = 'Requires Toggle Interface Cursor binding & Unlimited Navigation to use the cursor.';
		advd = true;
	};
	UIholdRepeatDisable = {Bool(false);
		head = 'Interface Cursor';
		sort = 6;
		name = 'Disable Repeated Movement';
		desc = 'Disable repeated cursor movements - each click will only move the cursor once.';
	};
	UIholdRepeatDelay = {Number(.125, 0.025);
		head = 'Interface Cursor';
		sort = 7;
		name = 'Repeated Movement Delay';
		desc = 'Delay until a movement is repeated, when holding down a direction, in seconds.';
		advd = true;
	};
	UIleaveCombatDelay = {Number(0.5, 0.1);
		head = 'Interface Cursor';
		sort = 8;
		name = 'Reactivation Delay';
		desc = 'Delay before reactivating interface cursor after leaving combat, in seconds.';
		advd = true;
	};
	UIpointerSize = {Number(22, 2, true);
		head = 'Interface Cursor';
		sort = 9;
		name = 'Pointer Size';
		desc = 'Size of pointer arrow, in pixels.';
		advd = true;
	};
	UIpointerOffset = {Number(-2, 1);
		head = 'Interface Cursor';
		sort = 10;
		name = 'Pointer Offset';
		desc = 'Offset of pointer arrow, from the selected node center, in pixels.';
		advd = true;
	};
	UItravelTime = {Range(4, 1, 1, 10);
		head = 'Interface Cursor';
		sort = 11;
		name = 'Travel Time';
		desc = 'How long the cursor should take to transition from one node to another.';
		note = 'Higher is slower.';
		advd = true;
	};
	UICursorLeftClick = {Button('PAD1');
		head = 'Interface Cursor';
		sort = 12;
		name = KEY_BUTTON1;
		desc = 'Button to replicate left click. This is the primary interface action.';
		note = 'While held down, can simulate dragging by clicking on the directional pad.';
	};
	UICursorRightClick = {Button('PAD2');
		head = 'Interface Cursor';
		sort = 13;
		name = KEY_BUTTON2;
		desc = 'Button to replicate right click. This is the secondary interface action.';
		note = 'This button is necessary to use or sell an item directly from your bags.';
	};
	UICursorSpecial = {Button('PAD4');
		head = 'Interface Cursor';
		sort = 14;
		name = 'Special Button';
		desc = 'Button to handle special actions, such as adding items to the utility ring.';
	};
	UImodifierCommands = {Select('SHIFT', unpack(MODID_SELECT));
		head = 'Interface Cursor';
		sort = 15;
		name = 'Modifier';
		desc = 'Which modifier to use for modified commands';
		note = 'The modifier can be used to scroll together with the directional pad.';
		opts = MODID_SELECT;
	};
	--------------------------------------------------------------------------------------------------------
	-- Unit hotkeys:
	--------------------------------------------------------------------------------------------------------
	unitHotkeyGhostMode = {Bool(false);
		head = 'Unit Hotkeys';
		sort = 1;
		name = 'Always Show';
		desc = 'Hotkey prompts linger on unit frames after targeting.';
	};
	unitHotkeyIgnorePlayer = {Bool(false);
		head = 'Unit Hotkeys';
		sort = 2;
		name = 'Ignore Player';
		desc = 'Always ignore player, regardless of unit pool.';
	};
	unitHotkeySize = {Number(32, 1);
		head = 'Unit Hotkeys';
		sort = 3;
		name = 'Size';
		desc = 'Size of unit hotkeys, in pixels.';
	};
	unitHotkeyOffsetX = {Number(0, 1, true);
		head = 'Unit Hotkeys';
		sort = 4;
		name = 'Horizontal Offset';
		desc = 'Horizontal offset of the hotkey prompt position, in pixels.';
		advd = true;
	};
	unitHotkeyOffsetY = {Number(0, 1, true);
		head = 'Unit Hotkeys';
		sort = 5;
		name = 'Vertical Offset';
		desc = 'Vertical offset of the hotkey prompt position, in pixels.';
		advd = true;
	};
	unitHotkeyPool = {String('party%d$;raid%d+$;player$');
		head = 'Unit Hotkeys';
		sort = 6;
		name = 'Unit Pool';
		desc = 'Match criteria for unit pool, each type separated by semicolon.';
		note = '$: end of match token\n+: matches multiple tokens\n%d: matches number';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	-- Misc:
	--------------------------------------------------------------------------------------------------------
	autoExtra = {Bool(true);
		head = ACCESSIBILITY_LABEL;
		sort = 1;
		name = 'Automatically Bind Extra Items';
		desc = 'Automatically add tracked quest items and extra spells to main utility ring.';
	};
	autoSellJunk = {Bool(true);
		head = ACCESSIBILITY_LABEL;
		sort = 2;
		name = 'Automatically Sell Junk';
		desc = 'Automatically sell junk when interacting with a merchant.';
	};
	UIscale = {Number(1, 0.025, true);
		head = ACCESSIBILITY_LABEL;
		sort = 5;
		name = 'Global Scale';
		desc = 'Scale of most ConsolePort frames, relative to UI scale.';
		note = 'Action bar is scaled separately.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	-- Power Level:
	--------------------------------------------------------------------------------------------------------
	powerLevelShow = {Bool(true);
		head = 'Power Level';
		sort = 1;
		name = 'Show Gauge';
		desc = 'Display power level for the current active gamepad.';
		note = 'This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.';
		hide = CPAPI.IsClassicEraVersion;
	};
	powerLevelShowIcon = {Bool(true);
		head = 'Power Level';
		sort = 2;
		name = 'Show Type Icon';
		desc = 'Display icon next to the power level for the current active gamepad.';
		note = 'Types are PlayStation, Xbox, or Generic.';
		hide = CPAPI.IsClassicEraVersion;
	};
	powerLevelShowText = {Bool(true);
		head = 'Power Level';
		sort = 3;
		name = 'Show Status Text';
		desc = 'Display power level status text for the current active gamepad.';
		note = 'Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.';
		hide = CPAPI.IsClassicEraVersion;
	};
	--------------------------------------------------------------------------------------------------------
	-- Bindings:
	--------------------------------------------------------------------------------------------------------
	bindingOverlapEnable = {Bool(false);
		head = KEY_BINDINGS_MAC;
		sort = 1;
		name = 'Allow Binding Overlap';
		desc = 'Allow binding multiple combos to the same binding.';
		advd = true;
	};
	bindingAllowSticks = {Bool(false);
		head = KEY_BINDINGS_MAC;
		sort = 2;
		name = 'Allow Radial Bindings';
		desc = 'Allow binding discrete radial stick inputs.';
		advd = true;
	};
	bindingShowExtraBars = {Bool(false);
		head = KEY_BINDINGS_MAC;
		sort = 3;
		name = 'Show All Action Bars';
		desc = 'Show bonus bar configuration for characters without stances.';
		advd = true;
	};
	bindingDisableQuickAssign = {Bool(false);
		head = KEY_BINDINGS_MAC;
		sort = 4;
		name = 'Disable Quick Assign';
		desc = 'Disables quick assign for unbound combinations when using the gamepad action bar.';
		note = 'Requires reload.';
		advd = true;
	};
	disableHotkeyRendering = {Bool(false);
		head = KEY_BINDINGS_MAC;
		sort = 5;
		name = 'Disable Hotkey Rendering';
		desc = 'Disables customization to hotkeys on regular action bar.';
		advd = true;
	};
	useAtlasIcons = CPAPI.IsRetailVersion and {Bool(true);
		head = KEY_BINDINGS_MAC;
		sort = 6;
		name = 'Use Default Hotkey Icons';
		desc = 'Uses the default hotkey icons instead of the custom icons provided by ConsolePort.';
		note = 'Requires reload.';
	};
	emulatePADPADDLE1 = {Pseudokey('none');
		head = KEY_BINDINGS_MAC;
		sort = 7;
		name = 'Emulate '..(KEY_PADPADDLE1 or 'Paddle 1');
		desc = 'Keyboard button to emulate the paddle 1 button.';
	};
	emulatePADPADDLE2 = {Pseudokey('none');
		head = KEY_BINDINGS_MAC;
		sort = 8;
		name = 'Emulate '..(KEY_PADPADDLE2 or 'Paddle 2');
		desc = 'Keyboard button to emulate the paddle 2 button.';
	};
	emulatePADPADDLE3 = {Pseudokey('none');
		head = KEY_BINDINGS_MAC;
		sort = 9;
		name = 'Emulate '..(KEY_PADPADDLE3 or 'Paddle 3');
		desc = 'Keyboard button to emulate the paddle 3 button.';
	};
	emulatePADPADDLE4 = {Pseudokey('none');
		head = KEY_BINDINGS_MAC;
		sort = 10;
		name = 'Emulate '..(KEY_PADPADDLE4 or 'Paddle 4');
		desc = 'Keyboard button to emulate the paddle 4 button.';
	};
	interactButton = {Button('PAD1', true):Set('none', true);
		head = KEY_BINDINGS_MAC;
		sort = 11;
		name = 'Click Override Button';
		desc = 'Button or combination used to click when a given condition applies, but act as a normal binding otherwise.';
		note = 'Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.';
	};
	interactCondition = {String('[vehicleui] nil; [@target,noharm][@target,noexists][@target,harm,dead] TURNORACTION; nil');
		head = KEY_BINDINGS_MAC;
		sort = 12;
		name = 'Click Override Condition';
		desc = 'Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.';
		note = 'Takes the format of...\n'
			.. BLUE_FONT_COLOR:WrapTextInColorCode('[condition] bindingID; nil')
			.. '\n...where each condition/binding is separated by a semicolon, and "nil" clears the override.';
		advd = true;
	};
	--------------------------------------------------------------------------------------------------------
	-- Advanced:
	--------------------------------------------------------------------------------------------------------
	actionPageCondition = {String(nil);
		head = ADVANCED_OPT;
		sort = 1;
		name = 'Action Page Condition';
		desc = 'Macro condition to evaluate action bar page.';
		advd = true;
	};
	actionPageResponse = {String(nil);
		head = ADVANCED_OPT;
		sort = 2;
		name = 'Action Page Response';
		desc = 'Response to condition for custom processing.';
		advd = true;
	};
	classFileOverride = {String(nil);
		head = ADVANCED_OPT;
		sort = 3;
		name = 'Override Class File';
		desc = 'Override class theme for interface styling.';
		advd = true;
	};
})  --------------------------------------------------------------------------------------------------------
