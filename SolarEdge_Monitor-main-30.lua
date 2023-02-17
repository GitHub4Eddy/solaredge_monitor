-- Quickapp SolarEdge Monitor main


local function getChildVariable(child,varName)
  for _,v in ipairs(child.properties.quickAppVariables or {}) do
    if v.name==varName then return v.value end
  end
  return ""
end


function QuickApp:updateChildDevices()
  for id,child in pairs(self.childDevices) do -- Update Child Devices
    child:updateValue(data) 
  end
end


function QuickApp:logging(level,text) -- Logging function for debug
  if tonumber(debugLevel) >= tonumber(level) then 
      self:debug(text)
  end
end


function QuickApp:solarPower(power, m2) -- Calculate Solar Power M2
  self:logging(3,"QuickApp:solarPower()")
  if m2 > 0 and power > 0 then
    solarPower = power / m2
  else
    solarPower = 0
  end
  return solarPower
end


function QuickApp:unitCheckWh(measurement) -- Set the measurement and unit to kWh, MWh or GWh
  self:logging(3,"QuickApp:unitCheckWh()")
  if measurement > 1000000000 then
    return string.format("%.1f",measurement/1000000000),"GWh"
  elseif measurement > 1000000 then
    return string.format("%.1f",measurement/1000000),"MWh"
  elseif measurement > 1000 then
    return string.format("%.1f",measurement/1000),"kWh"
  else
    return string.format("%.0f",measurement),"Wh"
  end
end


function QuickApp:simData() -- Simulate SolarEdge Monitor
  self:logging(3,"QuickApp:simData()")
  local jsonTableDetails = json.decode('{"details":{"id":1234567, "name":"NAME-INSTALLATION", "accountId":123456, "status":"Active", "peakPower":6.8, "lastUpdateTime":"2022-02-01", "currency":"EUR", "installationDate":"2021-02-01", "ptoDate":null, "notes":"", "type":"Optimizers&Inverters", "location":{"country":"Earth", "city":"SimCity", "address":"Street1", "address2":"", "zip":"1234AA", "timeZone":"Europe/Amsterdam", "countryCode":"EU"}, "primaryModule":{"manufacturerName":"LG", "modelName":"LG340", "maximumPower":340}, "uris":{"DETAILS":"/site/1234567/details", "DATA_PERIOD":"/site/1234567/dataPeriod", "OVERVIEW":"/site/1234567/overview"}, "publicSettings":{"isPublic":false}}}')
  local jsonTableEnvBenefits = json.decode('{"envBenefits": { "gasEmissionSaved": {"units": "kg", "co2": 674.93066, "so2": 874.65515,"nox": 278.92545 }, "treesPlanted": 2.2555082200000003, "lightBulbs": 5217.4604 }}') -- Metrics response
  -- local jsonTableEnvBenefits = json.decode('{"envBenefits": { "gasEmissionSaved": {"units": "lb", "co2": 1486.63, "so2": 1926.55, "nox": 614.37 }, "treesPlanted": 2.2555082200000003, "lightBulbs": 5217.4604 }}') -- Imperial response
  local jsonTable = json.decode('{"overview":{"lastUpdateTime":"2021-08-12 13:46:04","lifeTimeData":{"energy":7827878.0,"revenue":1728.5211},"lastYearData":{"energy":573242.0},"lastMonthData":{"energy":113386.0},"lastDayData":{"energy":7373.0},"currentPower":{"power":134.73499},"measuredBy":"INVERTER"}}') -- With revenue

  self:valuesDetails(jsonTableDetails) -- Get the values from Details
  self:valuesEnvBenefits(jsonTableEnvBenefits) -- Get the values from EnvBenefits
  self:valuesOverview(jsonTable) -- Get the values from Overview
  self:updateLabels() -- Update the labels
  self:updateProperties() -- Update the properties
  self:updateChildDevices() -- Update the Child Devices

  self:logging(3,"Timeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function() 
     self:simData()
  end)
end


