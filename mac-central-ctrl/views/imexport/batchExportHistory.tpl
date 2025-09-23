<!DOCTYPE html>

<html>
<head>
  <title>批量导出历史</title>
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
     <table id="exportHistoryTB"></table>
  </div>
  <script type="text/javascript">
    layui.use('table', function(){
      var historyRecords = "{{.history}}";
      var $ = layui.$;
      var table = layui.table;
      var tbData = JSON.parse(historyRecords);
      if (tbData == null){
        tbData = [];
      }
      // 直接赋值数据
      table.render({
        elem: '#exportHistoryTB',
        cols: [[ //标题栏
          {field: 'Id', title: '导出序号', width: '20%'},
          {field: 'N', title: '导出个数', width: '20%'},
          {field: 'T', title: '导出时间', width: '20%'},
          {field: 'O', title: '操作',templet: function (d) {
              return "<a style='cursor:pointer;color:blue;' href='/imexport/reBatchExport?id="+d.Id+"'>下载</a>"
            }
          },
        ]]
        ,data:tbData,
        skin: 'row',
        even: true,
        page: false, 
        limit:500,
      });
});
  </script>
</body>
</html>