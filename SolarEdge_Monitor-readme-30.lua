--[[ Quickapp SolarEdge Monitor readme

This QuickApp monitors your SolarEdge managed Solar Panels
The QuickApp has (child) devices for Solar Power, Lastday Data, Lastmonth Data, Lastyear Data and Lifetime Data
The Solar Production values are only requested from the SolarEdge Cloud between sunrise and sunset
The QuickApp also shows the Environmental Benefits in the labels for CO2, SO2, NOX, Trees planted and Lightbulbs
The QuickApp also shows the SolarEdge Installation details in the labels
The Environmental Benefits are updated once a day after 12:00 hour
The settings for Peak Power and Currency are retrieved from the inverter 
The rateType interface of Child device Last Day is automatically set to "production" and values from this child devices can be used for the Energy Panel 
The readings for lastyear and lifetime energy are automatically set to the right Wh unit (Wh, kWh, MWh or GWh) 
See API documentation on https://www.solaredge.com/sites/default/files/se_monitoring_api.pdf 


Changes version 3.0 (17th February 2023)
- Added translation for EN, FR and NL


Changes version 2.1 (3rd April 2022)
- Solved bug with child device lastDay showing incorrect values in energy panel

Changes version 2.0 (26th Match 2022)
- All *meter device types can now be shown in the Yubii app so: 
   - Changed main device SolarEdge Monitor to device type com.fibaro.powerMeter
   - Changed child device solarPower to device type com.fibaro.powerMeter
   - Changed child devices lastDayData, lastMonthData, lastYearData and lifeTimeData to com.fibaro.energyMeter
   - Configured storeEnergyData property of lastDayData, lastMonthData, lastYearData and lifeTimeData to com.fibaro.energyMeter to false
   - Configured storeEnergyData property of main device SolarEdge Monitor to true
- Added "pause" mode during sunset and sunrise. During this time NO requests will be send to the Cloud (because there is no solar production during that time). This saves on the ratelimit of 300 requests a day. 
- Added Environmental Benefits to the labels, with an update once a day
- Added new QuickApp Variable systemUnits Metrics (kg) or Imperial (lb) for Environmental Benefits
- Added SolarEdge Installation details to the labels
- Added extra timeout and debug logging in case of a bad response 
- Optimized some code

Changes version 1.5 (5th March 2022)
- Improved the handling of decreasing values

Changes version 1.4 (22nd February 2022)
- Changed rounding of all Wh values to one number after the decimal point, to prevent issues with decreasing values from SolarEdge Cloud
- Added extra check for decreasing values from SolarEdge Cloud lastDayData
- Changed handling bad responses from SolarEdge Cloud
- Removed QuickApp variable icon, icon can be selected in the user interface with the new firmware

Changes version 1.3 (8th January 2022)
- Extra check on return value API for "Too many requests"

Changes version 1.2 (26th August 2021)
- Added values update main device to power interface to show usage in Power consumption chart
- Solved a bug in the lifeTimeData.revenue existence check

Changes version 1.1 (21th August 2021)
- Changed back currentPower measurement to Watt and lastDayData, lastMonthData to kWh (not to mess up statistics in Energy panel or InfluxDB/Grafana installations)
- Changed Child device currentPower to Main device with type com.fibaro.powerSensor (Watt). So the Main device will show the current power production, no Child device necessary. 
- Changed Child device lastDayData to type com.fibaro.energyMeter (kWh). These values will be shown in the new energy panel. 
- Added automaticaly change rateType interface of Child device lastDayData to "production"
- Added extra check on apiKey and siteID, if not OK then change to simulation mode
- SolarEdge Monitor settings currency and PiekPower also available in simulation mode
- Changed the lastUpdateTime to format dd-mm-yyyy hh:mm 

Changes version 1.0 (30th July 2021)
- Total m² solar panels added to log text and label text
- Check for API existance of lifeTimeData_revenue (not available in older firmware)
- Automatic conversion added for lastmonthData, lastYearData and lifetimeData production to Wh, kWh, MWh or GWh
- Automatic conversion added for currentPower to Watt, Kilowatt, Megawatt or Gigawatt (yes, Megawatt and Gigawatt is optimistic)
- Get the Peakpower and Currency settings from Inverter
- Peakpower added to label text and child device log text

Changes version 0.3 (12th April 2021)
- Added last update date / time
- Cleaned up the code

Changes version 0.2 (12th April 2021)
- Disabled revenue value (except for lifeTimeData)

Changes version 0.1 (11th April 2021)
- First (test) version


Variables (mandatory and created automatically): 
- siteID = Site ID of your SolarEdge Inverter (see your Inverter Site Details)
- apiKey = API key of your SolarEdge Inverter (contact your installer if you don't have one)
- systemUnits = SystemUnits is Metrics (kg) or Imperial (Lb) (default is Metrics)
- solarM2 = The amount of m2 Solar Panels (use . for decimals) for calculating Solar Power m2 (default = 0)
- language = Preferred language (default = English (en)) (supported languages is Dutch (nl) and French (fr))
- interval = The daily API limitation is 300 requests. The default request interval is 360 seconds (6 minutes)
- pause = Should the SolardEdge go in pause mode after sunset (default = true)
- debugLevel = Number (1=some, 2=few, 3=all, 4=simulation mode) (default = 1)
]]

-- EOF