function QuickApp:updateProperties() -- Update the properties
  self:logging(3,"QuickApp:updateProperties()")
  self:updateProperty("value", tonumber(data.currentPower))
  self:updateProperty("power", tonumber(data.currentPower))
  self:updateProperty("unit", "Watt")
  self:updateProperty("log", data.lastUpdateTime)
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"QuickApp:updateLabels()")
  local labelText = ""
  if debugLevel == 4 then
    labelText = labelText ..translation["SIMULATION MODE"]  .."\n\n"
  end
  
  labelText = labelText ..translation["Current power"] ..": " ..data.currentPower .." Watt" .."\n\n"
  
  labelText = labelText ..translation["Peakpower"] ..": " ..data.peakPower .." kWp" .."\n"
  labelText = labelText ..translation["Solar power"] ..": " ..data.solarPower .." Watt/m² (" ..solarM2 .." m²)" .."\n"
  labelText = labelText ..translation["Lastday"] ..": " ..data.lastDayData .." kWh" .."\n"
  labelText = labelText ..translation["Lastmonth"] ..": " ..data.lastMonthData .." kWh" .."\n"
  labelText = labelText ..translation["Lastyear"] ..": " ..data.lastYearData .." " ..data.lastYearUnit .."\n"
  labelText = labelText ..translation["Lifetime"] ..": " ..data.lifeTimeData .." " ..data.lifeTimeUnit .." (" ..data.lifeTimeData_revenue ..")" .."\n\n"
  
  labelText = labelText ..translation["Environmental Benefits"] ..": " .."\n"
  labelText = labelText ..translation["CO2"] ..": " ..data.co2 .." " ..data.units .."\n"
  labelText = labelText ..translation["SO2"] ..": " ..data.so2 .." " ..data.units .."\n"
  labelText = labelText ..translation["NOX"] ..": " ..data.nox .." " ..data.units .."\n"
  labelText = labelText ..translation["Trees planted"] ..": " ..data.treesPlanted .."\n"
  labelText = labelText ..translation["Lightbulbs"] ..": " ..data.lightBulbs .."\n\n"
  
  labelText = labelText ..translation["SolarEdge installation"] ..": " .."\n"
  labelText = labelText ..translation["Type"] ..": " ..data.type .."\n"
  labelText = labelText ..translation["Module"] ..": " ..data.manufacturerName .."\n"
  labelText = labelText ..translation["Model"] ..": " ..data.modelName .."\n"
  labelText = labelText ..translation["Maximum Power"] ..": " ..data.maximumPower .."\n\n"
  
  labelText = labelText ..translation["Last update"] ..": " ..data.lastUpdateTime .."\n"

  self:updateView("label", "text", labelText)
  self:logging(2,labelText)
end


function QuickApp:sunsetCheck() -- Check for sunset and sleep time
  self:logging(3,"QuickApp:sunsetCheck()")
  local sunset = fibaro.getValue(1, "sunsetHour")
  if sunset < os.date("%H:%M") and interval == tonumber(self:getVariable("interval")) then -- Sunset change interval when interval is set regular
    self:logging(3, "Sunset at " ..sunset .." < Current time " ..os.date("%H:%M"))
    local pause = ((2400 - os.date("%H%M")) + (fibaro.getValue(1, "sunriseHour"):gsub(":","")))*60*60/100 - (interval*2) -- Time in seconds minus two interval rounds  
    interval = tonumber(string.format("%.0f", pause)) -- Set new interval time in seconds
    self:logging(3,"SET Timeout to " ..interval .." seconds")
  elseif interval ~= tonumber(self:getVariable("interval")) then-- Reset Reset interval to regular
    interval = tonumber(self:getVariable("interval")) 
    data.lastUpdateTime = "Paused" -- Change log text main device
    self:logging(3,"RESET Timeout to " ..interval .." seconds")
  else  -- Daytime
    self:logging(3, "Sunset at " ..sunset .." > Current time " ..os.date("%H:%M"))
  end
end


