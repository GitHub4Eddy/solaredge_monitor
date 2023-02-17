-- Quickapp SolarEdge Monitor i18n translation


class "i18n"
function i18n:translation(language)
  translation = {
    en = {
      ["SIMULATION MODE"] = "SIMULATION MODE", 
      ["Current power"] = "Current power", 
      ["Peakpower"] = "Peakpower", 
      ["Solar power"] = "Solar power", 
      ["Lastday"] = "Lastday", 
      ["Lastmonth"] = "Lastmonth", 
      ["Lastyear"] = "Lastyear", 
      ["Lifetime"] = "Lifetime", 
      ["Environmental Benefits"] = "Environmental Benefits", 
      ["CO2"] = "CO2", 
      ["SO2"] = "SO2", 
      ["NOX"] = "NOX", 
      ["Trees planted"] = "Trees planted", 
      ["Lightbulbs"] = "Lightbulbs", 
      ["SolarEdge installation"] = "SolarEdge installation", 
      ["Type"] = "Type", 
      ["Module"] = "Module", 
      ["Model"] = "Model", 
      ["Maximum Power"] = "Maximum Power", 
      ["Last update"] = "Last update"}, 
    nl = {
      ["SIMULATION MODE"] = "SIMULATIE MODE", 
      ["Current power"] = "Huidig vermogen", 
      ["Peakpower"] = "Piekvermogen", 
      ["Solar power"] = "Zonne-energie", 
      ["Lastday"] = "Vandaag", 
      ["Lastmonth"] = "Maand", 
      ["Lastyear"] = "Jaar", 
      ["Lifetime"] = "Levenslang", 
      ["Environmental Benefits"] = "Milieu voordelen", 
      ["CO2"] = "CO2", 
      ["SO2"] = "SO2", 
      ["NOX"] = "NOX", 
      ["Trees planted"] = "Bomen geplant", 
      ["Lightbulbs"] = "Lampen", 
      ["SolarEdge installation"] = "SolarEdge installatie", 
      ["Type"] = "Type", 
      ["Module"] = "Module", 
      ["Model"] = "Model", 
      ["Maximum Power"] = "Maximum vermogen", 
      ["Last update"] = "Laatst bijgewerkt"},
    fr = {
      ["SIMULATION MODE"] = "MODE SIMULATION", 
      ["Current power"] = "Puissance actuelle", 
      ["Peakpower"] = "Puissance de crête", 
      ["Solar power"] = "Énergie solaire", 
      ["Lastday"] = "aujourd'hui", 
      ["Lastmonth"] = "Ce mois-ci", 
      ["Lastyear"] = "L'année dernière", 
      ["Lifetime"] = "Durée de vie", 
      ["Environmental Benefits"] = "Avantages environnementaux", 
      ["CO2"] = "CO2", 
      ["SO2"] = "SO2", 
      ["NOX"] = "NOX", 
      ["Trees planted"] = "Arbres plantés", 
      ["Lightbulbs"] = "Ampoules", 
      ["SolarEdge installation"] = "Installation de SolarEdge", 
      ["Type"] = "Type", 
      ["Module"] = "Module", 
      ["Model"] = "Modèle", 
      ["Maximum Power"] = "Puissance maximum", 
      ["Last update"] = "Dernière mise à jour"},} 
    translation = translation[language] -- Shorten the table to only the current translation
  return translation
end

-- EOF