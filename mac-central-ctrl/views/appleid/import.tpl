<!DOCTYPE html>
<html>
<head>
  <title>shooter</title>
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    body{padding: 50px 100px;}
    hr{margin: 30px 0;}
    a{color:blue;display: block; width: 60px; height: 40px; line-height: 40px; text-align: center;}
    select{width: 200px;}
  </style>
</head>
<body>
  <div> 
      <form class="layui-form layuimini-form layer-form">
        <div class="layui-form-item">
          <label class="layui-form-label">标签</label>
          <div class="layui-input-block">
            <input type="text" id="appleid_tag" name="appleid_tag" lay-verify="required"  placeholder="标签" autocomplete="off" class="layui-input" style="width: 160px;">
          </div>
        </div>
        <div class="layui-form-item">
          <label class="layui-form-label">静置时间(H)</label>
          <div class="layui-input-block">
            <input type="text" id="ctrl_time" name="ctrl_time" lay-verify="required"  placeholder="静置时间" autocomplete="off" class="layui-input" style="width: 160px;">
          </div>
        </div>
        <div class="layui-form-item" style="margin-bottom: 0px;">
          <label class="layui-form-label required">ID格式:</label>
          <div class="layui-input-block" style="line-height: 36px;">
               abc@icloud.com,Ab334433(选填:,apiurl)
          </div>
        </div>
        <div class="layui-form-item" style="margin-bottom: 0px;">
          <label class="layui-form-label required"></label>
          <div class="layui-input-block" style="line-height: 36px;">
               def@icloud.com,De334433(选填:,apiurl)
          </div>
        </div>
        <div class="layui-form-item">
          <label class="layui-form-label required"></label>
          <div class="layui-input-block" style="line-height: 36px;">
               ghi@icloud.com,Gh334433(选填:,apiurl)
          </div>
        </div>
        <div class="layui-form-item">
          <label class="layui-form-label required">上传ID:</label>
          <div class="layui-input-block">
            <button type="button" class="layui-btn" id="btnChoose">选择文件</button>
          </div>
        </div>
        <div class="layui-form-item">
          <label class="layui-form-label"></label>
          <div class="layui-input-block">
             <button type="button" class="layui-btn" id="btnUpl">确定上传</button>
          </div>
        </div>
      </form>

  </div> 
</body>
<script type="text/javascript">

layui.use(['form', 'table','upload','util'], function () {
      var $ = layui.$;
      var form = layui.form;
      var upload = layui.upload;
      var util = layui.util;
      
      let txtFile = null; // loading遮罩
      upload.render({
        elem: '#btnChoose',
        url: '/id/doImport?',
        accept: 'file',
        exts: 'txt|csv',
        auto: false, // 是否选完文件后自动上传。如果设定 false，那么需要设置 bindAction 参数来指向一个其它按钮提交上传
        bindAction: '#btnUpl', // 确定上传按钮id 指定一个其它按钮提交上传
        data:{"ctrl_time":0,"appleid_tag":""}, // 请求上传接口的额外参数
        before: function (obj) {
          this.data.ctrl_time = $("#ctrl_time").val();
          this.data.appleid_tag = $("#appleid_tag").val();
          txtFile = layer.load(1, {shade: [0.5, '#000']}); // 上传loading、遮罩
        },
        done: function (res) {
            if (res.RetCode == 0) {
              layer.closeAll('loading');
              return layer.msg(res.RetMsg);
            }
            //上传完毕
            layer.close(txtFile);//关闭遮罩 关闭loading
            layer.msg(res.RetMsg);
            var endTime = (new Date()).getTime() + 2*1000;
            var serverTime = (new Date()).getTime();
            util.countdown(endTime, serverTime, function(date,serverTime,timer){
                var min = date[2];
                var sec = date[3];
                if(min == 0 && sec == 0){
                   window.location.href = "/macCode/cert?"
                }
            });
        },
        error: function(index, upload){
          layer.closeAll('loading');
        }
      });

      $("#btnUpl").on('click', function () {
          if (!txtFile){
              layer.msg('请上传文件');// 如果为空就提示
          }
      })

      function renderData(){
          $("#ctrl_time").val("{{.ctrl_time}}");
          $("#appleid_tag").val("{{.appleid_tag}}");   
          form.render();
      }

      renderData();
    });
</script>
</html>