function QuickApp:valuesCheck() -- Check for decreasing Cloud values for lastDayData
  self:logging(3,"QuickApp:valuesCheck()")
  self:logging(3,"Previous lastDayData: " ..data.prevlastDayData .. " / Next lastDayData: " ..data.lastDayData)
  if tonumber(data.lastDayData) < tonumber(data.prevlastDayData) and tonumber(data.prevlastDayData) ~= 0 and tonumber(data.lastDayData) ~= 0 then -- Decreasing value
    self:logging(2,"Decreasing value lastDayData ignored (Energy Panel Child Device), previous value: " ..data.prevlastDayData .." next value: " ..data.lastDayData)
    data.lastDayData = string.format("%.1f", data.prevlastDayData) -- Restore previous (higher) lastDayData value
  else
    data.prevlastDayData = string.format("%.1f", data.lastDayData) -- Save lastDayData to prevlastDayData only in case of increasing value
  end
end


function QuickApp:valuesEnvBenefits(table) --Get the values from json file Environmental Benefits
  self:logging(3,"QuickApp:valuesEnvBenefits()")
  local jsonTableEnvBenefits = table
  data.units = jsonTableEnvBenefits.envBenefits.gasEmissionSaved.units or "kg"
  data.co2 = string.format("%.0f", jsonTableEnvBenefits.envBenefits.gasEmissionSaved.co2 or "0") 
  data.so2 = string.format("%.0f", jsonTableEnvBenefits.envBenefits.gasEmissionSaved.so2 or "0") 
  data.nox = string.format("%.0f", jsonTableEnvBenefits.envBenefits.gasEmissionSaved.nox or "0") 
  data.treesPlanted = string.format("%.0f", jsonTableEnvBenefits.envBenefits.treesPlanted or "0") 
  data.lightBulbs = string.format("%.0f", jsonTableEnvBenefits.envBenefits.lightBulbs or "0") 
end


function QuickApp:valuesOverview(table) -- Get the values from json file Overview
  self:logging(3,"QuickApp:valuesOverview()")
  local jsonTable = table
  data.currentPower = string.format("%.0f", jsonTable.overview.currentPower.power or "0")
  data.solarPower = string.format("%.1f",self:solarPower(tonumber(data.currentPower), tonumber(solarM2)))
  data.lastDayData = string.format("%.1f",jsonTable.overview.lastDayData.energy/1000 or "0")
  data.lastMonthData = string.format("%.1f",jsonTable.overview.lastMonthData.energy/1000 or "0")
  data.lastYearData = jsonTable.overview.lastYearData.energy or "0"
  data.lastYearData, data.lastYearUnit = self:unitCheckWh(tonumber(data.lastYearData)) -- Set measurement and unit to kWh, MWh or GWh
  data.lifeTimeData = jsonTable.overview.lifeTimeData.energy or "0"
  data.lifeTimeData, data.lifeTimeUnit = self:unitCheckWh(tonumber(data.lifeTimeData)) -- Set measurement and unit to kWh, MWh or GWh
  data.lifeTimeData_revenue = string.format("%.2f", jsonTable.overview.lifeTimeData.revenue or "0.00") .." " ..data.currency -- lifeTimeData_revenue is not mandatory
  data.lastUpdateTime = jsonTable.overview.lastUpdateTime or os.date("%d-%m-%Y %H:%M")
  local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.lastUpdateTime:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.lastUpdateTime = os.date("%d-%m-%Y %H:%M", convertedTimestamp)
end


function QuickApp:valuesDetails(table) -- Get the values from json file Details
  self:logging(3,"QuickApp:valuesDetails()")
  local jsonTableDetails = table
  data.peakPower = string.format("%.1f", jsonTableDetails.details.peakPower or "0")
  data.currency = jsonTableDetails.details.currency or "EUR"
  data.type = jsonTableDetails.details.type or ""
  data.manufacturerName = jsonTableDetails.details.primaryModule.manufacturerName or ""
  data.modelName = jsonTableDetails.details.primaryModule.modelName or ""
  data.maximumPower = string.format("%.0f", jsonTableDetails.details.primaryModule.maximumPower or "0")
