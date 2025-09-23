<!DOCTYPE html>
<html>
<head>
  <title>宏</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    *{margin:0,padding:0;}
    body{padding: 50px 100px;}
    .text-warning{
      color:#c09853;
      line-height: 35px;
    }
    .op-dd{
      line-height: 35px;
    }
    .op-exp{
      color: blue; cursor: pointer;
    }
    .op-res{
      color: blue; cursor: pointer;
    }
    .op-cle{
      color: red; cursor: pointer;
    }
    .op-itemdel{
      color: red; cursor: pointer;
    }
    .layui-table th{font-weight: bold;background-color: #b0bac4} 
  </style>
</head>
<body>
  <form class="layui-form layuimini-form layer-form">
    <div class="layui-form-item">
        <label class="layui-form-label"></label>
        <div class="layui-input-block">
            <dd class="text-warning">宏定义字符串 {.MacroVal} 切勿弄错,导入格式一行一个</dd>
        </div>
      </div>
      <div class="layui-form-item">
        <label class="layui-form-label">消息ID:</label>
        <div class="layui-input-block" style="width: 300px;">
          <select id="im_select" lay-verify="required" lay-verType="tips"  lay-filter="im_select">
          </select> 
        </div>
      </div>
      <div class="layui-form-item">
        <label class="layui-form-label">操作:</label>
        <div class="layui-input-block" style="width: 300px;">
          <dd class="op-dd">
            <a class="op-exp">导出</a>
            <a class="op-res">重置</a>
            <a class='op-cle'>清除</a>
          </dd>
        </div>
      </div>
      <div class="layui-form-item">
        <label class="layui-form-label required">替换值上传:</label>
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
      <div class="layui-form-item">
        <label class="layui-form-label"></label>
        <div class="layui-input-block">
          <table id="macroListTB"></table>
        </div>
      </div>
  </form>  
  <script type="text/javascript">
    layui.use(['form', 'table','upload'], function () {
      var $ = layui.jquery;
      var form = layui.form;
      var upload = layui.upload;

      var identifier = "{{.identifier}}";
      var idfs_str = '{{.idfs}}';
      var idfs = JSON.parse(idfs_str);
      
      $.each(idfs,function(index,item){
        if (item == identifier){
          $("#im_select").append('<option selected="selected" value="'+item+'">'+item+'</option>');
        }else{
          $("#im_select").append('<option value="'+item+'">'+item+'</option>');
        } 
      });
      form.render("select")

      let txtFile = null; // loading遮罩
      upload.render({
        elem: '#btnChoose',
        url: '/macro/doImport?',
        accept: 'file',
        exts: 'txt|csv',
        auto: false, // 是否选完文件后自动上传。如果设定 false，那么需要设置 bindAction 参数来指向一个其它按钮提交上传
        bindAction: '#btnUpl', // 确定上传按钮id 指定一个其它按钮提交上传
        data:{identifier:''}, // 请求上传接口的额外参数
        before: function (obj) {
            txtFile = layer.load(1, {shade: [0.5, '#000']}); // 上传loading、遮罩
            this.data.identifier = $("#im_select").val();
        },
        done: function (res) {
            if (res.RetCode == 0) {
                return layer.msg(res.RetMsg);
            }
            //上传完毕
            layer.close(txtFile);//关闭遮罩 关闭loading
            layer.msg(res.RetMsg);
            tableData(this.data.identifier);
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
      
      tableData($("#im_select").val());

      function tableData(identifier){
        $.ajax({
          url:"/macro/status?",
          async: false,
          type:"GET",
          data:{"identifier":identifier},
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

      function renderTable(data){
        var table = layui.table;
        // 直接赋值数据
        table.render({
          elem: '#macroListTB',
          cols: [[ //标题栏
            {field: 'Index', title: '序号', width: '8%'},
            {field: 'MacroValue', title: '替换值', width: '8%'},
            {field: 'Status', title: '使用次数', width: '8%'},
            {field: 'LowerLimit', title: '初始条数', width: '8%'},
            {field: 'IsUsing', title: '使用情况', width:'8%',templet:function(d){
              if (d.IsUsing == true){
                return "<dd style='color:green;'>正在使用...</dd>";
              }else{
                return "<dd>等待使用</dd>";
              }
            }},
            {field: 'UpdateAtStr', title: '最后更新时间', width: '8%'},
            {field: 'Operation', title: '操作', templet:function(d){
               return "<dd><a class='op-itemdel' id-ref='"+$("#im_select").val()+"' data-ref='"+d.MacroValue+"'>删除</dd>";
            }},
          ]]
          ,data:data,
          skin: 'row',
          even: true,
          page: false, 
          limit:500,
        });

        $(".op-itemdel").on('click',function(){
            var identifier = $(this).attr("id-ref");
            var value = $(this).attr("data-ref");
            macroOp("/macro/delete?",{"identifier":identifier,"macro_value":value},"确定要删除项目["+value+"]吗?","正在删除项目["+value+"]...");
        })
      }

      form.on('select(im_select)',function(data){
        tableData(data.value);
      })

      $(".op-exp").on('click',function(){
        var identifier = $("#im_select").val();
        window.location.href = "/macro/export?identifier="+identifier;
      })
      
      $(".op-res").on('click',function(){
        var identifier = $("#im_select").val();
        macroOp("/macro/resetStatus?",{"identifier":identifier},"确定要重置宏替换吗?","正在重置宏替换...")
      })

      $(".op-cle").on('click',function(){
        var identifier = $("#im_select").val();
        macroOp("/macro/truncate?",{"identifier":identifier},"确定要清除宏替换吗?","正在清除宏替换...")
      })  

      function macroOp(url,data,msg,optip){
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
                      tableData($("#im_select").val());
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

  })
  </script>
</body>
</html>
