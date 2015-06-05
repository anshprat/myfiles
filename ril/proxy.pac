function FindProxyForURL(url, host)
{
if (isInNet(host, "10.140.0.0", "255.255.0.0")) {
return "PROXY 127.0.0.1:8081";
}
else {
return "DIRECT";
}
}