end


function QuickApp:getEnvBenefits() -- Get Environmental Benefits from the API
  self:logging(3,"QuickApp:getEnvBenefits()")
  local urlEnvBenefits = "https://monitoringapi.solaredge.com/site/"..self:getVariable('siteID').."/envBenefits?systemUnits="..string.lower(self:getVariable('systemUnits')):gsub("^%l", string.upper).."&api_key="..self:getVariable('apiKey')
  self:logging(2,"URL EnvBenefits: " ..urlEnvBenefits)

  http:request(urlEnvBenefits, {
    options={headers = {Accept = "application/json"},method = 'GET'}, success = function(response)
      self:logging(3,"response status: " ..response.status)
      self:logging(3,"headers: " ..response.headers["Content-Type"])
      self:logging(2,"Response data: " ..response.data)

      if response.data == nil or response.data == "" or response.data == "[]" or response.status > 200 then -- Check for empty result
        self:warning("Temporarily no Environmental Benefits data from SolarEdge Monitor")
        self:logging(1,"response status: " ..response.status)
        self:logging(1,"Response data: " ..response.data)
        return
      end

      local jsonTableEnvBenefits = json.decode(response.data) -- JSON decode from api to lua-table

      self:valuesEnvBenefits(jsonTableEnvBenefits) -- Get the values from EnvBenefits

    end,
    error = function(error)
      self:error("error: " ..json.encode(error))
      self:updateProperty("log", "error: " ..json.encode(error))
    end
  }) 
end


function QuickApp:getData() -- Get Production data from the API
  self:logging(3,"QuickApp:getData()")
  local urlOverview = "https://monitoringapi.solaredge.com/site/"..self:getVariable('siteID').."/overview.json?api_key="..self:getVariable('apiKey')
  self:logging(2,"URL Overview: " ..urlOverview)

  http:request(urlOverview, {
    options={headers = {Accept = "application/json"},method = 'GET'}, success = function(response)
      self:logging(3,"response status: " ..response.status)
      self:logging(3,"headers: " ..response.headers["Content-Type"])
      self:logging(2,"Response data: " ..response.data)

      if response.data == nil or response.data == "" or response.data == "[]" or response.status > 200 then -- Check for empty result
        self:warning("Temporarily no production data from SolarEdge Monitor")
        self:logging(1,"response status: " ..response.status)
        self:logging(1,"Response data: " ..response.data)
        fibaro.setTimeout(interval*1000, function() 
          return
        end)
      end

      local jsonTable = json.decode(response.data) -- JSON decode from api to lua-table

      self:valuesOverview(jsonTable) -- Get the values from Overview
      self:valuesCheck() -- Check of Cloud decreasing values lastDayData
      if pause then self:sunsetCheck() end -- Check for Sunset to set higher interval or return to origional setting
      self:updateLabels() -- Update the labels
      self:updateProperties() -- Update the properties
      self:updateChildDevices() -- Update the Child Devices

    end,
    error = function(error)
      self:error("error: " ..json.encode(error))
      self:updateProperty("log", "error: " ..json.encode(error))
    end
  }) 
  self:logging(3,"Timeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function()
    self:logging(3,"EnvBenefits countdown: " ..tonumber(os.date("%H%M"))-1200 .." < " ..interval/60 .." and >= 0")
    if tonumber(os.date("%H%M"))-1200 >= 0 and tonumber(os.date("%H%M"))-1200 < (interval/60) then -- Get Environmental Benefits data once every day after 12:00 hour
      self:logging(2,"Get EnvBenefits at " ..os.date("%d-%m-%Y %H:%M"))
      self:getEnvBenefits() -- Get Environmental Benefits data from SolarEdge Cloud
    end
    self:getData() -- Loop
  end)
end


