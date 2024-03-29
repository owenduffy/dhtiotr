-- Remember to connect GPIO16 (D0) and RST for deep sleep function,
-- better though a SB diode anode to RST cathode to GPIO16 (D0).

--# Settings #
dofile("nodevars.lua")
--# END settings #

--url=https://emoncms.org/input/post?node=7&csv=100,200,300
--apikey=97dc1bab4b095d559f9d809863aef28e

temperature = 0
humidity = 0

-- DHT22 sensor
function get_sensor_Data()
  dht=require("dht")
  status,temp,humi,temp_decimial,humi_decimial = dht.read(dhtdata)
    if( status == dht.OK ) then
      -- Prevent "0.-2 deg C" or "-2.-6"      
      temperature = temp.."."..(math.abs(temp_decimial)/100)
      humidity = humi.."."..(math.abs(humi_decimial)/100)
      -- If temp is zero and temp_decimal is negative, then add "-" to the temperature string
      if(temp == 0 and temp_decimial<0) then
        temperature = "-"..temperature
      end
      print("Temperature: "..temperature.." deg C")
      print("Humidity: "..humidity.."%")
    elseif( status == dht.ERROR_CHECKSUM ) then      
      print( "DHT Checksum error" )
      temperature=-1 --TEST
    elseif( status == dht.ERROR_TIMEOUT ) then
      print( "DHT Time out" )
      temperature=-2 --TEST
    end
  dht=nil
  package.loaded["dht"]=nil
end

function swf()
--  print("wifi_SSID: "..wifi_SSID)
--  print("wifi_password: "..wifi_password)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,cbsrest)
  wifi.setmode(wifi.STATION) 
  wifi.setphymode(wifi_signal_mode)
  if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
  end
  wifi.sta.config({ssid=wifi_SSID,pwd=wifi_password})
  print("swf done...")
end

function cbsrest()
  print(tmr.now())
  print("wifi.sta.status()",wifi.sta.status())
  if wifi.sta.status() ~= 5 then
    print("No Wifi connection...")
  else
    print("WiFi connected...")
  end
  get_sensor_Data()
  req,body=httpreq()
  if(body=="") then
    http.get(req,nil,cbhttpdone)
  else
    http.post(req,nil,body,cbhttpdone)
  end
  print("cbsrest done...")
end

function cbhttpdone(code,data)
  if (code<0) then
    print("HTTP request failed")
  else
    print(code,data)
  end
  tmr.alarm(0,500,tmr.ALARM_SINGLE,cbslp)
end

function cbslp()
  print(tmr.now())
  node.dsleep(meas_period*1000000-tmr.now()+8100,2)             
end

print("app starting...")
--watchdog will force deep sleep loop if the operation somehow takes to long
tmr.alarm(1,30000,1,cbslp)
meas_period=tonumber(meas_period)
if(meas_period>60) then
  get_sensor_Data()
end
--setup wifi
swf()
