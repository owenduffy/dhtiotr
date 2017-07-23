--copy to init.lua and edit cfgdefs below
--the values correspond to cfgvars
cfgdefs={
"",
"",
"",
4,
"",
"",
}
--no need for changes below here
cfgvars={
"wifi_SSID",
"wifi_password",
"nodeid",
"dhtdata",
"rest_url",
"apikey",
}

function httpgetreq() 
  req=rest_url.."?field1="..temperature.."&field2="..humidity.."&api_key="..apikey
  --  req="?node="..nodeid.."&csv="..temperature..","..humidity.."&apikey="..apikey
  print("req:"..req)
  return req
end

print("\n\nHold Pin00 low for 1s to stop boot.")
print("\n\nHold Pin00 low for 5s for config mode.")
tmr.delay(1000000)
if gpio.read(3) == 0 then
  print("Release to stop boot...")
  tmr.delay(4000000)
  if gpio.read(3) == 0 then
    print("Release now (wifit cfg)...")
    print("Starting wifi config mode...")
    dofile("wifi_setup.lua")
    return
  else
    print("...boot stopped")
    return
    end
  end

print("Starting...")
if pcall(function ()
    print("Open config")
--    dofile("config.lc")
    dofile("config.lua")
    end) then
  dofile("dhtiot.lua")
else
  print("Starting wifi config mode...")
  dofile("wifi_setup.lua")
end
