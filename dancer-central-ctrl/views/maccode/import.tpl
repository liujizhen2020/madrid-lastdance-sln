<!DOCTYPE html>
<html>
<head>
  <title>iphonecode</title>
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    body{padding: 50px 100px;}
    hr{margin: 30px 0;}
    a{color:blue;display: block; width: 60px; height: 40px; line-height: 40px; text-align: center;}
  </style>
</head>
<body>
  <div> 
      <form class="layui-form layuimini-form layer-form">
        <div class="layui-form-item" style="margin-bottom: 0px;">
          <label class="layui-form-label required">码格式:</label>
          <div class="layui-input-block" style="line-height: 36px;">
               (:)ROM:MLB:SN:BOARD:PT(:)括号中的可有可无
          </div>
        </div>
        <div class="layui-form-item">
          <label class="layui-form-label required">上传码:</label>
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
      var $ = layui.jquery;
      var form = layui.form;
      var upload = layui.upload;
      var util = layui.util;
      
      let txtFile = null; // loading遮罩
      upload.render({
        elem: '#btnChoose',
        url: '/macCode/doImport?',
        accept: 'file',
        exts: 'txt|csv',
        auto: false, // 是否选完文件后自动上传。如果设定 false，那么需要设置 bindAction 参数来指向一个其它按钮提交上传
        bindAction: '#btnUpl', // 确定上传按钮id 指定一个其它按钮提交上传
        data:{"pt":""}, // 请求上传接口的额外参数
        before: function (obj) {
            this.data.pt = $("#pt_select").val();
            txtFile = layer.load(1, {shade: [0.5, '#000']}); // 上传loading、遮罩
        },
        done: function (res) {
            if (res.RetCode == 0) {
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
    });
</script>
</html>

