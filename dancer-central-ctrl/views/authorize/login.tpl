<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
 
    <title>登录页</title>
    <link rel="stylesheet" href="/static/js/css/layui.css">
    <style type="text/css" charset="utf-8">

        .layui-header {
            background: none;
        }

        .body {
            padding: 10px;
        }


        /* login */
        .login-body {
        }

        .login-box {
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            margin: auto;
            width: 320px;
            height: 241px;
            max-height: 300px;
        }

        .login-body .login-box h3 {
            color: #444;
            font-size: 22px;
            font-weight: 100;
            text-align: center;
        }

        .login-box .layui-input[type='number'] {
            display: inline-block;
            width: 50%;
            vertical-align: top;
        }

        .login-box img {
            display: inline-block;
            width: 46%;
            height: 38px;
            border: none;
            vertical-align: top;
            cursor: pointer;
            margin-left: 4%;
        }

        .login-box button.btn-reset {
            width: 95px;
        }

        .login-box button.btn-submit {
            width: 190px;
        }

        .login-main {
            position: fixed;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            width: 350px;
            margin: 0 auto;
        }

        .login-main header {
            margin-top: 150px;
            height: 35px;
            line-height: 35px;
            font-size: 30px;
            font-weight: 100;
            text-align: center;
        }

        .login-main header, .login-main form, .login-main form .layui-input-inline {
            margin-bottom: 15px;
        }

        .login-main form .layui-input-inline, .login-main form .layui-input-inline input, .login-main form .layui-input-inline button {
            width: 100%;
        }

        .login-main form .login-btn {
            margin-bottom: 5px;
        }

    </style>
</head>
 
</head>
<body>
 
<div class="login-main">
    <header class="layui-elip">登录</header>
    <form class="layui-form">
        <div class="layui-input-inline">
            <input type="text" id="username" name="username" required lay-verify="required" placeholder="用户名" autocomplete="off"
                   class="layui-input">
        </div>
        <div class="layui-input-inline">
            <input type="password" id="password" name="password" required lay-verify="required" placeholder="密码" autocomplete="off"
                   class="layui-input">
        </div>
        <div class="layui-input-inline login-btn">
            <button lay-submit lay-filter="login" class="layui-btn">登录</button>
        </div>
        <hr/>
    </form>
</div>
 
 
<script src="/static/js/layui.js"></script>
<script type="text/javascript">

    layui.config({
        base: '/static/js/' //假设这是cookie.js所在的目录（本页面的相对路径）
    }).extend({ //设定模块别名
        cookie: 'jquery.cookie'
    });

    layui.use(['form','layer','jquery','cookie'], function () {
 
        // 操作对象
        var form = layui.form;
        var $ = layui.jquery;
        var cookie = layui.cookie;

        form.on('submit(login)',function (data) {
            var username = $('#username').val();
            var password = $('#password').val()
            $.ajax({
                url:'/auth/doLogin?',
                data:{'username':username,'password':password},
                type:'post',
                success:function (data) {
                    if (data.RetCode == 0){
                        layer.msg(data.RetMsg);
                    }else{
                       var expireDate = new Date();
                       expireDate.setTime(expireDate.getTime() + (30 * 60 * 1000) ); //expire after 15 minutes
                       $.cookie('im_token', data.Data, {expires:expireDate,path:"/"});
                       $.cookie('im_user',username,{expires:expireDate,path:"/"});
                       window.location.href = "/index";  
                    }
                    
                }
            })
            return false;
        })
 
    });

    if (window != top) {
        console.log("window to top");
        top.location.href = location.href;
    }

</script>
</body>
</html>