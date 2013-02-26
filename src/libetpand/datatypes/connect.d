module libetpand.datatypes.connect;

import core.stdc.time;
import std.string;

//alias long time_t;

extern(C) short mail_get_service_port(const char * name, char * protocol);
extern(C) int mail_tcp_connect(const char * server, short port);
//extern(C) int mail_tcp_connect_timeout(const char * server, short port, time_t timeout);
extern(C) int mail_tcp_connect_with_local_address(const char * server, short port,
    const char * local_address, short local_port);
/*extern(C) int mail_tcp_connect_with_local_address_timeout(const char * server, short port,
    const char * local_address, short local_port, time_t timeout);*/

short mailGetServicePort(string name, string protocol) {
	char* cname = cast(char*)toStringz(name);
	char* cprot = cast(char*)toStringz(protocol);
	short ret = mail_get_service_port(cname, cprot);

	return ret;
}

int mailTcpConnect(string server, short port) {
	char* cname = cast(char*)toStringz(server);
	int ret = mail_tcp_connect(cname, port);
	return ret;
}

/*int mailTcpConnectTimeout(string server, short port, long timeout) {
	char* cname = cast(char*)toStringz(server);
	int ret = mail_tcp_connect_timeout(cname, port, timeout);
	return ret;
}*/

int mailTcpConnectWithLocalAddress(string server, short port,
    	string local_address, short local_port) {
	char* cname = cast(char*)toStringz(server);
	char* cadr = cast(char*)toStringz(local_address);
	int ret = mail_tcp_connect_with_local_address(cname, port, cadr,
			local_port);
	return ret;
}

/*int mailTcpConnectWithLocalAddressTimeout(string server, short port,
		string local_address, short local_port, long timeout) {
	char* cname = cast(char*)toStringz(server);
	char* cadr = cast(char*)toStringz(local_address);
	int ret = mail_tcp_connect_with_local_address_timeout(cname, port, cadr,
			local_port, timeout);
	return ret;
}*/
