local HEARTOFAZEROTH_ITEMID = 158075
local L_APINFO
local L_APPERCENT
do
    local locale = GetLocale()
    if locale == "enUS" then
        L_APINFO    = "Artifact Power: %d/%d"
        L_APPERCENT = "%d%%"
    end
end

-- Handle wrapping the given text in artifact colour markup
local ColourWrapper
do
    -- These colour constants are located within the FrameXML Constants.lua
    local itemQuality = Enum.ItemQuality
    local rgb = BAG_ITEM_QUALITY_COLORS[itemQuality.Artifact]
    local colour = CreateColor(rgb.r, rgb.g, rgb.b)

    ColourWrapper = function(text)
        return colour:WrapTextInColorCode(text)
    end
end

-- Get the AP Info for the Heart of Azeroth
local GetHeartOfAzerothAPInfo
do
    local FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
    local GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo

    GetHeartOfAzerothAPInfo = function()
        local itemLocation = FindActiveAzeriteItem()

        if not itemLocation then
            return
        end

        local curXP, maxXP = GetAzeriteItemXPInfo(itemLocation)
        local percentXP = (curXP / maxXP) * 100

        return curXP, maxXP, percentXP
    end
end

-- Handle the hook
local function addon(tooltip, ...)
    -- Return if this isn't the tooltip for one of our items.
    -- This prevents showing AP on a [Heart of Azeroth] that someone may have
    -- linked in chat, etc.
    if not tooltip:IsEquippedItem() then
        return
    end

    local name, link = tooltip:GetItem()
    if link then
        local item = Item:CreateFromItemLink(link)
        local itemId = item:GetItemID()

        -- Ensure that we're really looking at a [Heart of Azeroth]
        if itemId == HEARTOFAZEROTH_ITEMID then
            local curXP, maxXP, percentXP = GetHeartOfAzerothAPInfo()

            if curXP then
                tooltip:AddDoubleLine(
                    ColourWrapper(L_APINFO:format(curXP, maxXP)),
                    ColourWrapper(L_APPERCENT:format(percentXP))
                )
            end
        end
    end
end
GameTooltip:HookScript("OnTooltipSetItem", addon)
