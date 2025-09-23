<!DOCTYPE html>

<html>
<head>
  <title>IM-配置元数据</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    body{padding: 50px 100px;}
    .sys-meta {border-style: dashed; margin-bottom:15px; border-color: rgba(151, 151, 151, 0.3)}
  </style>
</head>
<body>
  <div>
    <form class="layui-form" lay-filter="ssf" id="AAA">
        <div class="layui-form-item" style="margin-bottom:0px">
          <label class="layui-form-label" style="background-color:#009688; font:bold">证书管理</label>
          <div class="layui-input-block">
          </div>
        </div>
        <div class="sys-meta">
          <div class="layui-form-item">
            <label class="layui-form-label">静置时间(H)</label>
            <div class="layui-input-block" id="ck_dispatch_interval" style="width: 230px;">
            </div>
          </div>
          <div class="layui-form-item layui-form-text">
            <label class="layui-form-label">重下发间隔(H)</label>
            <div class="layui-input-block" id="ck_redispatch_interval" style="width: 230px;">
            </div>
          </div>
          <div class="layui-form-item layui-form-text">
            <label class="layui-form-label">重下发次数</label>
            <div class="layui-input-block" id="ck_redispatch_num" style="width: 230px;">
            </div>
          </div>
        </div>
        <div class="layui-form-item" style="margin-bottom: 0px;">
          <label class="layui-form-label" style="background-color:#009688">发送控制</label>
          <div class="layui-input-block">
          </div>
        </div>
        <div class="sys-meta">
          <div class="layui-form-item">
            <label class="layui-form-label">任务数</label>
            <div class="layui-input-block" id="phone_num_fetched_default" style="width: 230px;">
            </div>
          </div>
          <div class="layui-form-item layui-form-text">
            <label class="layui-form-label">发送间隔(S)</label>
              <div class="layui-input-block" id="send_msg_interval" style="width: 230px;">
              </div>
          </div>
          <div class="layui-form-item layui-form-text">
              <label class="layui-form-label">结束等待(S)</label>
              <div class="layui-input-block" id="send_wait_aftersend" style="width: 230px;">
              </div>
          </div>
          <div class="layui-form-item layui-form-text">
              <label class="layui-form-label">连续失败</label>
              <div class="layui-input-block" id="send_failure_stop" style="width: 230px;">
              </div>
          </div>
        </div>
        <div class="layui-form-item" style="margin-bottom: 0px;">
          <label class="layui-form-label" style="background-color:#009688">回收控制</label>
          <div class="layui-input-block">
          </div>
        </div>
        <div class="sys-meta">
          <div class="layui-form-item">
            <label class="layui-form-label">码超时间隔(M)</label>
            <div class="layui-input-block" id="maccode_expire_interval" style="width: 230px;">
            </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">码回收间隔(M)</label>
            <div class="layui-input-block" id="maccode_recycle_interval" style="width: 230px;">
            </div>
          </div>
          <div class="layui-form-item layui-form-text">
              <label class="layui-form-label">ID回收间隔(M)</label>
              <div class="layui-input-block" id="appleid_recycle_interval" style="width: 230px;">
              </div>
          </div>
          <div class="layui-form-item layui-form-text">
              <label class="layui-form-label">号回收间隔(M)</label>
              <div class="layui-input-block" id="phone_recycle_interval" style="width: 230px;">
              </div>
          </div>
          <div class="layui-form-item layui-form-text">
              <label class="layui-form-label">ID回收次数</label>
              <div class="layui-input-block" id="recycle_num_appleid" style="width: 230px;">
              </div>
          </div>
          <div class="layui-form-item layui-form-text">
              <label class="layui-form-label">号回收次数</label>
              <div class="layui-input-block" id="recycle_num_phone" style="width: 230px;">
              </div>
          </div>
        </div>
        <div class="layui-form-item" style="margin-bottom:0px">
          <label class="layui-form-label" style="background-color:#009688; font:bold">规则管理</label>
          <div class="layui-input-block">
          </div>
        </div>
        <div class="sys-meta">
          <div class="layui-form-item">
            <label class="layui-form-label">多设备数</label>
            <div class="layui-input-block" id="trailer_num_appleid" style="width: 230px;">
            </div>
          </div>
        </div>
        <div class="layui-form-item" style="margin-bottom: 0px">
          <label class="layui-form-label" style="background-color:#009688">系统开关</label>
          <div class="layui-input-block">
          </div>
        </div>
        <div class="sys-meta">
          <div class="layui-form-item">
            <label class="layui-form-label">代理</label>
              <div class="layui-input-block">
                   <input type="checkbox" id="proxySwitch" lay-skin="switch" lay-filter="proxySwitch"  lay-text="开启|关闭">
                </div>
          </div>
          <div class="layui-form-item">
            <label class="layui-form-label">提证</label>
              <div class="layui-input-block">
                   <input type="checkbox" id="certExtractSwitch" lay-skin="switch" lay-filter="certExtractSwitch"  lay-text="开启|关闭">
                </div>
          </div>
          <div class="layui-form-item">
              <label class="layui-form-label">发送</label>
                <div class="layui-input-block">
                  <input type="checkbox" id="certWorkSwitch" lay-skin="switch" lay-filter="certWorkSwitch"  lay-text="开启|关闭">
                </div>
          </div>
          <div class="layui-form-item">
              <label class="layui-form-label">多设备</label>
                <div class="layui-input-block">
                  <input type="checkbox" id="trailerSwitch" lay-skin="switch" lay-filter="trailerSwitch"  lay-text="开启|关闭">
                </div>
          </div>
        </div>
      </form>
    </div>
    <script>

      layui.config({
        base: '/static/js/' //本脚本所在路径
      }).extend({labeledit:"labeledit"});

      layui.use(['form', 'jquery','labeledit'], function () {

        var $ = layui.jquery;
        var form = layui.form;
        var labeledit=layui.labeledit;
        var m = "{{.m}}";
        var mmap = JSON.parse(m);
        labeledit.render({
            elem:'#ck_dispatch_interval',//组件ID
            editType: 'text',
            value:{id:mmap["CK_DISPATCH_INTERVAL"],text:mmap["CK_DISPATCH_INTERVAL"]},
            savecallback(value,text){
              saveMeta("CK_DISPATCH_INTERVAL",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#ck_redispatch_interval',//组件ID
            editType: 'text',
            value:{id:mmap["CK_REDISPATCH_INTERVAL"],text:mmap["CK_REDISPATCH_INTERVAL"]},
            savecallback(value,text){
              saveMeta("CK_REDISPATCH_INTERVAL",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#ck_redispatch_num',//组件ID
            editType: 'text',
            value:{id:mmap["CK_REDISPATCH_NUM"],text:mmap["CK_REDISPATCH_NUM"]},
            savecallback(value,text){
              saveMeta("CK_REDISPATCH_NUM",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#phone_num_fetched_default',//组件ID
            editType: 'text',
            value:{id:mmap["PHONE_NUM_FETCHED_DEFAULT"],text:mmap["PHONE_NUM_FETCHED_DEFAULT"]},
            savecallback(value,text){
              saveMeta("PHONE_NUM_FETCHED_DEFAULT",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#send_msg_interval',//组件ID
            editType: 'text',
            value:{id:mmap["SEND_MSG_INTERVAL"],text:mmap["SEND_MSG_INTERVAL"]},
            savecallback(value,text){
              saveMeta("SEND_MSG_INTERVAL",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#send_wait_aftersend',//组件ID
            editType: 'text',
            value:{id:mmap["SEND_WAIT_AFTERSEND"],text:mmap["SEND_WAIT_AFTERSEND"]},
            savecallback(value,text){
              saveMeta("SEND_WAIT_AFTERSEND",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#send_failure_stop',//组件ID
            editType: 'text',
            value:{id:mmap["SEND_FAILURE_STOP"],text:mmap["SEND_FAILURE_STOP"]},
            savecallback(value,text){
              saveMeta("SEND_FAILURE_STOP",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#maccode_expire_interval',//组件ID
            editType: 'text',
            value:{id:mmap["MACCODE_EXPIRE_INTERVAL"],text:mmap["MACCODE_EXPIRE_INTERVAL"]},
            savecallback(value,text){
              saveMeta("MACCODE_EXPIRE_INTERVAL",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#maccode_recycle_interval',//组件ID
            editType: 'text',
            value:{id:mmap["MACCODE_RECYCLE_INTERVAL"],text:mmap["MACCODE_RECYCLE_INTERVAL"]},
            savecallback(value,text){
              saveMeta("MACCODE_RECYCLE_INTERVAL",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#appleid_recycle_interval',//组件ID
            editType: 'text',
            value:{id:mmap["APPLEID_RECYCLE_INTERVAL"],text:mmap["APPLEID_RECYCLE_INTERVAL"]},
            savecallback(value,text){
              saveMeta("APPLEID_RECYCLE_INTERVAL",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#phone_recycle_interval',//组件ID
            editType: 'text',
            value:{id:mmap["PHONE_RECYCLE_INTERVAL"],text:mmap["PHONE_RECYCLE_INTERVAL"]},
            savecallback(value,text){
              saveMeta("PHONE_RECYCLE_INTERVAL",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#recycle_num_appleid',//组件ID
            editType: 'text',
            value:{id:mmap["RECYCLE_NUM_APPLEID"],text:mmap["RECYCLE_NUM_APPLEID"]},
            savecallback(value,text){
              saveMeta("RECYCLE_NUM_APPLEID",value);
              return true;
            }
        });
        labeledit.render({
            elem:'#recycle_num_phone',//组件ID
            editType: 'text',
            value:{id:mmap["RECYCLE_NUM_PHONE"],text:mmap["RECYCLE_NUM_PHONE"]},
            savecallback(value,text){
              saveMeta("RECYCLE_NUM_PHONE",value);
              return true;
            }
        });

        labeledit.render({
            elem:'#trailer_num_appleid',//组件ID
            editType: 'text',
            value:{id:mmap["TRAILER_NUM_APPLEID"],text:mmap["TRAILER_NUM_APPLEID"]},
            savecallback(value,text){
              saveMeta("TRAILER_NUM_APPLEID",value);
              return true;
            }
        });

        if(mmap["TRAILER_SWITCH"] == "1"){
            $("#trailerSwitch").attr("checked","checked");
        }

        if(mmap["PROXY_SWITCH"] == "1"){
            $("#proxySwitch").attr("checked","checked");
        }
        if(mmap["CERTEXTRACT_SWITCH"] == "1"){
            $("#certExtractSwitch").attr("checked","checked");
        }
        if(mmap["CERTWORK_SWITCH"] == "1"){
            $("#certWorkSwitch").attr("checked","checked");
        }

        form.on('switch(trailerSwitch)',function(data){
          saveMeta("TRAILER_SWITCH",(this.checked?"1":"0"));
        })

        form.on("switch(proxySwitch)",function(data){
          saveMeta("PROXY_SWITCH",(this.checked?"1":"0"));
        })

        form.on("switch(certExtractSwitch)",function(data){
          saveMeta("CERTEXTRACT_SWITCH",(this.checked?"1":"0"));
        })

        form.on("switch(certWorkSwitch)",function(data){
          saveMeta("CERTWORK_SWITCH",(this.checked?"1":"0"));
        })

        form.render();

        function saveMeta(k,v){
          $.ajax({
            url:"/systemMeta/saveConfig?",
            async: false,
            type:"POST",
            data:{"param_key":k,"param_value":v},
            success: function(data){
              if(data.RetCode == 1){
                layer.msg(data.RetMsg);
              }else{
                layer.alert(data.RetMsg);
              }
            }
          })
        }
      });

    </script>
</body>
</html>
