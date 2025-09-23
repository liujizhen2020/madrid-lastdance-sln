<!DOCTYPE html>

<html>
<head>
  <title>标签</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    *{margin:0,padding:0;}
    body{padding: 50px 50px;}
    .input-disp-interv{max-width: 90px;}
    .tag-del{color:red;cursor:pointer;}
  </style>
</head>
<body>
  <div>
    <table id="tagTB"></table>
  </div>
  <script type="text/javascript">
    layui.use(['table','jquery','util'], function(){
  
      var table = layui.table;
      var util = layui.util;
      var $ = layui.$;
      // 直接赋值数据
      
      function qRender(){
        $.ajax({
              url:"/appleId/tagData?",
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

      function renderData(tagData){
        table.render({
          elem: '#tagTB',
          cols: [[ //标题栏
            {field: 'Tag', title: '标签', width: "20%"},
            {field: 'DispatchInterval', title: '静置时间(小时)', width: "10%", templet:function(d){
                return "<dd class='disp-interv' tag-ref='"+d.Tag+"' data-ref='"+d.DispatchInterval+"'>"+d.DispatchInterval+"</dd>"
              }
            },
            {field: 'Num', title: 'ID个数', width: "12%",templet: function (d) {
                return d.Num
              }
            },
            {field: 'BindingNum', title: '激活个数', width: "12%",templet: function (d) {
                return d.BindingNum
              }
            },
            {field: 'CertNum', title: '证书个数', width: "12%",templet: function (d) {
                return d.CertNum
              }
            },
            {field: 'ReadyNum', title: '就绪个数', width: "12%",templet: function (d) {
                return d.ReadyNum
              }
            },
            {field: 'CreateAtStr', title: '导入时间', width: "12%",templet: function (d) {
                return d.CreateAtStr
              }
            },
            {field: 'CreateAtStr', title: '操作', templet: function (d) {
                 return "<dd class='tag-del' tag-ref='"+d.Tag+"'>删除</dd>"
              }
            },
          ]]
          ,data:tagData,
          skin: 'row',
          even: true,
          page: false,
          limit:500,
        });

        $(".disp-interv").dblclick(function(){
          var tagRef = $(this).attr("tag-ref");
          var dataRef = $(this).attr("data-ref");
          $(this).html("<input class='input-disp-interv' type='text' tag-ref='"+tagRef+"' value='"+dataRef+"'>");
          $('.input-disp-interv').focusout(function(){
              var tagRef = $(this).attr("tag-ref");
              var dataVal = $(this).val();
              saveTagInterval({'tag':tagRef,'interval':dataVal})
          })
        })

        $('.tag-del').on('click',function(){
          var tagRef = $(this).attr("tag-ref");
          tagDel('/appleId/tagDel?',{"tag":tagRef},"确定删除标签["+tagRef+"]吗?","正在删除标签["+tagRef+"]...");
        })
      }

      function saveTagInterval(data){
        $.ajax({
          url:"/appleId/saveTagInterval?",
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

      function tagDel(url,data,msg,optip){
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
      qRender();

  });
  </script>
</body>
</html>
