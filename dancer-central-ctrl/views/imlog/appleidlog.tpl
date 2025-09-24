<!DOCTYPE html>

<html>
<head>
  <title>日志</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    body{padding: 50px 100px;}
  </style>
</head>

<body>
  <div>
     <table id="idLogTB"></table>
  </div>
  <script type="text/javascript">
    layui.use('table', function(){
      var logRecords = "{{.logRecord}}";
      var $ = layui.$;
      var table = layui.table;
      var logData = JSON.parse(logRecords)
      if (logData == null){
        logData = [];
      }
      // 直接赋值数据
      table.render({
        elem: '#idLogTB',
        cols: [[ //标题栏
          {field: 'Email', title: 'AppleID', width: 300},
          {field: 'Pwd', title: '密码', width: 120},
          {field: 'MDNum', title: '发送次数', width: 100},
          {field: 'Create', title: '首次发送时间', width: 200},
          {field: 'Update', title: '最后发送时间', width: 200},
          {field: 'LastSucc', title: '本次成功', width: 120},
          {field: 'SuccTotal', title: '总成功', width: 120}
        ]]
        ,data:logData,
        skin: 'row',
        even: true,
        page: false, 
        limit:500,
      });
    });
  </script>
</body>
</html>
