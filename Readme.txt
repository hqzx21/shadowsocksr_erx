
shadowsocksr for EdgeRouter X

ssr版本安装后会提示缺少libc.so.6
暂时没空折腾，先用ss版的吧.....

安装前提示：
ssr版不能与ss版同时运行，如果之前安装过ss版，必须先停止ss版服务，并且删除/etc/rc.local中的启动项再进行安装。

安装:
1.下载shadowsocksr_erx-master.zip并解压
2.用winscp把解压的所有文件copy到/tmp目录
3.连接路由CLI命令界面并登陆，然后执行: 
cd /tmp
sudo bash install.sh
4.根据提示输入shadowsocksr配置信息，一般只需要输入服务器地址、端口、密码，其它选项可以直接回车使用默认选项。

注意:
1.国内外流量自动分流，通过ipset对国内IP进行白名单，国内IP不会翻墙访问，只有国外流量会走shadowsocksr通道翻墙
2.只能对TCP流量翻墙
3.国外网站DNS经shadowsocksr服务器中转使用TCP访问8.8.8.8，防止污染，国内域名使用国内DNS解析，不会影响CDN访问
4.1080端口可以作为socks5翻墙代理使用
5.文件存放在/config目录是因为这个目录备份配置的时候会被一起备份，并且系统升级也不会删除
6.shadowsocksr版本:v2.5.6, chinadns版本:v1.3.2(修改版)，pdnsd版本:v1.2.9
7.EdgeRouter X EdgeOS v1.8.5,v1.9.0测试通过
8.如果想暂停shadowsocksr，运行sudo /etc/init.d/shadowsocksr stop
9.重新启动就运行sudo /etc/init.d/shadowsocksr start
10.运行sudo crontab -e，并在文件末尾添加以下内容，就可以实现每隔5分钟检测ss状态，如果不能翻墙就自动重启服务：
*/5 * * * * sh /config/shadowsocksr/bin/ss-monitor.sh

PT下载用户请注意，如果你有独立的下载机，可以设置让下载机不走SS。具体操作如下：
ss启动脚本/etc/init.d/shadowsocks里面有下面一行:
#BYPASS_RANGE=192.168.123.0/24
去掉注释(删掉#号)重启服务就可以生效，然后192.168.123.0/24这整个网段都不会走ss通道了，同时也无法翻墙了，192.168.123.0/24也可以换成单独IP或者其它网段。

DNS解析过程
chinadns    必须配置至少一个国内DNS，一个国外DNS
dnsmasq  ->    chinadns    (国外IP)->    pdnsd   -> ss-server -> dns-server:ok
			   (国内IP)->    114.114.114.114:ok

chinadns作者很久没有更新过了，但是有几个bug，会导致有些同时有国内国外CDN的域名解析出国外的IP，本方案使用的chinadns我修复了这个bug并优化了部分情况下的解析速度。
ss翻墙方案目前最容易出问题的就是DNS防污染，最近的几次更新几乎都是针对DNS，到目前版本终于让我比较满意了。
