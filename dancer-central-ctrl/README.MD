请按顺序阅读
1. 部署配置文档DEPLOY.MD
2. go编译环境说明文档 ENV.MD
3. API对接文档API.MD

2024.3.27 升级说明
1.db.appleid_tag.createIndex({"Tag":1},{unique:true})
2.升级完成后，临时关闭提证、发送开关
3.执行url /appleId/initTag? 初始化历史数据
4.开启提证、发送开关