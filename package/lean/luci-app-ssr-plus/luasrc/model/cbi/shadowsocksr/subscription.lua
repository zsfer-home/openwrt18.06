-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocksr = "shadowsocksr"

local uci = luci.model.uci.cursor()
local server_count = 0
uci:foreach("shadowsocksr", "servers", function(s)
  server_count = server_count + 1
end)

local fs  = require "nixio.fs"
local sys = require "luci.sys"

local ucic = luci.model.uci.cursor()

m = Map(shadowsocksr)
m:section(SimpleSection).template  = "shadowsocksr/status"
-- [[ 节点订阅 ]]--

s = m:section(TypedSection, "server_subscribe",  translate("Subscription"))
s.anonymous = true

o = s:option(Flag, "auto_update", translate("Auto Update"))
o.rmempty = false
o.description = translate("Auto Update Server subscription, GFW list and CHN route")


o = s:option(ListValue, "auto_update_time", translate("Update time (every day)"))
for t = 0,23 do
    o:value(t, t..":00")
end
o.default=2
o.rmempty = false

o = s:option(DynamicList, "subscribe_url", translate("Subscribe URL"))
o.rmempty = true

o = s:option(Value, "filter_words", translate("Subscribe Filter Words"))
o.rmempty = true
o.description = translate("Filter Words splited by /")

o = s:option(Button,"update_Sub",translate("Update Subscribe List"))
o.inputstyle = "reload"
o.description = translate("Update subscribe url list first")
o.write = function()
  luci.http.redirect(luci.dispatcher.build_url("admin", "Internet", "shadowsocksr", "servers"))
end

o = s:option(Flag, "switch", translate("Subscribe Default Auto-Switch"))
o.rmempty = false
o.description = translate("Subscribe new add server default Auto-Switch on")
o.default="1"

o = s:option(Flag, "proxy", translate("Through proxy update"))
o.rmempty = false
o.description = translate("Through proxy update list, Not Recommended ")

o = s:option(DummyValue, "", "")
o.rawhtml = true
o.template = "shadowsocksr/update_subscribe"

o = s:option(Button,"delete",translate("Delete All Subscribe Severs"))
o.inputstyle = "reset"
o.description = string.format(translate("Server Count") ..  ": %d", server_count)
o.write = function()
uci:delete_all("shadowsocksr", "servers", function(s)
  if s.hashkey or s.isSubscribe then
    return true
  else
    return false
  end
end)
uci:save("shadowsocksr") 
uci:commit("shadowsocksr")
luci.sys.exec("/etc/init.d/shadowsocksr restart")
luci.http.redirect(luci.dispatcher.build_url("admin", "Internet", "shadowsocksr", "servers"))
return
end

return m





