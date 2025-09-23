# vmc

滚动发送，可以配置多个vm同时工作。

## how it works
1. 读取配置
1. 读取码
1. 修改vmx文件，实现vm改机
1. 启动vm
1. 获取vm的ip，`vmrun getGuestIPAddress`
1. 定时发送UDP报文，给vm指定端口
1. 监听vm的UDP报文消息，得到vm状态
1. 若vm使命完成，关闭并销毁vm



### UDP 消息反馈
* 主控定时发送ping消息给虚拟机，内容为：3个字节，状态码0x80,主控端口号0x28,0x00 (10240)
* 虚拟机内部接收到消息后，回复状态字符串，比如working，done
* 如果虚拟机回复done， 主控关闭虚拟机，克隆开启下一个。
