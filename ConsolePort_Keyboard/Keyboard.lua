local Keyboard, Radial, db = CPAPI.EventHandler(ConsolePortKeyboard, {'PLAYER_LOGOUT'}), ConsolePortRadial, ConsolePort:DB();
local L, _, env = db.Locale, ...;
local VALID_VEC_LEN, VALID_DSP_LEN = 0.5, 0.15;

---------------------------------------------------------------
-- Hardware events
---------------------------------------------------------------

function Keyboard:Left(x, y, len)
	self:ReflectStickPosition(x, y, len, len > VALID_VEC_LEN)

	local oldFocusSet = self.focusSet;
	self.focusSet = len > VALID_VEC_LEN and
		self.Registry[Radial:GetIndexForStickPosition(x, y, len, self.numSets)]

	local isNewFocusSet = oldFocusSet ~= self.focusSet;
	if oldFocusSet and isNewFocusSet then
		oldFocusSet:OnStickChanged(0, 0, 0, false)
		oldFocusSet:SetHighlight(false)
	end
	if isNewFocusSet and self.focusSet then
		self.focusSet:SetHighlight(true)
	end
end

function Keyboard:Right(x, y, len)
	if self.focusSet then
		self.focusSet:OnStickChanged(x, y, len, len > VALID_DSP_LEN)
	end
	if not self.inputLock and len > VALID_VEC_LEN then
		self.inputLock = true;
		self:Insert()
	elseif len <= VALID_VEC_LEN then
		self.inputLock = false;
	end
end

function Keyboard:OnGamePadStick(stick, x, y, len)
	if self[stick] then
		self[stick](self, x, y, len)
	end
	self:SetPropagateKeyboardInput(false)
end

function Keyboard:OnGamePadButtonDown(button)
	local callback = self.commands[button];
	if callback then
		callback(self, button)
		return self:SetPropagateKeyboardInput(false)
	end
	self:SetPropagateKeyboardInput(true)
end

function Keyboard:OnFocusChanged(frame)
	self:SetShown(frame)
	self.focusFrame = frame;
end

function Keyboard:SetState(state)
	if not self:IsShown() then return end
	if self.state == state then return end

	self.state = state;
	for widget in self:EnumerateActive() do
		widget:SetState(state)
	end
end

function Keyboard:OnShow()
	ConsolePortUIHandle:SetHintFocus(self)
	for _, data in ipairs(self.hints) do
		local text, key = unpack(data)
		if text and key then
			ConsolePortUIHandle:AddHint(key, text)
		end
	end
end

function Keyboard:OnHide()
	if ConsolePortUIHandle:IsHintFocus(self) then
		ConsolePortUIHandle:HideHintBar()
	end
	ConsolePortUIHandle:ClearHintsForFrame(self)
end

---------------------------------------------------------------
-- Input scripts
---------------------------------------------------------------
local utf8 = env.utf8;

function Keyboard:Insert()
	local key = self.focusSet and self.focusSet.focusKey;
	if key then
		self.focusFrame:Insert(key:GetText())
		key:Flash()
	end
end

function Keyboard:Erase()
	local pos = self.focusFrame:GetUTF8CursorPosition()
	if pos ~= 0 then
		local text, offset = (self.focusFrame:GetText())
		-- TODO: handle markers

		local newText = 
			utf8.sub(text, 0, offset and pos - offset or pos - 1) .. -- prefix
			utf8.sub(text, pos + 1, utf8.len(text) - pos);           -- suffix
		self.focusFrame:SetText(newText)
		self.focusFrame:SetCursorPosition(utf8.pos(newText, offset and pos - offset or pos - 1))
	end
end

function Keyboard:Enter()
	ExecuteFrameScript(self.focusFrame, 'OnEnterPressed')
	if self.cachedFocusText then
		env.DictHandler:Update(env.Dictionary, self.cachedFocusText)
		self.cachedFocusText = nil;
	end
end

function Keyboard:Space()
	ExecuteFrameScript(self.focusFrame, 'OnSpacePressed')
	self.focusFrame:Insert(' ')
end

function Keyboard:Escape()
	ExecuteFrameScript(self.focusFrame, 'OnEscapePressed')
end

function Keyboard:MoveLeft()
	local text, pos = self.focusFrame:GetText(), self.focusFrame:GetUTF8CursorPosition()
	local marker = text:sub(pos - 4, pos):find('{rt%d}')
	self.focusFrame:SetCursorPosition(utf8.pos(text, marker and pos - 5 or pos - 1))
end

function Keyboard:MoveRight()
	local text, pos = self.focusFrame:GetText(), self.focusFrame:GetUTF8CursorPosition()
	local marker = text:sub(pos, pos + 5):find('{rt%d}')
	self.focusFrame:SetCursorPosition(utf8.pos(text, marker and pos + 5 or pos + 1))
end

function Keyboard:PrevWord()
	self:SetAutoCorrectIndexDelta(-1)
end

function Keyboard:NextWord()
	self:SetAutoCorrectIndexDelta(1)
end

---------------------------------------------------------------
-- Auto correct handling
---------------------------------------------------------------

