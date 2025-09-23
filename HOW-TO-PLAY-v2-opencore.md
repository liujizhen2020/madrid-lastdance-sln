# HOW TO PLAY

* 测试日期：2023-8-30
* 代码分支：play2-opencore
* 发送方式：提取证书,多线程发送 (起量了，老板)

## 参与对象：
* vmc --- vm本地控制器
* svr --- 服务器
* CoreTrojan ----- 部署到母鸡，开机自动运行，执行内部改机
* UltimatePlan --- 虚拟机内部运行, 协议登陆，提取证书
* MadridExpressVM  --- 发送端App （如果在VM运行，不需要改机）

## 登录步骤
* vmc获取码子，改uuid,指定网卡mac，
* 启动vm, trojan生成config.plist, 更新file system UUID
* 重启vm,
* app获取id，开始登录，回传登录结果
* 若登录成功，提取证书，上传服务器
* 若登录失败，vmc销毁本地vm


## 发送步骤
* 多线程批量发送！