function QuickApp:getDetails() -- Get the settings from the API
  self:logging(3,"QuickApp:getDetails()")
  local urlDetails = "https://monitoringapi.solaredge.com/site/"..self:getVariable('siteID').."/details?api_key="..self:getVariable('apiKey')
  self:logging(2,"URL Details: " ..urlDetails)
  http:request(urlDetails, {
    options={headers = {Accept = "application/json"},method = 'GET'}, success = function(response)
      self:logging(3,"response status: " ..response.status)
      self:logging(3,"headers: " ..response.headers["Content-Type"])
      self:logging(2,"Response data: " ..response.data)

      if response.data == nil or response.data == "" or response.data == "[]" or response.status > 200 then -- Check for empty result
        self:warning("Temporarily no details data from SolarEdge Monitor")
        self:logging(1,"response status: " ..response.status)
        self:logging(1,"Response data: " ..response.data)
        return
      end

      local jsonTableDetails = json.decode(response.data) -- JSON decode from api to lua-table

      self:valuesDetails(jsonTableDetails) -- Get the values from Details

    end,
    error = function(error)
      self:error("error: " ..json.encode(error))
      self:updateProperty("log", "error: " ..json.encode(error))
    end
  }) 
end


function QuickApp:createVariables() -- Create all Variables 
  data = {}

  data.peakPower = "0"
  data.currency = "EUR"
  data.type = ""
  data.manufacturerName = ""
  data.modelName = ""
  data.maximumPower = ""

  data.units = ""
  data.co2 = "0"
  data.so2 = "0"
  data.nox = "0"
  data.treesPlanted = "0"
  data.lightBulbs = "0"

  data.currentPower = "0"
  data.solarPower = "0" 
  data.lastDayData = "0"
  --data.prevlastDayData = "0" -- Is set in Child device class
  data.lastMonthData = "0"
  data.lastYearData= "0"
  data.lastYearUnit= "Wh"
  data.lifeTimeData= "0"
  data.lifeTimeUnit= "Wh"
  data.lifeTimeData_revenue = "0"
  data.lastUpdateTime = ""
  translation = i18n:translation(string.lower(self:getVariable("language"))) -- Initialise the translation
end


function QuickApp:getQuickAppVariables() -- Get all Quickapp Variables or create them
  local siteID = self:getVariable("siteID")
  local apiKey = self:getVariable("apiKey")
  local systemUnits = string.lower(self:getVariable("systemUnits")):gsub("^%l", string.upper)
  solarM2 = tonumber(self:getVariable("solarM2"))
  local language = string.lower(self:getVariable("language"))
  interval = tonumber(self:getVariable("interval")) 
  httpTimeout = tonumber(self:getVariable("httpTimeout")) 
  pause = string.lower(self:getVariable("pause"))
  debugLevel = tonumber(self:getVariable("debugLevel"))

  -- Check existence of the mandatory variables, if not, create them with default values
  if siteID == "" or siteID == nil then
    siteID = "0" -- This siteID is just an example, it is not working 
    self:setVariable("siteID",siteID)
    self:trace("Added QuickApp variable siteID")
  end
 if apiKey == "" or apiKey == nil then
    apiKey = "0" -- This API key is just an example, it is not working
    self:setVariable("apiKey",apiKey)
    self:trace("Added QuickApp variable apiKey")
  end 
 if systemUnits ~= "Metrics" and systemUnits ~= "Imperial" then
    systemUnits = "Metrics" -- Default systemUnits is Metrics (kg)
    self:setVariable("systemUnits",systemUnits)
    self:trace("Added QuickApp variable systemUnits")
  end 
  if solarM2 == "" or solarM2 == nil then 
    solarM2 = "0" 
    self:setVariable("solarM2",solarM2)
    self:trace("Added QuickApp variable solarM2")
  end 
  if language == "" or language == nil or type(i18n:translation(string.lower(self:getVariable("language")))) ~= "table" then
    language = "en" 
    self:setVariable("language",language)
    self:trace("Added QuickApp variable language")
    translation = i18n:translation(string.lower(self:getVariable("language"))) -- (Extra) Initialise the translation because of early createVariables()
  end
  if interval == "" or interval == nil then
    interval = "360" -- The default interval is 6 minutes (360 seconds) 
    self:setVariable("interval",interval)
    self:trace("Added QuickApp variable interval")
    interval = tonumber(interval)
  end
  if httpTimeout == "" or httpTimeout == nil then
    httpTimeout = "5" -- Default http timeout 
    self:setVariable("httpTimeout",httpTimeout)
    self:trace("Added QuickApp variable httpTimeout")
    httpTimeout = tonumber(httpTimeout)
  end 
  if pause == "" or pause == nil then 
    pause = "true" 
    self:setVariable("pause",pause)
    self:trace("Added QuickApp variable pause")
  end  
  if debugLevel == "" or debugLevel == nil then
    debugLevel = "1" -- Default debug level
    self:setVariable("debugLevel",debugLevel)
    self:trace("Added QuickApp variable debugLevel")
    debugLevel = tonumber(debugLevel)
  end
  if apiKey == nil or apiKey == ""  or apiKey == "0" then -- Check mandatory apiKey 
    self:error("API key is empty! Get your API key from your installer and copy the apiKey to the quickapp variable")
    self:warning("No API Key: Switched to Simulation Mode")
    debugLevel = 4 -- Simulation mode due to empty apiKey
  end
  if siteID == nil or siteID == ""  or siteID == "0" then -- Check mandatory siteID   
    self:error("Site ID is empty! Get your siteID key from your inverter and copy the siteID to the quickapp variable")
    self:warning("No siteID: Switched to Simulation Mode")
    debugLevel = 4 -- Simulation mode due to empty siteID 
  end
  if pause == "true" then 
    pause = true 
  else
    pause = false
  end
