--
--	BaleSpawner object
--
-- 	By: baron <mve.karlsson@gmail.com>
--

BaleSpawner = {}
BaleSpawner_mt = Class(BaleSpawner, Object)
getfenv(0)["BaleSpawner"] = BaleSpawner

function BaleSpawner:new(isServer, isClient, customMt)
    local mt = customMt
    if mt == nil then
        mt = BaleSpawner_mt
    end

    local self = Object:new(isServer, isClient, mt)
    registerObjectClassName(self, "BaleSpawner")

    return self
end

function BaleSpawner:delete()
    unregisterObjectClassName(self)
    BaleSpawner:superClass().delete(self)
end

function BaleSpawner:load(_, x, y, z, rx, ry, rz, xmlFilename)
    local _, baseDirectory = getModNameAndBaseDirectory(xmlFilename)
    local xmlFile = loadXMLFile("tempObjectXML", xmlFilename)

    if xmlFile ~= nil then
        local isSpawned = true

        -- load xml parameters
        local stackI3DFilename 
        local baleParam = {}

        stackI3DFilename = Utils.getFilename(getXMLString(xmlFile, "object.filename"), baseDirectory)
        baleParam.fillLevel = Utils.getNoNil(getXMLInt(xmlFile, "object.stack#fillLevel"), 4000)
        baleParam.isWrapped = Utils.getNoNil(getXMLBool(xmlFile, "object.stack#isWrapped"), false)
        baleParam.baleFilename = Utils.getFilename(getXMLString(xmlFile, "object.stack#baleFilename"), baseDirectory)

        -- load i3d to find bale nodes
        local stackRoot = Utils.loadSharedI3DFile(stackI3DFilename)
        local stackNode = getChildAt(stackRoot, 0)
        local stackTransform = createTransformGroup("stackTransform")

        setTranslation(stackTransform, x, y, z)
        setRotation(stackTransform, rx, ry, rz)
        link(stackTransform,stackNode)

        delete(stackRoot)

        -- spawn this stack of bales
        local spawnedBales = {}
        local i = 0
        while true do
            local key = "object.stack.bale("..tostring(i)..")"

            if not hasXMLProperty(xmlFile, key) then
                break
            elseif not g_currentMission:getCanAddLimitedObject(FSBaseMission.LIMITED_OBJECT_TYPE_BALE) then
                for _, bale in pairs(spawnedBales) do
                    bale:delete()
                end
                
                isSpawned = false
                break
            else
                local baleNode = Utils.indexToObject(stackNode,getXMLString(xmlFile, key.."#index"));
                local x, y, z = getWorldTranslation(baleNode)
                local rx, ry, rz = getWorldRotation(baleNode)

                local baleObject = Bale:new(self.isServer, self.isClient)
                baleObject:load(baleParam.baleFilename, x, y, z, rx, ry, rz, baleParam.fillLevel)
                baleObject:register()
                baleObject:setWrappingState(baleParam.isWrapped and 1 or 0)
                baleObject.isBuyBale = true

                table.insert(spawnedBales,baleObject)
                
                i = i + 1
            end
        end

        -- cleanup
        delete(xmlFile)
        delete(stackTransform)
        Utils.releaseSharedI3DFile(stackI3DFilename, nil, true)

        return isSpawned
    end

    return false
end

function BaleSpawner:setFillLevel(fillLevel, setDirty)
end

function BaleSpawner:update(dt)
    if self.isServer then
        self:delete()
    end
end