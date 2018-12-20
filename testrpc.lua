--[[

local sproto = require "sproto"
local print_r = require "print_r"

local server_proto = sproto.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

foobar 1 {
	request {
		what 0 : string
	}
	response {
		ok 0 : boolean
	}
}

foo 2 {
	response {
		ok 0 : boolean
	}
}

bar 3 {
	response nil
}

blackhole 4 {
}

#test namespace rpc
test {
	foobar 11 {
		request {
			what 0 : string
		}
		response {
			ok 0 : boolean
		}
	}

	foo 12 {
		response {
			ok 0 : boolean
		}
	}

	bar 13 {
		response nil
	}

	blackhole 14 {
	}
}


]]

--[[
local client_proto = sproto.parse [[
.package {
	type 0 : integer
	session 1 : integer
}
]]

--[[
assert(server_proto:exist_type "package")
assert(server_proto:exist_proto "foobar")

print("=== default table")

print_r(server_proto:default("package"))
print_r(server_proto:default("foobar", "REQUEST"))
assert(server_proto:default("foo", "REQUEST")==nil)
assert(server_proto:request_encode("foo")=="")
server_proto:response_encode("foo", { ok = true })
assert(server_proto:request_decode("blackhole")==nil)
assert(server_proto:response_decode("blackhole")==nil)

print("=== test 1")

-- The type package must has two field : type and session
local server = server_proto:host "package"
local client = client_proto:host "package"
local client_request = client:attach(server_proto)

print("client request foobar")
local req = client_request("foobar", { what = "foo" }, 1)
print("request foobar size =", #req)
local type, name, request, response = server:dispatch(req)
assert(type == "REQUEST" and name == "foobar")
print_r(request)
print("server response")
local resp = response { ok = true }
print("response package size =", #resp)
print("client dispatch")
local type, session, response = client:dispatch(resp)
assert(type == "RESPONSE" and session == 1)
print_r(response)

local req = client_request("foo", nil, 2)
print("request foo size =", #req)
local type, name, request, response = server:dispatch(req)
assert(type == "REQUEST" and name == "foo" and request == nil)
local resp = response { ok = false }
print("response package size =", #resp)
print("client dispatch")
local type, session, response = client:dispatch(resp)
assert(type == "RESPONSE" and session == 2)
print_r(response)

local req = client_request("bar", nil, 3)
print("request bar size =", #req)
local type, name, request, response = server:dispatch(req)
assert(type == "REQUEST" and name == "bar" and request == nil)
assert(select(2,client:dispatch(response())) == 3)

local req = client_request "blackhole"	-- no response
print("request blackhole size = ", #req)

print("=== test 2")
local v, tag = server_proto:request_encode("foobar", { what = "hello"})
assert(tag == 1)	-- foobar : 1
print("tag =", tag)
print_r(server_proto:request_decode("foobar", v))
local v = server_proto:response_encode("foobar", { ok = true })
print_r(server_proto:response_decode("foobar", v))



------------------------------namespace------------------------------

print("=== default table")

print_r(server_proto:default("package"))
print_r(server_proto:default("test.foobar", "REQUEST"))
assert(server_proto:default("test.foo", "REQUEST")==nil)
assert(server_proto:request_encode("test.foo")=="")
server_proto:response_encode("test.foo", { ok = true })
assert(server_proto:request_decode("test.blackhole")==nil)
assert(server_proto:response_decode("test.blackhole")==nil)

print("=== test 1")

-- The type package must has two field : type and session
local server = server_proto:host "package"
local client = client_proto:host "package"
local client_request = client:attach(server_proto)

print("client request foobar")
local req = client_request("test.foobar", { what = "foo" }, 1)
print("request foobar size =", #req)
local type, name, request, response = server:dispatch(req)
assert(type == "REQUEST" and name == "test.foobar")
print_r(request)
print("server response")
local resp = response { ok = true }
print("response package size =", #resp)
print("client dispatch")
local type, session, response = client:dispatch(resp)
assert(type == "RESPONSE" and session == 1)
print_r(response)

local req = client_request("test.foo", nil, 2)
print("request foo size =", #req)
local type, name, request, response = server:dispatch(req)
assert(type == "REQUEST" and name == "test.foo" and request == nil)
local resp = response { ok = false }
print("response package size =", #resp)
print("client dispatch")
local type, session, response = client:dispatch(resp)
assert(type == "RESPONSE" and session == 2)
print_r(response)

local req = client_request("test.bar", nil, 3)
print("request bar size =", #req)
local type, name, request, response = server:dispatch(req)
assert(type == "REQUEST" and name == "test.bar" and request == nil)
assert(select(2,client:dispatch(response())) == 3)

local req = client_request "test.blackhole"	-- no response
print("request blackhole size = ", #req)

print("=== test 2")
local v, tag = server_proto:request_encode("test.foobar", { what = "hello"})
assert(tag == 1)	-- foobar : 1
print("tag =", tag)
print_r(server_proto:request_decode("test.foobar", v))
local v = server_proto:response_encode("test.foobar", { ok = true })
print_r(server_proto:response_decode("test.foobar", v))

]]
----------------------------test new rpc---------------------------------

--package.path = "./lualib/?.lua;"
--package.cpath = "./luaclib/?.dll;"

local sproto = require "sproto"
local core = require "sproto.core"
local print_r = require "print_r"

local server_sproto = sproto.parse [[

.UserData {
	errorcode 0 : integer
	token     1 : string
	unionid   2 : string
}

.Package {
	type    0 : integer
	session 1 : integer
	ud      2 : UserData 
}

login {
	.Player {
		playerid 0 : integer   #玩家id
		nickname 1 : string    #昵称
		headid   2 : integer   #默认头像id
		headurl  3 : string    #头像地址
		sex      4 : integer   #0-未知 1-男 2-女
		gold     5 : integer   #金币
	}

	#C2S
	account_login 100 {
		request {
			account   0 : string  #帐号
			password  1 : string  #密码
			channelid 2 : string  #渠道id
		}
		response {
			player 0 : Player
		}
	}

	#S2C
	login_event 150 {
		request {
			tips     0 : string
		}
	}
}

]]

local client_sproto = sproto.parse [[

.UserData {
	errorcode 0 : integer
	token 1 : string
	unionid 2 : string
}

.Package {
	type 0 : integer
	session 1 : integer
	ud 2 : UserData
}

]]

function print_binary(name, binary)
	local str = ""
	for i=1, #binary do
		str = str .. string.byte(string.sub(binary, i, i)) .. ", "
	end
	print("buffer=", str);
	-- print(str)
end

local server = server_sproto:host "Package"
local client = client_sproto:host "Package"

--客户端请求
local client_request = client:attach(server_sproto)
local server_request = server:attach(server_sproto)

local player = {
	playerid = 22,
	nickname = "欧383",
	headid = 100033,
	headurl = "http://www.wechat.com/images/0001",
	sex = 1,
	gold = 188888888,
}

--encode && decode
local encodedString = server_sproto:encode("login.Player", player)

print_binary("encode=", encodedString)

local decodedInfo = server_sproto:decode("login.Player", encodedString)
print_r(decodedInfo)


--rpc request
print("1.==============C2S request==================")
local req = {account="account01", password="18c08cc0af530ff3c1fd82156db181ac", channelid="huawei"}
local reqStream = server_request("login.account_login", req, 1, {token="e10adc3949ba59abbe56e057f20f883e"})
local type, name, reqInfo, response, ud = server:dispatch(reqStream)
print("type=", type)
print("name=", name)
print("reqInfo=", table.tostring(reqInfo))
print("ud=", table.tostring(ud))



print("2.==============C2S response==================")
local respStream = response { player = player }
local type, session, respInfo, ud = server:dispatch(respStream)
print("type=", type)
print("session=", session)
print("respInfo=", table.tostring(reqInfo))
print("ud=", table.tostring(ud))



print("3.================S2C response================")
local s2cStream = server:response("login.account_login", { player = player })
local type, name, respInfo, session, ud = server:dispatch(s2cStream)
print("type=", type)
print("name=", name)
print("reqInfo=", table.tostring(reqInfo))
print("session=", session)
print("ud=", table.tostring(ud))