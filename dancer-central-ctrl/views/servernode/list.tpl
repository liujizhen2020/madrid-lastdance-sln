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
     <table id="serverNodeTB"></table>
  </div>
  <script type="text/javascript">
    layui.use('table', function(){

      var table = layui.table;
      var util = layui.util;
      var $ = layui.$;

      function tableData(){
        $.ajax({
          url:"/serverNode/listData?",
          async: false,
          type:"GET",
          data:{},
          success: function(data){
            if(data.RetCode == 1){
               if (data.Data == null) {
                 data.Data = [];
               }
               renderTable(data.Data);
            }else{
              layer.alert(data.RetMsg);
            }
          }
        })
      };

      function nodeOp(url,data,msg,optip){
          layer.alert(msg, {
              skin: 'layui-layer-molv'
              ,closeBtn: 1 
              ,anim: 1 
              ,btn: ['确定','取消'] //按钮
              ,icon: 6    // icon
              ,yes:function(){
                layer.msg(optip);
                $.ajax({
                  url:url,
                  async: false,
                  type:"POST",
                  data:data,
                  success: function(data){
                    if(data.RetCode == 1){
                      tableData();
                    }else{
                      layer.alert(data.RetMsg);
                    }
                  }
                })
              }
             ,btn2:function(){
             }
          });
      }

      function renderTable(d){
        table.render({
          elem: '#serverNodeTB',
          cols: [[ //标题栏
            {field: 'Index', title: '序号', width: '8%'},
            {field: 'UniqueID', title: '标识符', width: '18%'},
            {field: 'IpAddr', title: 'IP', width: '10%'},
            {field: 'VmCount', title: '虚拟机个数', width: '8%'},
            {field: 'LastSeen', title: '最后上线时间', width: '15%'},
            {field: 'IsActive', title: '是否在线',width:'10%', templet: function(d){
                  if (d.Active == 1) {
                    return "<dd><a style='color:green;'>在线</a></dd>";
                  }else{
                    return "<dd><a style='color:red;'>离线</a></dd>";
                  }
            }},
            {field: 'Operation', title: '操作', templet: function(d){
              return "<dd><a class='op-itemdel' id-ref='"+d.UniqueID+"' style='color:red;cursor:pointer;'>丢弃</a></dd>";
            }},
          ]]
          ,data:d,
          skin: 'row',
          even: true,
          page: false, 
          limit:500,
        });

        $(".op-itemdel").on('click',function(){
            var identifier = $(this).attr("id-ref");
            nodeOp("/serverNode/discard?",{"UniqueID":identifier},"确定要删除项目["+identifier+"]吗?","正在删除项目["+identifier+"]...");
        })
      }

      tableData();
    });
  </script>
</body>
</html>
