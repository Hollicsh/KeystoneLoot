local AddonName, KeystoneLoot = ...;

local _buttons = {};
local _lastParent;


local OverviewFrame = KeystoneLoot:GetOverview();

local TooltipFrame = CreateFrame('Frame', nil, OverviewFrame, 'TooltipBackdropTemplate');
OverviewFrame.TooltipFrame = TooltipFrame;
TooltipFrame:Hide();
TooltipFrame:SetToplevel(true);
TooltipFrame:SetFrameStrata('FULLSCREEN_DIALOG');


local function ListButton_OnEnter(self)
	self.Background:Show();
end

local function ListButton_OnLeave(self)
	self.Background:Hide();
end

local function ListButton_OnClick(self)
	local info = self.info;

	if (type(info.args) == 'table') then
		info.func(unpack(info.args));
	else
		info.func(info.args);
	end

	TooltipFrame:Hide();

	if (info.keepShownOnClick) then
		local _, parent = TooltipFrame:GetPoint();
		KeystoneLoot:ToggleDropDown(parent);
	end

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

local function CreateListButton(i)
	local Button = CreateFrame('Button', nil, TooltipFrame);
	Button:SetSize(180, 18);
	Button:SetScript('OnEnter', ListButton_OnEnter);
	Button:SetScript('OnLeave', ListButton_OnLeave);
	Button:SetScript('OnClick', ListButton_OnClick);

	if (i == 1) then
		Button:SetPoint('TOPLEFT', 15, -10);
		Button:SetPoint('TOPRIGHT', -15, -10);
	else
		Button:SetPoint('TOPLEFT', _buttons[i - 1], 'BOTTOMLEFT');
		Button:SetPoint('TOPRIGHT', _buttons[i - 1], 'BOTTOMRIGHT');
	end

	local Background = Button:CreateTexture(nil, 'BACKGROUND');
	Button.Background = Background;
	Background:Hide();
	Background:SetAllPoints();
	Background:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight');
	Background:SetBlendMode('ADD');
	Background:SetVertexColor(0.8, 0.6, 0, 1);

	local Check = Button:CreateTexture(nil, 'ARTWORK');
	Button.Check = Check;
	Check:SetSize(16, 16);
	Check:SetPoint('LEFT');
	Check:SetTexture('Interface\\Common\\UI-DropDownRadioChecks');
	Check:SetTexCoord(0.5, 1, 0, 0.5);

	local Divider = Button:CreateTexture(nil, 'BACKGROUND');
	Button.Divider = Divider;
	Divider:SetAllPoints();
	Divider:SetTexture('Interface\\Common\\UI-TooltipDivider-Transparent');

	local Text = Button:CreateFontString('ARTWORK', nil, 'GameFontHighlightSmallLeft');
	Button.Text = Text;
	Text:SetWordWrap(false);
	Text:SetPoint('LEFT', Check, 'RIGHT', 4, -1);

	table.insert(_buttons, Button);

	return Button;
end


function KeystoneLoot:ToggleDropDown(parent)
	if (TooltipFrame:IsShown()) then
		if (parent ~= _lastParent) then
			_lastParent = parent;

			TooltipFrame:Hide();
			self:ToggleDropDown(parent);
			return;
		end

		TooltipFrame:Hide();
	else
		_lastParent = parent;

		local numButtons = 0;
		local dropdownWidth = 0;
		local dropdownHeight = 0;
		local _list = parent:GetList() or {};

		if (#_list == 0) then
			_list = {{
				text = EMPTY,
				checked = false,
				notCheckable = true,
				hasGrayColor = true,
				disabled = true
			}};
		end

		for i, info in next, _list do
			if (info.disabled == nil) then
				info.disabled = false;
			end
			if (info.hasGrayColor == nil) then
				info.hasGrayColor = false;
			end

			local Button = _buttons[i] or CreateListButton(i);
			Button:Show();

			local Check = Button.Check;
			local Divider = Button.Divider;
			local Text = Button.Text;

			local leftPadding = 0;

			if (info.divider) then
				Button:Disable();
				Button:SetHeight(8);
				Check:Hide();
				Divider:Show();
				Text:SetText('');

				dropdownHeight = dropdownHeight + 8;
			else
				Button:SetHeight(18);
				Check:Show();
				Divider:Hide();
				Text:SetText(info.text);

				Button:SetEnabled(not info.disabled);

				if (info.hasGrayColor) then
					Button.Text:SetFontObject('GameFontDisableSmallLeft');
				else
					Button.Text:SetFontObject('GameFontHighlightSmallLeft');
				end

				if (info.checked) then
					Check:SetTexCoord(0, 0.5, 0, 0.5);
				else
					Check:SetTexCoord(0.5, 1, 0, 0.5);
				end

				if (info.notCheckable) then
					Check:SetAlpha(0);
					leftPadding = leftPadding - 20;
				else
					Check:SetAlpha(1);
				end

				if (info.leftPadding) then
					leftPadding = leftPadding + info.leftPadding;
				end

				Check:SetPoint('LEFT', leftPadding, 1);

				dropdownHeight = dropdownHeight + 18;
			end

			Button.info = info;

			dropdownWidth = math.max(dropdownWidth, Button.Text:GetWidth() + leftPadding);
			numButtons = numButtons + 1;
		end

		for i=(numButtons + 1), #_buttons do
			local Button = _buttons[i];
			Button:Hide();
		end

		TooltipFrame:SetSize(dropdownWidth + 50, dropdownHeight + 20);
		TooltipFrame:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', 5, 0);
		TooltipFrame:Show();
	end
end