end


function QuickApp:setupChildDevices()
  local cdevs = api.get("/devices?parentId="..self.id) or {} -- Pick up all Child Devices
  function self:initChildDevices() end -- Null function, else Fibaro calls it after onInit()...

  if #cdevs == 0 then -- If no Child Devices, create them
    local initChildData = { 
      {className="solarPower", name="Solar Power", type="com.fibaro.powerMeter", value=0},
      {className="lastDayData", name="Today", type="com.fibaro.energyMeter", value=0},
      {className="lastMonthData", name="This month", type="com.fibaro.energyMeter", value=0},
      {className="lastYearData", name="This year", type="com.fibaro.energyMeter", value=0},
      {className="lifeTimeData", name="Lifetime", type="com.fibaro.energyMeter", value=0},
    }
    for _,c in ipairs(initChildData) do
      local child = self:createChildDevice(
        {name = c.name, type=c.type, value=c.value, initialInterfaces = {}, }, 
        _G[c.className] -- Fetch class constructor from class name
      )
      child:setVariable("className",c.className)  -- Save class name so we know when we load it next time
    end   
  else 
    for _,child in ipairs(cdevs) do
      local className = getChildVariable(child,"className") -- Fetch child class name
      local childObject = _G[className](child) -- Create child object from the constructor name
      self.childDevices[child.id]=childObject
      childObject.parent = self -- Setup parent link to device controller 
    end
  end
end


function QuickApp:onInit()
  __TAG = fibaro.getName(plugin.mainDeviceId) .." ID:" ..plugin.mainDeviceId
  self:debug("QuickApp:onInit()") 
  
  self:createVariables() -- Early because of initialise the value for prevlastDayData
  self:setupChildDevices() -- Setup all child devices

  if not api.get("/devices/"..self.id).enabled then
    self:warning("Device", fibaro.getName(plugin.mainDeviceId), "is disabled")
    return
  end

  self:getQuickAppVariables() 

  http = net.HTTPClient({timeout=httpTimeout*1000})

  if tonumber(debugLevel) >= 4 then 
    self:simData() -- Go in simulation
  else
    self:getDetails() -- Get settings from SolarEdge Monitor from SolarEdge Cloud only at startup
    self:getEnvBenefits() -- Get Environmental Benefits initial data from SolarEdge Cloud
    self:getData() -- Go to loop getData()
  end
end

-- EOF  