<!DOCTYPE html>

<html>
<head>
  <title>证书</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    *{margin:0,padding:0;}

    body{padding: 50px 100px;}

    .cert-div{width: 100%;height:100%;margin:0 auto;}

    .code-cert{width:45%;height: 100%; float: left; border-style: dashed; border-color: rgba(151, 151, 151, 0.3)}

    .id-cert{width:45%;height: 100%; float: right; border-style: dashed; border-color: rgba(151, 151, 151, 0.3)}

    .op-icon{margin-left:5px;cursor:pointer;font-size:20px; margin:9px 1px;line-height: 38px;}

  </style>
</head>
<body>
  <div class="cert-div">
    <div class="code-cert">
      <form class="layui-form" lay-filter="ssf" id="CCC">
          <div class="layui-form-item">
            <label class="layui-form-label" style="background-color:#009688; font:bold">改机部分</label>
            <div class="layui-input-block">
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">空闲:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="macFree"></label>
               <i class="layui-icon layui-icon-upload-drag op-icon" id="ulMacFree" title="上传"></i>
               <i class="layui-icon layui-icon-download-circle op-icon" id="dlMacFree" title="下载"></i>
               <i class="layui-icon layui-icon-delete op-icon" id="delMacFree" title="删除"></i>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">改机中:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="macInitialize"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">改机成功:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="macReady"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">改机失败:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="macInitFatal"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label" style="background-color:#009688; font:bold">激活IM</label>
            <div class="layui-input-block">
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">激活中:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="IMReg"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">激活成功:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="IMReady"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">激活失败:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="IMRegFatal"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label" style="background-color:#009688; font:bold">证书管理</label>
            <div class="layui-input-block">
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">就绪:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="certReady"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">使用中:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="certWorking"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">已使用:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="certWorked"></label>
            </div>
          </div>
      </form>
    </div>
    <div class="id-cert">
      <form class="layui-form" lay-filter="ssf" id="AAA">
          <div class="layui-form-item">
            <label class="layui-form-label" style="background-color:#009688; font:bold">ID激活IM</label>
            <div class="layui-input-block">
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">空闲:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="idFree" ></label>
               <i class="layui-icon layui-icon-upload-drag op-icon" id="ulIdFree" title="上传"></i>
               <i class="layui-icon layui-icon-download-circle op-icon" id="dlIdFree" title="下载"></i>
               <i class="layui-icon layui-icon-delete op-icon" id="delIdFree" title="删除"></i>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">激活中:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="idLogin"></label>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">激活成功:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="idReady"></label>
                <i class="layui-icon layui-icon-download-circle op-icon" id="dlIdReady" title="下载"></i>
               <i class="layui-icon layui-icon-delete op-icon" id="delIdReady" title="删除"></i>
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">不可用:</label>
            <div class="layui-input-block">
               <label class="layui-form-label" style="text-align: left" id="idFatal"></label>
                <i class="layui-icon layui-icon-download-circle op-icon" id="dlIdFatal" title="下载"></i>
               <i class="layui-icon layui-icon-delete op-icon" id="delIdFatal" title="删除"></i>
            </div>
          </div>
      </form>
    </div>
  </div>
  <script type="text/javascript">
    layui.use(['form', 'util','layer'], function(){
        var $ = layui.$;
        var form = layui.form;
        var layer = layui.layer;
        refreshCertData();

        $("#ulMacFree").on('click', function () {
          window.location.href = "/macCode/toImport?";
        })

        $("#dlMacFree").on('click', function () {
          window.location = "/macCode/export?";
        })

        $("#delMacFree").on('click', function () {
          certOp("/macCode/truncate?",{"status":0},"您确定要删除空闲的设备吗?","正在删除空闲设备...");
        })

        $("#ulIdFree").on('click',function(){
          window.location.href = "/id/toImport?";
        })

        $("#dlIdFree").on('click',function(){
          window.location = "/id/export?status=0";
        })

        $("#dlIdReady").on('click',function(){
          window.location = "/id/export?status=100";
        })

        $("#dlIdFatal").on('click',function(){
          window.location = "/id/export?status=-1";
        })

        $("#delIdFree").on('click',function(){
          certOp("/id/truncate?",{"status":0},"您确定要删除空闲的ID吗?","正在删除空闲ID...")
        })

        $("#delIdReady").on('click',function(){
          certOp("/id/truncate?",{"status":100},"您确定要删除激活成功的ID吗?","正在删除激活成功的ID...")
        })

        $("#delIdFatal").on('click',function(){
          certOp("/id/truncate?",{"status":-1},"您确定要删除不可用的ID吗?","正在删除不可用的ID...")
        })
       
        function refreshCertData(){
          $.ajax({
              url:"/macCode/certData?",
              async: false,
              type:"GET",
              data:{},
              success: function(data){
                if(data.RetCode == 1){
                  renderData(data.Data);
                }else{
                  layer.msg(data.RetMsg);
                }
              }
          })
        }

        function certOp(url,data,msg,optip){
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
                      refreshCertData();
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

        function renderData(certWrap){
          $("#macFree").text(certWrap.MacFree);
          $("#macInitialize").text(certWrap.MacInitilize);
          $("#macReady").text(certWrap.MacReady);
          $("#macInitFatal").text(certWrap.MacInitFatal);

          $("#IMReg").text(certWrap.IMReg);
          $("#IMReady").text(certWrap.IMReady);
          $("#IMRegFatal").text(certWrap.IMRegFatal);

          $("#certReady").text(certWrap.CertReady);
          $("#certWorking").text(certWrap.CertWorking);
          $("#certWorked").text(certWrap.CertWorked)
          $("#certFatal").text(certWrap.CertFatal)

          $("#idFree").text(certWrap.IdFree)
          $("#idLogin").text(certWrap.IdLogin)
          $("#idReady").text(certWrap.IdReady)
          $("#idFatal").text(certWrap.IdFatal)
          
          form.render();
        }
    });
  </script>
</body>
</html>
