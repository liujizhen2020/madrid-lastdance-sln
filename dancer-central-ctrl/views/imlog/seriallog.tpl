<!DOCTYPE html>

<html>
<head>
  <title>日志</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    body{padding: 50px 100px;}
    .layui-table th{font-weight: bold;background-color: #b0bac4} 
  </style>
</head>

<body>
  <div>
     <table id="serialLogTB"></table>
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
        elem: '#serialLogTB',
        cols: [[ //标题栏
          {field: 'Serial', title: '序列号', width: '9%'},
          {field: 'ProductType', title: '机型', width: '9%'},
          {field: 'BindingEmail', title: 'AppleID', width: '9%'},
          {field: 'EmailPWD', title: 'Password', width: '9%'},
          {field: 'BindingTimeStr', title: '提证时间', width: '9%'},
          {field: 'CreateAtStr', title: '发送时间', width: '9%'},
          {field: 'BindingInterval', title: '时间差', width: '9%'},
          {field: 'DispNum', title: '发送次数', width: '9%'},
          {field: 'LastSucc', title: '本次成功', width: '9%'},
          {field: 'SuccTotal', title: '总成功'}
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
