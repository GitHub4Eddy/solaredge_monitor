-- SolarEdge Monitor Classes Childs


class 'solarPower'(QuickAppChild)
function solarPower:__init(dev)
  QuickAppChild.__init(self,dev)
end
function solarPower:updateValue(data) 
  self:updateProperty("value", tonumber(data.solarPower))
  self:updateProperty("unit", "Watt/m²")
  self:updateProperty("log", data.peakPower .." kWp / " ..solarM2 .." m²")
end

class 'lastDayData'(QuickAppChild)
function lastDayData:__init(dev)
  QuickAppChild.__init(self,dev) 
  --self:trace("Retrieved value from lastDayData: " ..self.properties.value) 
  data.prevlastDayData = string.format("%.1f", self.properties.value) -- Initialize prevlastDayData with value of child device
  if fibaro.getValue(self.id, "rateType") ~= "production" then 
    self:updateProperty("rateType", "production")
    self:warning("Changed rateType interface of SolarEdge lastDayData child device (" ..self.id ..") to production")
    if not fibaro.getValue(self.id, "storeEnergyData") then
     self:updateProperty("storeEnergyData", false)
     self:warning("Configured storeEnergyData property of lastDayData child device (" ..self.id ..") to true")
    end
  end
end
function lastDayData:updateValue(data) 
  self:updateProperty("value", tonumber(data.lastDayData))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", "")
end

class 'lastMonthData'(QuickAppChild)
function lastMonthData:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "production" then 
    self:updateProperty("rateType", "production")
    self:warning("Changed rateType interface of SolarEdge lastMonthData child device (" ..self.id ..") to production")
    if not fibaro.getValue(self.id, "storeEnergyData") then
      self:updateProperty("storeEnergyData", false)
      self:warning("Configured storeEnergyData property of lastMonthData child device (" ..self.id ..") to false")
    end
  end
end
function lastMonthData:updateValue(data) 
  self:updateProperty("value", tonumber(data.lastMonthData))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", "")
end

class 'lastYearData'(QuickAppChild)
function lastYearData:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "production" then 
    self:updateProperty("rateType", "production")
    self:warning("Changed rateType interface of SolarEdge lastYearData child device (" ..self.id ..") to production")
    if not fibaro.getValue(self.id, "storeEnergyData") then
      self:updateProperty("storeEnergyData", false)
      self:warning("Configured storeEnergyData property of lastYearData child device (" ..self.id ..") to false")
    end
  end
end
function lastYearData:updateValue(data) 
  self:updateProperty("value", tonumber(data.lastYearData))
  self:updateProperty("unit", data.lastYearUnit)
  self:updateProperty("log", "")
end

class 'lifeTimeData'(QuickAppChild)
function lifeTimeData:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "production" then 
    self:updateProperty("rateType", "production")
    self:warning("Changed rateType interface of SolarEdge lifeTimeData child device (" ..self.id ..") to production")
    if not fibaro.getValue(self.id, "storeEnergyData") then
      self:updateProperty("storeEnergyData", false)
      self:warning("Configured storeEnergyData property of lifeTimeData child device (" ..self.id ..") to false")
    end
  end
end
function lifeTimeData:updateValue(data) 
  self:updateProperty("value", tonumber(data.lifeTimeData))
  self:updateProperty("unit", data.lifeTimeUnit)
  self:updateProperty("log", data.lifeTimeData_revenue)
end

-- EOF