do -- Auto correct suggestion buttons
	local autoCorrectContainer = Keyboard.AutoCorrectContainer;
	local autoCorrectPool = CreateFramePool('Button', autoCorrectContainer, 'ConsolePortKeyboardACButton')
	Keyboard.acWidgets = {};

	local function OnAutoCorrectSuggestionsUpdated(result, iterator)
		local widgets, i = wipe(Keyboard.acWidgets), 1;
		for word, weight in iterator(result) do
			local widget, newObj = autoCorrectPool:Acquire()
			widget.Text:SetText(word)
			widget:Show()
			widgets[i], i = widget, i + 1;
			if i > 8 then
				break
			end
		end

		autoCorrectContainer:SetHeight(#widgets * 20)
		local prev;
		for i, widget in ipairs(widgets) do
			widget:SetPoint('TOP', prev or autoCorrectContainer, prev and 'BOTTOM' or 'TOP', 0, 0)
			prev = widget;
		end

		Keyboard:OnSuggestionsChanged(result, iterator)
	end

	function Keyboard:OnTextChanged(text, pos)
		local word = utf8.getword(text, pos);
		autoCorrectPool:ReleaseAll()
		env:GetAutoCorrectSuggestions(word, env.Dictionary, OnAutoCorrectSuggestionsUpdated)
		self.cachedFocusText = text;
	end
end

function Keyboard:OnSuggestionsChanged(result, iterator)
	self.acCurIndex, self.acMaxIndex = 1, #self.acWidgets;
	self:SetAutoCorrectIndex(self.acCurIndex)
end

function Keyboard:SetAutoCorrectIndexDelta(delta)
	if self.acCurIndex and self.acMaxIndex then
		self:SetAutoCorrectIndex(Clamp(self.acCurIndex + delta, 1, self.acMaxIndex))
	end
end

function Keyboard:SetAutoCorrectIndex(index)
	self.acText, self.acCurIndex = nil, index;
	for i, widget in ipairs(self.acWidgets) do
		widget.Hilite:SetAlpha(0)
	end
	local widget = self.acWidgets[index];
	if widget then
		widget.Hilite:SetAlpha(1)
		self.acText = widget.Text:GetText()
	end
end

function Keyboard:AutoCorrect()
	if self.acText then
		local text, word = self.focusFrame:GetText(), self.acText;
		local _, startPos, endPos = utf8.getword(text, self.focusFrame:GetUTF8CursorPosition())
		if text and word and startPos and endPos then
			self.focusFrame:SetText(text:sub(0, startPos - 1) .. word .. text:sub(endPos + 1))
		end
	end
end

---------------------------------------------------------------
-- Data handling
---------------------------------------------------------------

function Keyboard:OnDataLoaded(...)
	self:OnVariableChanged()

	if not ConsolePort_KeyboardLayout then
		ConsolePort_KeyboardLayout = CopyTable(env.DefaultLayout)
	end
	if not ConsolePort_KeyboardMarkers then
		ConsolePort_KeyboardMarkers = CopyTable(env.DefaultMarkers)
	end
	if not ConsolePort_KeyboardDictionary then
		ConsolePort_KeyboardDictionary = env.DictHandler:Generate()
	end

	env.Layout     = ConsolePort_KeyboardLayout;
	env.Markers    = ConsolePort_KeyboardMarkers;
	env.Dictionary = ConsolePort_KeyboardDictionary;

	self:ReleaseAll()
	self.numSets = #ConsolePort_KeyboardLayout;
	for i, set in ipairs(ConsolePort_KeyboardLayout) do
		local widget, newObj = self:Acquire(i)
		if newObj then
			widget:OnLoad()
		end
		widget:SetPoint('CENTER', Radial:GetPointForIndex(i, self.numSets, self:GetSize()/1.75))
		widget:SetData(set)
		widget:Show()
	end
end

function Keyboard:OnVariableChanged()
	self.commands = {
		[db('keyboardEnterButton')]     = self.Enter;
		[db('keyboardEraseButton')]     = self.Erase;
		[db('keyboardSpaceButton')]     = self.Space;
		[db('keyboardEscapeButton')]    = self.Escape;
		[db('keyboardInsertButton')]    = self.Insert;
		[db('keyboardMoveLeftButton')]  = self.MoveLeft;
		[db('keyboardMoveRightButton')] = self.MoveRight;
		[db('keyboardNextWordButton')]  = self.NextWord;
		[db('keyboardPrevWordButton')]  = self.PrevWord;
		[db('keyboardAutoCorrButton')]  = self.AutoCorrect;
	};
	self.hints = {
		{L'Enter',   db('keyboardEnterButton')};
		{L'Erase',   db('keyboardEraseButton')};
		{L'Space',   db('keyboardSpaceButton')};
		{L'Escape',  db('keyboardEscapeButton')};
		{L'Insert',  db('keyboardInsertButton')};
		{L'Correct', db('keyboardAutoCorrButton')};
	};
	-- update dictionary pattern
	env.DictMatchPattern  = db('keyboardDictPattern');
	env.DictMatchAlphabet = db('keyboardDictAlphabet');
end

db:RegisterCallbacks(Keyboard.OnVariableChanged, Keyboard,
	'Settings/keyboardInsertButton',
	'Settings/keyboardEraseButton',
	'Settings/keyboardEnterButton',
	'Settings/keyboardSpaceButton',
	'Settings/keyboardEscapeButton',
	'Settings/keyboardDictPattern',
	'Settings/keyboardDictAlphabet'
);

function Keyboard:PLAYER_LOGOUT()
	env.DictHandler:Normalize(env.Dictionary)
end

---------------------------------------------------------------
-- Init
---------------------------------------------------------------
Keyboard:EnableGamePadStick(true)
Keyboard.Arrow:SetSize(50*0.71, 400*0.71)
Keyboard:SetScript('OnShow', Keyboard.OnShow)
Keyboard:SetScript('OnHide', Keyboard.OnHide)
Keyboard:SetScript('OnUpdate', Keyboard.OnUpdate)
Keyboard:SetScript('OnGamePadStick', Keyboard.OnGamePadStick)
Keyboard:SetScript('OnGamePadButtonDown', Keyboard.OnGamePadButtonDown)
CPFocusPoolMixin.CreateFramePool(Keyboard, 'PieMenu', 'ConsolePortKeyboardSet', env.CharsetMixin)