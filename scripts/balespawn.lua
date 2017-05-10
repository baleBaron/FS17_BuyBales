--
--	bale spawn specialization v1.17 beta
--
--  ONLY PRIVATE EDITS ALLOWED
--
-- 	by baron (mve.karlsson@gmail.com)
--

BaleSpawner = {};

function BaleSpawner.prerequisitesPresent(specializations)
    return true;
end;

function BaleSpawner:load(savegame)

	self.baleParam = {};
	self.baleParam.fillLevel   	= Utils.getNoNil(getXMLInt(self.xmlFile,"vehicle.stack#fillLevel"),4000);
	self.baleParam.isWrapped	= Utils.getNoNil(getXMLBool(self.xmlFile,"vehicle.stack#isWrapped"),false);
	self.baleParam.baleFilename	= getXMLString(self.xmlFile,"vehicle.stack#baleFilename");
	
	self.bale_indices = {};
	
	local count = 0;
	while true do
		local key = "vehicle.stack.bale("..tostring(count)..")";
				
		if not hasXMLProperty(self.xmlFile,key) then
			break;
		end;
		
		local index = Utils.indexToObject(self.components,getXMLString(self.xmlFile,key.."#index"));
		table.insert(self.bale_indices,index);
		
		count = count + 1;
	end;
	
end;

function BaleSpawner:delete()
end;

function BaleSpawner:mouseEvent(posX, posY, isDown, isUp, button)
end;

function BaleSpawner:keyEvent(unicode, sym, modifier, isDown)
end;

function BaleSpawner:update(dt)
	
	if self.isServer and g_currentMission.vehiclesToDelete[self] == nil then --make sure this stack is not sold
		--flag this dummy vehicle for removal
		g_currentMission.vehiclesToDelete[self] = self;
		
		for k in pairs(self.bale_indices) do --spawn this stack
			local x,y,z 	= getWorldTranslation(self.bale_indices[k]);
			local rx,ry,rz 	= getWorldRotation	 (self.bale_indices[k]);
			local bale 		= Bale:new(self.isServer,self.isClient);
			
			bale:load(Utils.getFilename(self.baleParam.baleFilename, self.baseDirectory),x,y,z,rx,ry,rz,self.baleParam.fillLevel);
			bale:register();
			--no way to check for errors?
	
			if self.baleParam.isWrapped == true then 	
				bale:setWrappingState(1);
			end;
		end;
	end;
end;

function BaleSpawner:updateTick(dt)
end;

function BaleSpawner:draw()
end;