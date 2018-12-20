local sproto = require "sproto"
local core = require "sproto.core"
local print_r = require "print_r"

local sp = sproto.parse [[
.Person {
	name 0 : string
	id 1 : integer
	email 2 : string

	.PhoneNumber {
		number 0 : string
		type 1 : integer
	}

	phone 3 : *PhoneNumber
}

.AddressBook {
	person 0 : *Person(id)
	others 1 : *Person
}


# login is namespace
login {
	.RoleInfo {
		roleid     0 : integer
		uid        1 : integer
		nickname   2 : string
		sex        3 : integer
		headimgurl 4 : string
	}

	#rpc method
	login 101 {
		request {
			account   0 : string  #帐号
			password  1 : string  #密码
			channel   2 : string  #渠道
		}

		response {
			roleList 0 : *RoleInfo #玩家列表
		}
	}
}
]]

-- core.dumpproto only for debug use
core.dumpproto(sp.__cobj)

local def = sp:default "Person"
print("default table for Person")
print_r(def)
print("--------------")

local ab = {
	person = {
		[10000] = {
			name = "Alice",
			id = 10000,
			phone = {
				{ number = "123456789" , type = 1 },
				{ number = "87654321" , type = 2 },
			}
		},
		[20000] = {
			name = "Bob",
			id = 20000,
			phone = {
				{ number = "01234567890" , type = 3 },
			}
		}
	},
	others = {
		{
			name = "Carol",
			id = 30000,
			phone = {
				{ number = "9876543210" },
			}
		},
	}
}

collectgarbage "stop"

local code = sp:encode("AddressBook", ab)
local addr = sp:decode("AddressBook", code)
print_r(addr)


local roleInfo = {
	roleid = 1234,
	uid = 222,
	nickname = "moong",
	sex = 0,
	headimgurl = "http://www.baidu.com/1.png"
}
local stream = sp:encode("login.RoleInfo", roleInfo)
local result = sp:decode("login.RoleInfo", stream)
