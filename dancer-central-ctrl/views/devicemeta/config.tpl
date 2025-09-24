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
          <label class="layui-form-label required">下载原数据:</label>
          <div class="layui-input-block">
                  <a href="/deviceMeta/downloadGroup">下载</a>
          </div>
        </div>
        <div class="layui-form-item">
          <label class="layui-form-label required">上传设备:</label>
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
          <label class="layui-form-label">选择分组</label>
          <div class="layui-input-block" style="width: 95px;">
            <select id="group_select" lay-verify="required" lay-verType="tips"  lay-filter="group_select">
            </select>
          </div>
        </div>
        <div class="layui-form-item">
          <label class="layui-form-label"></label>
          <div class="layui-input-block">
             <table id="devListTB"></table>
          </div>
        </div>
      </form>

  </div> 
</body>
<script type="text/javascript">

  layui.use(['form', 'table','upload'], function () {
      var $ = layui.jquery;
      var form = layui.form;
      var upload = layui.upload;
      
      let txtFile = null; // loading遮罩
      upload.render({
        elem: '#btnChoose',
        url: '/deviceMeta/updateGroup?',
        accept: 'file',
        exts: 'txt',
        auto: false, // 是否选完文件后自动上传。如果设定 false，那么需要设置 bindAction 参数来指向一个其它按钮提交上传
        bindAction: '#btnUpl', // 确定上传按钮id 指定一个其它按钮提交上传
        data:{}, // 请求上传接口的额外参数
        before: function (obj) {
            txtFile = layer.load(1, {shade: [0.5, '#000']}); // 上传loading、遮罩
        },
        done: function (res) {
            if (res.RetCode == 0) {
                return layer.msg(res.RetMsg);
            }
            //上传完毕
            layer.close(txtFile);//关闭遮罩 关闭loading
            layer.msg(res.RetMsg);
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
      var ostr = "{{.owner}}";
      var ownerList = JSON.parse(ostr);
      var html='';

      $.each(ownerList,function(index,item){
        $("#group_select").append('<option value="'+item+'">'+item+'</option>');
      });
      form.render("select")
      tableData($("#group_select").val());

      function tableData(owner){
        $.ajax({
          url:"/deviceMeta/listDeviceByOwner?",
          async: false,
          type:"POST",
          data:{"owner":owner},
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
          elem: '#devListTB',
          cols: [[ //标题栏
            {field: 'SN', title: '序列号', width: 150},
            {field: 'OS', title: '系统版本', width: 100},
            {field: 'Owner', title: '拥有者', width: 100},
            {field: 'GrpIndex', title: '索引号', width: 100},
            {field: 'BizName', title: '业务名称', width: 150},
            {field: 'BizVersion', title: '业务版本', width: 160},
            {field: 'Active', title: '在线状态', width: 160, templet: function (d) {
                    if (d.Active == true) {
                        return "<span style='color: green;''>在线</span>";
                    } else {
                        return "<span style='color: red;''>离线</span>";
                    }
                }
            },
          ]]
          ,data:data,
          skin: 'row',
          even: true,
          page: false, 
          limit:500,
        });
      }

      form.on('select(group_select)',function(data){
        tableData(data.value);
      })
      
  })

</script>
</html>
