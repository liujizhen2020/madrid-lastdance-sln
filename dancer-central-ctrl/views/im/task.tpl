<!DOCTYPE html>

<html>
<head>
  <title>任务</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    *{margin:0,padding:0;}
    body{padding: 50px 50px;}
    .switch-status{cursor:pointer;}
    .target-num{cursor:pointer;}
    .macro-num{cursor:pointer;color:orange;}
    .op-a{color:blue;cursor: pointer;}
    .op-imptarget{color:blue;cursor:pointer;}
    .op-deltarget{color:red;cursor:pointer;}
    .op-edittask{color:blue;cursor:pointer;}
    .op-deltask{color:red;cursor:pointer;}
    .input-target-num{max-width: 90px;}
    .input-macro-num{max-width: 90px;}
    .layui-table th{font-weight: bold;background-color: #b0bac4} 
  </style>
</head>
<body>
  <div>
     <dd>
        <a href="/msgedit/toAddText?" style="color: blue">添加IM任务</a>
      </dd>
     <table id="taskTB"></table>
  </div>
  <script type="text/javascript">
    layui.use(['table','jquery','util'], function(){
  
      var table = layui.table;
      var util = layui.util;
      var $ = layui.$;
      // 直接赋值数据
      
      function qRender(){
        $.ajax({
              url:"/im/taskData?",
              async: false,
              type:"GET",
              data:{},
              success: function(data){
                if(data.RetCode == 1){
                  renderData(data.Data==null?[]:data.Data);
                }else{
                  layer.msg(data.RetMsg);
                }
              }
        });
      }

      function renderData(taskData){
        table.render({
          elem: '#taskTB',
          cols: [[ //标题栏
            {field: 'Index', title: '序号', width: '6%'},
            {field: '', title: '状态', width: '6%', templet: function(d){
                if (d.Status == 1) {
                  return "<dd><a class='switch-status' style='color:green;' id-ref='"+d.Identifier+"'>已开启</a></dd>";
                }else{
                  return "<dd><a class='switch-status' style='color:red;' id-ref='"+d.Identifier+"'>已关闭</a></dd>";
                }
            }},
            {field: 'TargetNum', title: '设定目标量', width: '6%', templet:function(d){
              return "<dd class='target-num' id-ref='"+d.Identifier+"' data-ref='"+d.TargetNum+"'>"+d.TargetNum+"</dd>"
            }},
            {field: '', title: '内容', width: '30%',templet: function (d) {
                return d.Content.Text
              }
            },
            {field: 'MacroSwitch', title: '替换', width: '6%', templet:function(d){
              return "<dd class='macro-num' id-ref='"+d.Identifier+"' data-ref='"+d.MacroSwitch+"'>"+d.MacroSwitch+"</dd>"
            }},
            {field: '', title: '明细-尚未发送', width: '8%', templet:function(d){
               return "<dd><a class='op-a' style='color:red;' href='/imexport/exportTask?status=0&identifier="+d.Identifier+"'>"+d.Free+"</a></dd>";
            }},
            {field: '', title: '明细-等待返回', width: '8%', templet:function(d){
               return "<dd><a class='op-a' style='color:orange;'  href='/imexport/exportTask?status=1&identifier="+d.Identifier+"'>"+d.Working+"</a></dd>";
            }},
            {field: '', title: '明细-已送达', width: '8%', templet:function(d){
               return "<dd><a class='op-a' style='color:green;' href='/imexport/exportTask?status=100&identifier="+d.Identifier+"'>"+d.Succ+"</a></dd>";
            }},
            {field: '', title: '操作',templet:function(d){
              return "<dd><a id-ref='"+d.Identifier+"' class='op-a' href='/macro/toMain?identifier="+d.Identifier+"'>宏替换</a>&nbsp;<a id-ref='"+d.Identifier+"' class='op-imptarget'>导入号码</a>&nbsp;<a id-ref='"+d.Identifier+"' class='op-deltarget' idx-ref='"+d.Index+"'>清除号码</a> &nbsp;<a id-ref='"+d.Identifier+"' class='op-edittask'>编辑任务</a>&nbsp;<a id-ref='"+d.Identifier+"' idx-ref='"+d.Index+"' class='op-deltask'>删除任务</a></dd>"
            }},
          ]]
          ,data:taskData,
          skin: 'row',
          even: true,
          page: false, 
          limit:500,
        });

        $(".switch-status").on('click',function(){
          var idRef = $(this).attr("id-ref");
          $.ajax({
                url:"/imessage/switchStatus?",
                async: false,
                type:"POST",
                data:{"identifier":idRef},
                success: function(data){
                  if(data.RetCode == 1){
                    qRender();
                  }else{
                    layer.msg(data.RetMsg);
                  }
                }
          });
        });

        $(".target-num").dblclick(function(){
          var dataRef = $(this).attr("data-ref");
          var idRef = $(this).attr("id-ref");
          $(this).html("<input class='input-target-num' type='text' id-ref='"+idRef+"' value='"+dataRef+"'>");
          $('.input-target-num').focusout(function(){
              var inputIdRef = $(this).attr("id-ref");
              var dataVal = $(this).val();
              modTaskMeta({'identifier':inputIdRef,'field':'TargetNum','value':dataVal})
          })
        })

        $(".macro-num").dblclick(function(){
          var dataRef = $(this).attr("data-ref");
          var idRef = $(this).attr("id-ref");
          $(this).html("<input class='input-macro-num' type='text' id-ref='"+idRef+"' value='"+dataRef+"'>");
          $('.input-macro-num').focusout(function(){
              var inputIdRef = $(this).attr("id-ref");
              var dataVal = $(this).val();
              modTaskMeta({'identifier':inputIdRef,'field':'MacroSwitch','value':dataVal})
          })
        })

        $('.op-imptarget').on('click',function(){
          var idRef = $(this).attr("id-ref");
          window.location.href = "/phoneNo/toImport?identifier="+idRef;
        })

        $('.op-deltarget').on('click',function(){
          var idRef = $(this).attr("id-ref");
          var idxRef = $(this).attr("idx-ref");
          taskOp('/phoneNo/truncate?',{"identifier":idRef},"确定删除["+idxRef+"]任务号码吗?","正在删除["+idxRef+"]任务号码...");
        })

        $('.op-edittask').on('click',function(){
          var idRef = $(this).attr("id-ref");
          window.location.href = "/msgedit/toEditText?identifier="+idRef;
        })

        $('.op-deltask').on('click',function(){
          var idRef = $(this).attr("id-ref");
          var idxRef = $(this).attr("idx-ref");
          taskOp('/msgedit/doDelete?',{"identifier":idRef},"确定删除任务["+idxRef+"]吗?","正在删除任务["+idxRef+"]...");
        })
      }

      function taskOp(url,data,msg,optip){
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
                      qRender();
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

      function modTaskMeta(data){
        $.ajax({
          url:"/imessage/saveItemMeta?",
          async: false,
          type:"POST",
          data:data,
          success: function(data){
            if(data.RetCode == 1){
                layer.msg(data.RetMsg);
                qRender();
            }else{
                layer.alert(data.RetMsg);
            }
          }
        })
      }

      qRender();

  });
  </script>
</body>
</html>
