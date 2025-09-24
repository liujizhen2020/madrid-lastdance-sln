<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head> 
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    body{padding: 50px 100px;}
  </style>
  <title>指定接收</title>
 </head> 
 <body> 
 <div> 
     <form class="layui-form" lay-filter="ssf" id="AAA">
       <div class="layui-form-item">
          <label class="layui-form-label">下发次数</label>
          <div class="layui-input-block">
            <input type="text" id="dispatch_num" name="dispatch_num" lay-verify="required"  placeholder="输入下发次数" autocomplete="off" class="layui-input" style="width: 160px;">
          </div>
       </div>
       <div class="layui-form-item layui-form-text">
          <label class="layui-form-label">手机号列表</label>
          <div class="layui-input-block">
            <textarea id="special_phone" placeholder="请输入手机号列表,一行一个" class="layui-textarea" name="special_phone"></textarea>
          </div>
        </div>
        <div class="layui-form-item">
          <label></label>
          <div class="layui-input-block">
            <button class="layui-btn" lay-submit  id="ssSubmit">立即提交</button>
            <button type="reset" id="ssReset" class="layui-btn layui-btn-primary">重置</button>
          </div>
        </div>
    </form>
  </div> 
  <script type="text/javascript">
      //方法提交
    
  layui.use(['form', 'util', 'laydate','layer'], function(){
    var $ = layui.$;
    var form = layui.form;
    var layer = layui.layer;
    // 提交事件

    form.val('ssf',{
      'dispatch_num':'{{.dispatch_num}}',
      'special_phone':'{{.special_phone}}'
    });

    form.on('submit(ssf)', function(data){ 
      var postData = {'dispatch_num':$('#dispatch_num').val(),'special_phone':$('#special_phone').val()};  
      $.ajax({
          url:"/specialSend/apply?",
          async: false,
          type:"POST",
          data:postData,
          success: function(data){
            if(data.RetCode == 1){
              layer.msg(data.RetMsg);
            }else{
              layer.alert(data.RetMsg);
            }
          }
      })
      return false;
    });

    form.render();
    
    $('#ssReset').on('click', function(){
       form.val('ssf',{
        'dispatch_num':'0',
        'special_phone':''
       })
    });

  });
  </script>  
 </body>
</html>