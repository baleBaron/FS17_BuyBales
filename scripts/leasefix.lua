--
-- Disable leasing for the "bale_stack" vehicle.
--
-- This is done by disguising the shop item as an object while in the shop screen
-- But treat it as a vehicle when bought
--
-- By: baron <mve.karlsson@gmail.com>
--

noLeaseXmlFile = { g_currentModDirectory .. "stack_round_8_hay.xml", 
                   g_currentModDirectory .. "stack_round_8_silage.xml",
                   g_currentModDirectory .. "stack_round_8_straw.xml",
                   g_currentModDirectory .. "stack_square_8_hay.xml",
                   g_currentModDirectory .. "stack_square_8_straw.xml"
                 }

NoBaleLease = {}
addModEventListener(NoBaleLease)

function NoBaleLease:loadMap()
    ShopScreen.onBuy        = Utils.overwrittenFunction(ShopScreen.onBuy,       NoBaleLease.onBuy)
    ShopScreen.onYesNoBuyObject = Utils.overwrittenFunction(ShopScreen.onYesNoBuyObject, NoBaleLease.onYesNoBuyObject)

    for _, xmlFile in pairs(noLeaseXmlFile) do
        local item = StoreItemsUtil.storeItemsByXMLFilename[string.lower(xmlFile)]
        
        if item ~= nil then
            item.runningLeasingFactor = nil
            item.species = "object"
            item.isBuyBalesItem = true
        end
    end
end

function NoBaleLease:deleteMap()
end

function NoBaleLease:mouseEvent(posX, posY, isDown, isUp, button)
end

function NoBaleLease:keyEvent(unicode, sym, modifier, isDown)
end

function NoBaleLease:update(dt)
end

function NoBaleLease:draw()
end

function NoBaleLease:onBuy(superFunc, storeItem, ...)
    self.isBuyingBales = storeItem.isBuyBalesItem
    superFunc(self, storeItem, ...)
end

function NoBaleLease:onYesNoBuyObject(superFunc, purchaseConfirmed, ...)
    if self.isBuyingBales and purchaseConfirmed then
        self.ignoreOnClose = false
        self:finalizeBuy()
    else
        superFunc(self, purchaseConfirmed, ...)
    end
end
