
local ffi = require "ffi"
local bit = require "bit"
local band = bit.band

local ws2_32 = require("ws2_32");

-- pass in a sockaddr
-- get out a more specific sockaddr_in or sockaddr_in6
local newSocketAddress = function(name, namelen)
	local sockaddrptr = ffi.cast("struct sockaddr *", name)
	local newone

	if sockaddrptr.sa_family == AF_INET then
		newone = sockaddr_in()
	elseif sockaddrptr.sa_family == AF_INET6 then
		newone = sockaddr_in6()
	end
	ffi.copy(newone, sockaddrptr, namelen)

	return newone
end


local host_serv = function(hostname, servicename, family, socktype, isnumericstring)
	hostname = hostname or "localhost"
	family = family or AF_UNSPEC;
	socktype = socktype or SOCK_STREAM;

	local err;
	local hints = addrinfo();
	local res = ffi.new("PADDRINFOA[1]")

	--hints.ai_flags = AI_CANONNAME;	-- return canonical name
	hints.ai_family = family;
	hints.ai_socktype = socktype;
	if isnumericstring then
		hints.ai_flags = AI_NUMERICHOST
	end

	err = ws2_32.getaddrinfo(hostname, servicename, hints, res)
--print("host_serv, err: ", err);
	if err ~= 0 then
		-- error condition
		return nil, err
	end

	return res[0]
end


local CreateIPV4WildcardAddress= function(family, port)
	local inetaddr = sockaddr_in()
	inetaddr.sin_family = family;
	inetaddr.sin_addr.S_addr = ws2_32.htonl(INADDR_ANY);
	inetaddr.sin_port = ws2_32.htons(port);

	return inetaddr
end

local CreateSocketAddress = function(hostname, port, family, socktype)
	family = family or AF_INET
	socktype = socktype or SOCK_STREAM

--print("CreateSocketAddress(): ", hostname, port);

	local hostportoffset = hostname:find(':')
	if hostportoffset then
		port = tonumber(hostname:sub(hostportoffset+1))
		hostname = hostname:sub(1,hostportoffset-1)
		print("CreateSocketAddress() - Modified: ", hostname, port)
	end

	local addressinfo, err = host_serv(hostname, nil, family, socktype)

	if not addressinfo then
		return nil, err
	end

	-- clone one of the addresses
	local oneaddress = newSocketAddress(addressinfo.ai_addr, addressinfo.ai_addrlen)
	oneaddress:SetPort(port)

	-- free the addrinfos structure
	err = ws2_32.freeaddrinfo(addressinfo)

	return oneaddress;
end



return {
	host_serv = host_serv,
	
	CreateIPV4WildcardAddress = CreateIPV4WildcardAddress,
	CreateSocketAddress = CreateSocketAddress,

	--CreateTcpServerSocket = CreateTcpServerSocket,
	--CreateTcpClientSocket = CreateTcpClientSocket,
}
