local _, env = ...;
---------------------------------------------------------------
local Skins = {}; env.LIB.Skin.ClusterBar = Skins;
---------------------------------------------------------------
local NOMOD = env.ClusterConstants.ModNames();
---------------------------------------------------------------
local Masks = env.ClusterConstants.Masks;
local Swipes = env.ClusterConstants.Swipes;
local Assets = env.ClusterConstants.Assets;
local AdjustTextures = env.ClusterConstants.AdjustTextures;
local GetIconMask = env.LIB.SkinUtility.GetIconMask;
local GetHighlightTexture = env.LIB.SkinUtility.GetHighlightTexture;
local GetSlotBackground = env.LIB.SkinUtility.GetSlotBackground;
local SkinOverlayGlow = env.LIB.Skin.ColorSwatchProc;
local SkinChargeCooldown = env.LIB.SkinUtility.SkinChargeCooldown;
---------------------------------------------------------------

local function SetRotatedMaskTexture(self, mask, prefix, direction)
    local maskTexture = Masks[prefix][direction];
    mask:SetTexture(maskTexture)
    self.Flash:SetTexture(maskTexture)
end

local function SetRotatedSwipeTexture(self, prefix, direction)
    local cooldown, swipeTexture = self.cooldown, Swipes[prefix][direction];
    self.__procText, self.__procSize = swipeTexture, 0.6;
    cooldown:SetSwipeTexture(swipeTexture)
    cooldown:SetDrawBling(false, true)
    cooldown:SetAllPoints()
end

local function SetMainSwipeTexture(self)
    local cooldown = self.cooldown;
    cooldown:SetSwipeTexture(Assets.MainSwipe)
    cooldown:SetEdgeTexture(Assets.CooldownEdge)
    cooldown:SetBlingTexture(Assets.CooldownBling)
    cooldown:SetDrawEdge(true)
    cooldown:SetUseCircularEdge(true)
    cooldown:SetPoint('TOPLEFT', self.icon, 'TOPLEFT', 3, -3)
    cooldown:SetPoint('BOTTOMRIGHT', self.icon, 'BOTTOMRIGHT', -3, 3)
    self.__procText, self.__procSize = Assets.MainSwipe, 0.62;
    if self.swipeColor then
        cooldown:SetSwipeColor(self.swipeColor:GetRGBA())
    end
end

local function SetTextures(self, adjustTextures, coords, texSize)
    for key, file in pairs(adjustTextures) do
        local texture = self[key];
        if texture then
            if coords then
                texture:SetTexCoord(unpack(coords))
            end
            texture:SetTexture(file)
            texture:ClearAllPoints()
            texture:SetPoint('CENTER', 0, 0)
            texture:SetSize(texSize, texSize)
        end
    end
    GetHighlightTexture(self):SetBlendMode('ADD')
    if self.borderColor then
        self.NormalTexture:SetVertexColor(self.borderColor:GetRGBA())
    end
end

local function SetBackground(self, mask)
    local bg = GetSlotBackground(self)
    bg:SetDrawLayer('BACKGROUND', -8)
    bg:SetAllPoints(self.icon)
    bg:SetTexture(Assets.EmptyIcon)
    bg:AddMaskTexture(mask)
    bg:SetDesaturated(true)
    bg:SetVertexColor(0.5, 0.5, 0.5, 1)
    if ( self.mod == NOMOD ) then
        mask:SetTexture(Assets.MainMask)
    end
    mask:SetAllPoints(self.icon)
end

local function OnChargeCooldownSet(self)
    self:SetUseCircularEdge(true)
    self:SetEdgeTexture(Assets.CooldownEdge)
end

local function OnChargeCooldownUnset(self)
    self:SetUseCircularEdge(false)
end

for mod, data in pairs(env.ClusterConstants.Layout) do
    local prefix  = data.Prefix;
    local offset  = data.TexSize or 1;
    local adjust  = AdjustTextures[mod];

    Skins[mod] = function(self, force)
        local direction = self.direction;
        if direction then
            SetRotatedSwipeTexture(self, prefix, direction)
        else
            SetMainSwipeTexture(self)
        end
        SkinChargeCooldown(self, OnChargeCooldownSet, OnChargeCooldownUnset)

        if not force then return end;
        local size = self:GetSize()
        local mask = GetIconMask(self)
        local coords = direction and data[direction].Coords;
        SetTextures(self, adjust, coords, size * offset)
        SetBackground(self, mask)
        if direction then
            SetRotatedMaskTexture(self, mask, prefix, direction)
        end
        SkinOverlayGlow(self)
    end;
end