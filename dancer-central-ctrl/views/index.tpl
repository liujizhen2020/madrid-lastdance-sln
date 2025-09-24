<!DOCTYPE html>

<html>
<head>
  <title>IM管理系统</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script src="/static/js/layui.js"></script>
  <link rel="stylesheet" type="text/css" media="screen" href="/static/js/css/layui.css" />
</head>

<body class="layui-layout-body">
<div class="layui-layout layui-layout-admin">
    <div class="layui-header">
        <div class="layui-logo" style="color:white;">IM管理系统</div>
        <ul class="layui-nav layui-layout-right">
            <li id="welcomeLi" class="layui-nav-item">
            </li>
            <li class="layui-nav-item"><a id='logoutA'>安全退出</a></li>
        </ul>
    </div>

    <div class="layui-side layui-bg-black">
        <div class="layui-side-scroll">
            <!-- 左侧垂直导航区域-->
            <ul class="layui-nav layui-nav-tree" lay-filter="test">
                <li class="layui-nav-item">
                    <a class="" href="javascript:;">提证管理</a>
                    <dl class="layui-nav-child">
                        <dd>
                            <a href="javascript:;" data-id="1-1" data-title="证书提取" data-url="/macCode/cert?"
                               class="site-immain-active" data-type="tabAdd">证书提取</a>
                        </dd>

                        <dd>
                            <a href="javascript:;" data-id="1-2" data-title="标签管理" data-url="/appleId/tag?"
                               class="site-immain-active" data-type="tabAdd">标签管理</a>
                        </dd>

                        <dd>
                            <a href="javascript:;" data-id="1-3" data-title="导出历史" data-url="/imexport/batchExportHistory?"
                               class="site-immain-active" data-type="tabAdd">导出历史</a>
                        </dd>

                        <dd>
                            <a href="javascript:;" data-id="1-4" data-title="服务节点" data-url="/serverNode/list?"
                               class="site-immain-active" data-type="tabAdd">服务节点</a>
                        </dd>
                    </dl>
                </li>
                <li class="layui-nav-item">
                    <a href="javascript:;">任务控制</a>
                    <dl class="layui-nav-child">
                        <dd><a href="javascript:;" data-id="2-1" data-title="任务列表" data-url="/im/task?"
                             class="site-immain-active" data-type="tabAdd">任务列表</a></dd>
                        <dd><a href="javascript:;" data-id="2-2" data-title="指定接收" data-url="/specialSend/toConfig?"
                             class="site-immain-active" data-type="tabAdd" >指定接收</a></dd>
                        <dd><a href="javascript:;" data-id="2-3" data-title="发送日志" data-url="/imlog/serialLog?"
                             class="site-immain-active" data-type="tabAdd">发送日志</a></dd>
                        <dd><a href="javascript:;" data-id="2-4" data-title="账号日志" data-url="/imlog/appleIdLog?"
                             class="site-immain-active" data-type="tabAdd">账号日志</a></dd>
                    </dl>
                </li>
                <li class="layui-nav-item">
                    <a href="javascript:;">系统管理</a>
                    <dl class="layui-nav-child">
                        <dd><a href="javascript:;" data-id="3-1" data-title="元数据配置" data-url="/systemMeta/toConfig?"
                            class="site-immain-active" data-type="tabAdd">元数据配置</a></dd>
                    </dl>
                </li>
            </ul>
        </div>
    </div>

    <!--tab标签-->
    <div class="layui-tab" lay-filter="immain" lay-allowclose="true" style="margin-left: 200px;">
        <ul class="layui-tab-title"></ul>
        <div class="layui-tab-content"></div>
    </div>

<div class="layui-footer" style="text-align:center;">
    <!-- 底部固定区域 -->
    © www.yourcompany.com IM管理系统
</div>
</div>
<script>

  layui.config({
        base: '/static/js/'
    }).extend({
        cookie: 'jquery.cookie'
  });

  layui.use(['element', 'layer', 'jquery','cookie'], function () {
    var element = layui.element;
    var $ = layui.$;
    $('.site-immain-active').on('click', function () {
       var dataid = $(this);
       tabOp(dataid);
    });

    function tabOp(dataid){
      if ($(".layui-tab-title li[lay-id]").length <= 0) {
        active.tabAdd(dataid.attr("data-url"), dataid.attr("data-id"), dataid.attr("data-title"));
      } else {
        $.each($(".layui-tab-title li[lay-id]"), function () {
          if ($(this).attr("lay-id") == dataid.attr("data-id")) {
            active.tabDelete(dataid.attr("data-id"));
          }
        })
        active.tabAdd(dataid.attr("data-url"), dataid.attr("data-id"), dataid.attr("data-title"));
      }
      active.tabChange(dataid.attr("data-id"));
    }

    var username = $.cookie("im_user");
    $("#welcomeLi").text("欢迎回来,"+username);

    var active = {
      tabAdd: function (url, id, name) {
        element.tabAdd('immain', {
          title: name,
          content: '<iframe data-frameid="' + id + '" width="100%" scrolling="auto" frameborder="0" src="' + url + '" ></iframe>',
          id: id
        })
        FrameWH();
      },
      tabChange: function (id) {
        element.tabChange('immain', id); 
      },
      tabDelete: function (id) {
        element.tabDelete("immain", id);
      }
    };

    function FrameWH() {
      var h = $(window).height();
      h = h-120;
      $("iframe").css("height",h+"px");
    }

   $('#logoutA').on('click',function(){
      $.cookie('im_user',"");
      $.cookie('im_token',"");
      window.location.href = "/index";
   })
});
</script>
</body>
</html>
