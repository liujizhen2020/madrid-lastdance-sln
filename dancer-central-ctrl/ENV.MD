1. 安装go编译环境
  https://www.jianshu.com/p/79bdd20c46cf

2. $GOPATH下新建目录src/,将压缩包解压到此目录下


3. cd ${GOPATH}/src/dancer-central-ctrl/

4. 下载依赖的开源代码
   go get github.com/astaxie/beego
   go get github.com/go-sql-driver/mysql
   go get github.com/go-redis/redis

5. bee run 运行项目，如果报错某个库没找到，则按报错路径执行步骤4