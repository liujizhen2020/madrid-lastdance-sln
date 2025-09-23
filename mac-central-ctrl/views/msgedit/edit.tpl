<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- saved from url=(0046)http://45.32.112.191/93790f00send/tmessage.php -->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head> 
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
  <title>数据发送</title> 
  <script type="text/javascript" src="/static/js/layui.js"></script>
  <link rel="stylesheet" href="/static/js/css/layui.css">
  <style type="text/css">
    body{
      padding: 40px;
    }
    .text-warning{
      color:#c09853;
    }
    .emoji-group {
    }
    .emoji-val{
    }
  </style>
 </head> 
 <body> 
  <div class="container"> 
   <div class="span10" style="display:inline;" id="abc"> 
    <div style="margin:0 20px;display:inline;"> 
    <form class="layui-form" lay-filter="ssf" id="AAA">
      <div class="layui-form-item layui-form-text">
        <label class="layui-form-label"></label>
        <div class="layui-input-block">
          <h6 class="text-warning">请自觉遵守互联网相关的政策法规,严禁违法犯罪类用途。</h6> 
        </div>
      </div>
      
      <div class="layui-form-item layui-form-text">
        <label class="layui-form-label">内容</label>
        <div class="layui-input-block">
          <textarea id="content" placeholder="在此录入内容...." class="layui-textarea" name="content"></textarea>
        </div>
      </div>
      <div class="layui-form-item">
        <label></label>
        <div class="layui-input-block">
          <button class="layui-btn" lay-submit  id="ssSubmit">立即提交</button>
          <button type="reset" id="ssReset" class="layui-btn layui-btn-primary">重置</button>
        </div>
      </div>
      <div class="layui-form-item">
        <label></label>
        <div class="layui-input-block">
          <div> 
            <input type="button" class="layui-btn layui-btn-sm layui-btn-primary emoji-group" id="smiles_ref" group-ref="smiles" value="笑脸" /> 
            <input type="button" class="layui-btn layui-btn-sm emoji-group" id="bells_ref"  group-ref="bells" value="铃声"/> 
            <input type="button" class="layui-btn layui-btn-sm emoji-group" id="animals_ref" group-ref="animals" value="动物"/> 
            <input type="button" class="layui-btn layui-btn-sm emoji-group" id="numbers_ref" group-ref="numbers" value="数字"/> 
            <input type="button" class="layui-btn layui-btn-sm emoji-group" id="cars_ref" group-ref="cars" value="车辆"/> 
          </div> 
          <div id="smiles_div"> 
            <img src="/static/js/img/smiles_01_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE04'/> 
            <img src="/static/js/img/smiles_01_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE0A'/> 
            <img src="/static/js/img/smiles_01_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE03'/> 
            <img src="/static/js/img/smiles_01_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u263A'/> 
            <img src="/static/js/img/smiles_01_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE09'/> 
            <img src="/static/js/img/smiles_01_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE0D'/> 
            <img src="/static/js/img/smiles_01_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE18'/> 
            <img src="/static/js/img/smiles_01_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE1A'/> 
            <img src="/static/js/img/smiles_01_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE33'/> 
            <img src="/static/js/img/smiles_01_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE0C'/> 
            <img src="/static/js/img/smiles_01_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE01'/> 
            <img src="/static/js/img/smiles_02_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE1C'/> 
            <br /> 
            <img src="/static/js/img/smiles_02_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE1D'/> 
            <img src="/static/js/img/smiles_02_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE12'/> 
            <img src="/static/js/img/smiles_02_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE0F'/> 
            <img src="/static/js/img/smiles_02_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE13'/> 
            <img src="/static/js/img/smiles_02_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE14'/> 
            <img src="/static/js/img/smiles_02_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE1E'/> 
            <img src="/static/js/img/smiles_02_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE16'/> 
            <img src="/static/js/img/smiles_02_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE25'/> 
            <img src="/static/js/img/smiles_02_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE30'/> 
            <img src="/static/js/img/smiles_02_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE28'/> 
            <img src="/static/js/img/smiles_03_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE23'/> 
            <img src="/static/js/img/smiles_03_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE22'/> 
            <br /> 
            <img src="/static/js/img/smiles_03_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE2D'/> 
            <img src="/static/js/img/smiles_03_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE02'/> 
            <img src="/static/js/img/smiles_03_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE32'/> 
            <img src="/static/js/img/smiles_03_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE31'/> 
            <img src="/static/js/img/smiles_03_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE20'/> 
            <img src="/static/js/img/smiles_03_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE21'/> 
            <img src="/static/js/img/smiles_03_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE2A'/> 
            <img src="/static/js/img/smiles_03_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE37'/> 
            <img src="/static/js/img/smiles_03_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC7F'/> 
            <img src="/static/js/img/smiles_04_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC7D'/> 
            <img src="/static/js/img/smiles_04_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC9B'/> 
            <img src="/static/js/img/smiles_04_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC99'/> 
            <br /> 
            <img src="/static/js/img/smiles_04_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC9C'/> 
            <img src="/static/js/img/smiles_04_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC97'/> 
            <img src="/static/js/img/smiles_04_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC9A'/> 
            <img src="/static/js/img/smiles_04_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2764'/> 
            <img src="/static/js/img/smiles_04_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC94'/> 
            <img src="/static/js/img/smiles_04_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC93'/> 
            <img src="/static/js/img/smiles_04_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC98'/> 
            <img src="/static/js/img/smiles_04_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2728'/> 
            <img src="/static/js/img/smiles_05_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF1F'/> 
            <img src="/static/js/img/smiles_05_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCA2'/> 
            <img src="/static/js/img/smiles_05_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2755'/> 
            <img src="/static/js/img/smiles_05_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2754'/> 
            <br /> 
            <img src="/static/js/img/smiles_05_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCA4'/> 
            <img src="/static/js/img/smiles_05_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCA8'/> 
            <img src="/static/js/img/smiles_05_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCA6'/> 
            <img src="/static/js/img/smiles_05_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFB6'/> 
            <img src="/static/js/img/smiles_05_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFB5'/> 
            <img src="/static/js/img/smiles_05_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD25'/> 
            <img src="/static/js/img/smiles_05_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCA9'/> 
            <img src="/static/js/img/smiles_06_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC4D'/> 
            <img src="/static/js/img/smiles_06_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC4E'/> 
            <img src="/static/js/img/smiles_06_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC4C'/> 
            <img src="/static/js/img/smiles_06_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC4A'/> 
            <img src="/static/js/img/smiles_06_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u270A'/> 
            <br /> 
            <img src="/static/js/img/smiles_06_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u270C'/> 
            <img src="/static/js/img/smiles_06_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC4B'/> 
            <img src="/static/js/img/smiles_06_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u270B'/> 
            <img src="/static/js/img/smiles_06_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC50'/> 
            <img src="/static/js/img/smiles_06_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC46'/> 
            <img src="/static/js/img/smiles_06_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC47'/> 
            <img src="/static/js/img/smiles_07_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC49'/> 
            <img src="/static/js/img/smiles_07_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC48'/> 
            <img src="/static/js/img/smiles_07_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE4C'/> 
            <img src="/static/js/img/smiles_07_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE4F'/> 
            <img src="/static/js/img/smiles_07_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u261D'/> 
            <img src="/static/js/img/smiles_07_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC4F'/> 
            <br /> 
            <img src="/static/js/img/smiles_07_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCAA'/> 
            <img src="/static/js/img/smiles_07_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEB6'/> 
            <img src="/static/js/img/smiles_07_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFC3'/> 
            <img src="/static/js/img/smiles_07_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC6B'/> 
            <img src="/static/js/img/smiles_07_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC83'/> 
            <img src="/static/js/img/smiles_08_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC6F'/> 
            <img src="/static/js/img/smiles_08_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE46'/> 
            <img src="/static/js/img/smiles_08_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE45'/> 
            <img src="/static/js/img/smiles_08_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC81'/> 
            <img src="/static/js/img/smiles_08_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE47'/> 
            <img src="/static/js/img/smiles_08_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC8F'/> 
            <img src="/static/js/img/smiles_08_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC91'/> 
            <br /> 
            <img src="/static/js/img/smiles_08_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC86'/> 
            <img src="/static/js/img/smiles_08_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC87'/> 
            <img src="/static/js/img/smiles_08_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC85'/> 
            <img src="/static/js/img/smiles_08_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC66'/> 
            <img src="/static/js/img/smiles_09_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC67'/> 
            <img src="/static/js/img/smiles_09_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC69'/> 
            <img src="/static/js/img/smiles_09_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC68'/> 
            <img src="/static/js/img/smiles_09_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC76'/> 
            <img src="/static/js/img/smiles_09_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC75'/> 
           </div> 
           <div id="bells_div"> 
            <img src="/static/js/img/smiles_09_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC74'/> 
            <img src="/static/js/img/smiles_09_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC71'/> 
            <img src="/static/js/img/smiles_09_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC72'/> 
            <img src="/static/js/img/smiles_09_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC73'/> 
            <img src="/static/js/img/smiles_09_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC77'/> 
            <img src="/static/js/img/smiles_09_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC6E'/> 
            <img src="/static/js/img/smiles_10_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC7C'/> 
            <img src="/static/js/img/smiles_10_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC78'/> 
            <img src="/static/js/img/smiles_10_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC82'/> 
            <img src="/static/js/img/smiles_10_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC80'/> 
            <img src="/static/js/img/smiles_10_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC63'/> 
            <img src="/static/js/img/smiles_10_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC8B'/> 
            <br /> 
            <img src="/static/js/img/smiles_10_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC44'/> 
            <img src="/static/js/img/smiles_10_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC42'/> 
            <img src="/static/js/img/smiles_10_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC40'/> 
            <img src="/static/js/img/smiles_10_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC43'/> 
            <img src="/static/js/img/bells_01_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF8D'/> 
            <img src="/static/js/img/bells_01_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC9D'/> 
            <img src="/static/js/img/bells_01_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF8E'/> 
            <img src="/static/js/img/bells_01_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF92'/> 
            <img src="/static/js/img/bells_01_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF93'/> 
            <img src="/static/js/img/bells_01_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF8F'/> 
            <img src="/static/js/img/bells_01_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF86'/> 
            <img src="/static/js/img/bells_01_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF87'/> 
            <br /> 
            <img src="/static/js/img/bells_01_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF90'/> 
            <img src="/static/js/img/bells_01_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF91'/> 
            <img src="/static/js/img/bells_01_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF83'/> 
            <img src="/static/js/img/bells_02_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC7B'/> 
            <img src="/static/js/img/bells_02_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF85'/> 
            <img src="/static/js/img/bells_02_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF84'/> 
            <img src="/static/js/img/bells_02_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF81'/> 
            <img src="/static/js/img/bells_02_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD14'/> 
            <img src="/static/js/img/bells_02_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF89'/> 
            <img src="/static/js/img/bells_02_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF88'/> 
            <img src="/static/js/img/bells_02_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCBF'/> 
            <img src="/static/js/img/bells_02_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCC0'/> 
            <br /> 
            <img src="/static/js/img/bells_02_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCF7'/> 
            <img src="/static/js/img/bells_02_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA5'/> 
            <img src="/static/js/img/bells_03_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCBB'/> 
            <img src="/static/js/img/bells_03_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCFA'/> 
            <img src="/static/js/img/bells_03_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCF1'/> 
            <img src="/static/js/img/bells_03_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCE0'/> 
            <img src="/static/js/img/bells_03_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u260E'/> 
            <img src="/static/js/img/bells_03_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCBD'/> 
            <img src="/static/js/img/bells_03_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCFC'/> 
            <img src="/static/js/img/bells_03_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD0A'/> 
            <img src="/static/js/img/bells_03_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCE2'/> 
            <img src="/static/js/img/bells_03_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCE3'/> 
            <br /> 
            <img src="/static/js/img/bells_03_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCFB'/> 
            <img src="/static/js/img/bells_04_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCE1'/> 
            <img src="/static/js/img/bells_04_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u27BF'/> 
            <img src="/static/js/img/bells_04_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD0D'/> 
            <img src="/static/js/img/bells_04_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD13'/> 
            <img src="/static/js/img/bells_04_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD12'/> 
            <img src="/static/js/img/bells_04_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD11'/> 
            <img src="/static/js/img/bells_04_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2702'/> 
            <img src="/static/js/img/bells_04_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD28'/> 
            <img src="/static/js/img/bells_04_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCA1'/> 
            <img src="/static/js/img/bells_04_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCF2'/> 
            <img src="/static/js/img/bells_04_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCE9'/> 
            <br /> 
            <img src="/static/js/img/bells_05_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCEB'/> 
            <img src="/static/js/img/bells_05_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCEE'/> 
            <img src="/static/js/img/bells_05_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEC0'/> 
            <img src="/static/js/img/bells_05_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEBD'/> 
            <img src="/static/js/img/bells_05_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCBA'/> 
            <img src="/static/js/img/bells_05_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCB0'/> 
            <img src="/static/js/img/bells_05_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD31'/> 
            <img src="/static/js/img/bells_05_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEAC'/> 
            <img src="/static/js/img/bells_05_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCA3'/> 
            <img src="/static/js/img/bells_05_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD2B'/> 
            <img src="/static/js/img/bells_05_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC8A'/> 
            <img src="/static/js/img/bells_06_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC89'/> 
            <br /> 
            <img src="/static/js/img/bells_06_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFC8'/> 
            <img src="/static/js/img/bells_06_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFC0'/> 
            <img src="/static/js/img/bells_06_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26BD'/> 
            <img src="/static/js/img/bells_06_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26BE'/> 
            <img src="/static/js/img/bells_06_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFBE'/> 
            <img src="/static/js/img/bells_06_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26F3'/> 
            <img src="/static/js/img/bells_06_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFB1'/> 
            <img src="/static/js/img/bells_06_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFCA'/> 
            <img src="/static/js/img/bells_06_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFC4'/> 
            <img src="/static/js/img/bells_06_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFBF'/> 
            <img src="/static/js/img/bells_07_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2660'/> 
            <img src="/static/js/img/bells_07_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2665'/> 
            <br /> 
            <img src="/static/js/img/bells_07_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2663'/> 
            <img src="/static/js/img/bells_07_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2666'/> 
            <img src="/static/js/img/bells_07_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFC6'/> 
            <img src="/static/js/img/bells_07_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC7E'/> 
            <img src="/static/js/img/bells_07_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFAF'/> 
            <img src="/static/js/img/bells_07_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDC04'/> 
            <img src="/static/js/img/bells_07_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFAC'/> 
            <img src="/static/js/img/bells_07_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCDD'/> 
            <img src="/static/js/img/bells_07_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCD6'/> 
           </div> 
           <div id="animals_div"> 
            <img src="/static/js/img/bells_08_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA8'/> 
            <img src="/static/js/img/bells_08_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA4'/> 
            <img src="/static/js/img/bells_08_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA7'/> 
            <img src="/static/js/img/bells_08_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFBA'/> 
            <img src="/static/js/img/bells_08_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFB7'/> 
            <img src="/static/js/img/bells_08_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFB8'/> 
            <img src="/static/js/img/bells_08_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u303D'/> 
            <img src="/static/js/img/bells_08_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC5F'/> 
            <img src="/static/js/img/bells_08_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC61'/> 
            <img src="/static/js/img/bells_08_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC60'/> 
            <img src="/static/js/img/bells_08_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC62'/> 
            <img src="/static/js/img/bells_09_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC55'/> 
            <br /> 
            <img src="/static/js/img/bells_09_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC54'/> 
            <img src="/static/js/img/bells_09_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC57'/> 
            <img src="/static/js/img/bells_09_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC58'/> 
            <img src="/static/js/img/bells_09_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC59'/> 
            <img src="/static/js/img/bells_09_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF80'/> 
            <img src="/static/js/img/bells_09_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA9'/> 
            <img src="/static/js/img/bells_09_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC51'/> 
            <img src="/static/js/img/bells_09_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC52'/> 
            <img src="/static/js/img/bells_09_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF02'/> 
            <img src="/static/js/img/bells_09_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCBC'/> 
            <img src="/static/js/img/bells_10_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC5C'/> 
            <img src="/static/js/img/bells_10_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC84'/> 
            <br /> 
            <img src="/static/js/img/bells_10_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC8D'/> 
            <img src="/static/js/img/bells_10_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC8E'/> 
            <img src="/static/js/img/bells_10_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2615'/> 
            <img src="/static/js/img/bells_10_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF75'/> 
            <img src="/static/js/img/bells_10_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF7A'/> 
            <img src="/static/js/img/bells_10_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF7B'/> 
            <img src="/static/js/img/bells_10_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF78'/> 
            <img src="/static/js/img/bells_10_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF76'/> 
            <img src="/static/js/img/bells_10_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF74'/> 
            <img src="/static/js/img/bells_11_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF54'/> 
            <img src="/static/js/img/bells_11_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF5F'/> 
            <img src="/static/js/img/bells_11_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF5D'/> 
            <br /> 
            <img src="/static/js/img/bells_11_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF5B'/> 
            <img src="/static/js/img/bells_11_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF71'/> 
            <img src="/static/js/img/bells_11_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF63'/> 
            <img src="/static/js/img/bells_11_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF59'/> 
            <img src="/static/js/img/bells_11_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF58'/> 
            <img src="/static/js/img/bells_11_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF5A'/> 
            <img src="/static/js/img/bells_11_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF5C'/> 
            <img src="/static/js/img/bells_11_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF72'/> 
            <img src="/static/js/img/bells_12_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF5E'/> 
            <img src="/static/js/img/bells_12_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF73'/> 
            <img src="/static/js/img/bells_12_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF62'/> 
            <img src="/static/js/img/bells_12_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF61'/> 
            <br /> 
            <img src="/static/js/img/bells_12_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF66'/> 
            <img src="/static/js/img/bells_12_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF67'/> 
            <img src="/static/js/img/bells_12_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF82'/> 
            <img src="/static/js/img/bells_12_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF70'/> 
            <img src="/static/js/img/bells_12_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF4E'/> 
            <img src="/static/js/img/bells_12_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF4A'/> 
            <img src="/static/js/img/bells_12_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF49'/> 
            <img src="/static/js/img/bells_13_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF53'/> 
            <img src="/static/js/img/bells_13_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF46'/> 
            <img src="/static/js/img/bells_13_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF45'/> 
            <img src="/static/js/img/flowers_01_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2600'/> 
            <img src="/static/js/img/flowers_01_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2614'/> 
            <br /> 
            <img src="/static/js/img/flowers_01_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2601'/> 
            <img src="/static/js/img/flowers_01_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26C4'/> 
            <img src="/static/js/img/flowers_01_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF19'/> 
            <img src="/static/js/img/flowers_01_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26A1'/> 
            <img src="/static/js/img/flowers_01_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF00'/> 
            <img src="/static/js/img/flowers_01_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF0A'/> 
            <img src="/static/js/img/flowers_01_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC31'/> 
            <img src="/static/js/img/flowers_01_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC36'/> 
            <img src="/static/js/img/flowers_01_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC2D'/> 
            <img src="/static/js/img/flowers_02_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC39'/> 
            <img src="/static/js/img/flowers_02_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC30'/> 
            <img src="/static/js/img/flowers_02_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC3A'/> 
            <br /> 
            <img src="/static/js/img/flowers_02_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC38'/> 
            <img src="/static/js/img/flowers_02_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC2F'/> 
            <img src="/static/js/img/flowers_02_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC28'/> 
            <img src="/static/js/img/flowers_02_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC3B'/> 
            <img src="/static/js/img/flowers_02_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC37'/> 
            <img src="/static/js/img/flowers_02_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC2E'/> 
            <img src="/static/js/img/flowers_02_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC17'/> 
            <img src="/static/js/img/flowers_02_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC35'/> 
            <img src="/static/js/img/flowers_03_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC12'/> 
            <img src="/static/js/img/flowers_03_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC34'/> 
            <img src="/static/js/img/flowers_03_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC0E'/> 
            <img src="/static/js/img/flowers_03_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC2B'/> 
            <br /> 
            <img src="/static/js/img/flowers_03_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC11'/> 
            <img src="/static/js/img/flowers_03_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC18'/> 
            <img src="/static/js/img/flowers_03_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC0D'/> 
            <img src="/static/js/img/flowers_03_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC26'/> 
            <img src="/static/js/img/flowers_03_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC24'/> 
            <img src="/static/js/img/flowers_03_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC14'/> 
            <img src="/static/js/img/flowers_03_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC27'/> 
            <img src="/static/js/img/flowers_04_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC1B'/> 
            <img src="/static/js/img/flowers_04_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC19'/> 
           </div> 
           <div id="numbers_div"> 
            <img src="/static/js/img/flowers_04_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC20'/> 
            <img src="/static/js/img/flowers_04_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC1F'/> 
            <img src="/static/js/img/flowers_04_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC33'/> 
            <img src="/static/js/img/flowers_04_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC2C'/> 
            <img src="/static/js/img/flowers_04_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC90'/> 
            <img src="/static/js/img/flowers_04_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF38'/> 
            <img src="/static/js/img/flowers_04_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF37'/> 
            <img src="/static/js/img/flowers_04_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF40'/> 
            <img src="/static/js/img/flowers_04_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF39'/> 
            <img src="/static/js/img/flowers_05_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF3B'/> 
            <img src="/static/js/img/flowers_05_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF3A'/> 
            <img src="/static/js/img/flowers_05_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF41'/> 
            <br /> 
            <img src="/static/js/img/flowers_05_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF43'/> 
            <img src="/static/js/img/flowers_05_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF42'/> 
            <img src="/static/js/img/flowers_05_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF34'/> 
            <img src="/static/js/img/flowers_05_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF35'/> 
            <img src="/static/js/img/flowers_05_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF3E'/> 
            <img src="/static/js/img/flowers_05_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC1A'/> 
            <img src="/static/js/img/numbers_01_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0031%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0032%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0033%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0034%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0035%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0036%ufe0f%u20e3'/> 
            <br /> 
            <img src="/static/js/img/numbers_01_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0037%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0038%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0039%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0030%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_01_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u0023%ufe0f%u20e3'/> 
            <img src="/static/js/img/numbers_02_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2B06'/> 
            <img src="/static/js/img/numbers_02_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2B07'/> 
            <img src="/static/js/img/numbers_02_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2B05'/> 
            <img src="/static/js/img/numbers_02_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u27A1'/> 
            <img src="/static/js/img/numbers_02_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2197'/> 
            <img src="/static/js/img/numbers_02_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2196'/> 
            <img src="/static/js/img/numbers_02_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2198'/> 
            <br /> 
            <img src="/static/js/img/numbers_02_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2199'/> 
            <img src="/static/js/img/numbers_02_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u25C0'/> 
            <img src="/static/js/img/numbers_02_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u25B6'/> 
            <img src="/static/js/img/numbers_02_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u23EA'/> 
            <img src="/static/js/img/numbers_03_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u23E9'/> 
            <img src="/static/js/img/numbers_03_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD97'/> 
            <img src="/static/js/img/numbers_03_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD95'/> 
            <img src="/static/js/img/numbers_03_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD1D'/> 
            <img src="/static/js/img/numbers_03_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD99'/> 
            <img src="/static/js/img/numbers_03_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD92'/> 
            <img src="/static/js/img/numbers_03_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA6'/> 
            <img src="/static/js/img/numbers_03_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE01'/> 
            <br /> 
            <img src="/static/js/img/numbers_03_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCF6'/> 
            <img src="/static/js/img/numbers_03_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE35'/> 
            <img src="/static/js/img/numbers_03_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE33'/> 
            <img src="/static/js/img/numbers_04_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE50'/> 
            <img src="/static/js/img/numbers_04_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE39'/> 
            <img src="/static/js/img/numbers_04_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE2F'/> 
            <img src="/static/js/img/numbers_04_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE3A'/> 
            <img src="/static/js/img/numbers_04_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE36'/> 
            <img src="/static/js/img/numbers_04_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE1A'/> 
            <img src="/static/js/img/numbers_04_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE37'/> 
            <img src="/static/js/img/numbers_04_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE38'/> 
            <img src="/static/js/img/numbers_04_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDE02'/> 
            <br /> 
            <img src="/static/js/img/numbers_04_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEBB'/> 
            <img src="/static/js/img/numbers_04_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEB9'/> 
            <img src="/static/js/img/numbers_05_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEBA'/> 
            <img src="/static/js/img/numbers_05_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEBC'/> 
            <img src="/static/js/img/numbers_05_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEAD'/> 
            <img src="/static/js/img/numbers_05_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD7F'/> 
            <img src="/static/js/img/numbers_05_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u267F'/> 
            <img src="/static/js/img/numbers_05_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE87'/> 
            <img src="/static/js/img/numbers_05_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEBE'/> 
            <img src="/static/js/img/numbers_05_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u3299'/> 
            <img src="/static/js/img/numbers_05_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u3297'/> 
            <img src="/static/js/img/numbers_05_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD1E'/> 
            <br /> 
            <img src="/static/js/img/numbers_05_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD94'/> 
            <img src="/static/js/img/numbers_06_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2733'/> 
            <img src="/static/js/img/numbers_06_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2734'/> 
            <img src="/static/js/img/numbers_06_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC9F'/> 
            <img src="/static/js/img/numbers_06_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD9A'/> 
            <img src="/static/js/img/numbers_06_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCF3'/> 
            <img src="/static/js/img/numbers_06_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCF4'/> 
            <img src="/static/js/img/numbers_06_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCB9'/> 
            <img src="/static/js/img/numbers_06_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDCB1'/> 
            <img src="/static/js/img/numbers_06_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2648'/> 
            <img src="/static/js/img/numbers_06_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2649'/> 
            <img src="/static/js/img/numbers_06_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u264A'/> 
            <br /> 
            <img src="/static/js/img/numbers_07_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u264B'/> 
            <img src="/static/js/img/numbers_07_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u264C'/> 
            <img src="/static/js/img/numbers_07_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u264D'/> 
            <img src="/static/js/img/numbers_07_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u264E'/> 
            <img src="/static/js/img/numbers_07_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u264F'/> 
            <img src="/static/js/img/numbers_07_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2650'/> 
            <img src="/static/js/img/numbers_07_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2651'/> 
            <img src="/static/js/img/numbers_07_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2652'/> 
            <img src="/static/js/img/numbers_07_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2653'/> 
           </div> 
           <div id="cars_div"> 
            <img src="/static/js/img/numbers_07_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26CE'/> 
            <img src="/static/js/img/numbers_07_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD2F'/> 
            <img src="/static/js/img/numbers_08_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD70'/> 
            <img src="/static/js/img/numbers_08_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD71'/> 
            <img src="/static/js/img/numbers_08_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD8E'/> 
            <img src="/static/js/img/numbers_08_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDD7E'/> 
            <img src="/static/js/img/numbers_08_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD32'/> 
            <img src="/static/js/img/numbers_08_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD34'/> 
            <img src="/static/js/img/numbers_08_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD33'/> 
            <img src="/static/js/img/numbers_08_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD5B'/> 
            <img src="/static/js/img/numbers_08_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD50'/> 
            <img src="/static/js/img/numbers_08_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD51'/> 
            <br /> 
            <img src="/static/js/img/numbers_08_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD52'/> 
            <img src="/static/js/img/numbers_09_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD53'/> 
            <img src="/static/js/img/numbers_09_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD54'/> 
            <img src="/static/js/img/numbers_09_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD55'/> 
            <img src="/static/js/img/numbers_09_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD56'/> 
            <img src="/static/js/img/numbers_09_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD57'/> 
            <img src="/static/js/img/numbers_09_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD58'/> 
            <img src="/static/js/img/numbers_09_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD59'/> 
            <img src="/static/js/img/numbers_09_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD5A'/> 
            <img src="/static/js/img/numbers_09_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2B55'/> 
            <img src="/static/js/img/numbers_09_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u274C'/> 
            <img src="/static/js/img/numbers_10_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2122'/> 
            <br /> 
            <img src="/static/js/img/cars_01_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE0'/> 
            <img src="/static/js/img/cars_01_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFEB'/> 
            <img src="/static/js/img/cars_01_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE2'/> 
            <img src="/static/js/img/cars_01_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE3'/> 
            <img src="/static/js/img/cars_01_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE5'/> 
            <img src="/static/js/img/cars_01_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE6'/> 
            <img src="/static/js/img/cars_01_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFEA'/> 
            <img src="/static/js/img/cars_01_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE9'/> 
            <img src="/static/js/img/cars_01_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE8'/> 
            <img src="/static/js/img/cars_01_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC92'/> 
            <img src="/static/js/img/cars_01_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26EA'/> 
            <img src="/static/js/img/cars_02_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFEC'/> 
            <br /> 
            <img src="/static/js/img/cars_02_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF07'/> 
            <img src="/static/js/img/cars_02_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF06'/> 
            <img src="/static/js/img/cars_02_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFE7'/> 
            <img src="/static/js/img/cars_02_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFEF'/> 
            <img src="/static/js/img/cars_02_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFF0'/> 
            <img src="/static/js/img/cars_02_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26FA'/> 
            <img src="/static/js/img/cars_02_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFED'/> 
            <img src="/static/js/img/cars_02_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDDFC'/> 
            <img src="/static/js/img/cars_02_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDDFB'/> 
            <img src="/static/js/img/cars_02_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF04'/> 
            <img src="/static/js/img/cars_03_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF05'/> 
            <img src="/static/js/img/cars_03_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF03'/> 
            <br /> 
            <img src="/static/js/img/cars_03_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDDFD'/> 
            <img src="/static/js/img/cars_03_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF08'/> 
            <img src="/static/js/img/cars_03_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA1'/> 
            <img src="/static/js/img/cars_03_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26F2'/> 
            <img src="/static/js/img/cars_03_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFA2'/> 
            <img src="/static/js/img/cars_03_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEA2'/> 
            <img src="/static/js/img/cars_03_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEA4'/> 
            <img src="/static/js/img/cars_03_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26F5'/> 
            <img src="/static/js/img/cars_03_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2708'/> 
            <img src="/static/js/img/cars_04_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE80'/> 
            <img src="/static/js/img/cars_04_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEB2'/> 
            <img src="/static/js/img/cars_04_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE99'/> 
            <br /> 
            <img src="/static/js/img/cars_04_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE97'/> 
            <img src="/static/js/img/cars_04_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE95'/> 
            <img src="/static/js/img/cars_04_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE8C'/> 
            <img src="/static/js/img/cars_04_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE93'/> 
            <img src="/static/js/img/cars_04_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE92'/> 
            <img src="/static/js/img/cars_04_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE91'/> 
            <img src="/static/js/img/cars_04_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE9A'/> 
            <img src="/static/js/img/cars_04_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE83'/> 
            <img src="/static/js/img/cars_05_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE89'/> 
            <img src="/static/js/img/cars_05_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE84'/> 
            <img src="/static/js/img/cars_05_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE85'/> 
            <img src="/static/js/img/cars_05_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFAB'/> 
            <br /> 
            <img src="/static/js/img/cars_05_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26FD'/> 
            <img src="/static/js/img/cars_05_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEA5'/> 
            <img src="/static/js/img/cars_05_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u26A0'/> 
            <img src="/static/js/img/cars_05_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDEA7'/> 
            <img src="/static/js/img/cars_05_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDD30'/> 
            <img src="/static/js/img/cars_05_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFB0'/> 
            <img src="/static/js/img/cars_05_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDE8F'/> 
            <img src="/static/js/img/cars_06_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83D%uDC88'/> 
            <img src="/static/js/img/cars_06_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%u2668'/> 
            <img src="/static/js/img/cars_06_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDFC1'/> 
            <img src="/static/js/img/cars_06_04.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDF8C'/> 
            <img src="/static/js/img/cars_06_05.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDEF%uD83C%uDDF5'/> 
            <br /> 
            <img src="/static/js/img/cars_06_06.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDF0%uD83C%uDDF7'/> 
            <img src="/static/js/img/cars_06_07.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDE8%uD83C%uDDF3'/> 
            <img src="/static/js/img/cars_06_08.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDFA%uD83C%uDDF8'/> 
            <img src="/static/js/img/cars_06_09.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDEB%uD83C%uDDF7'/> 
            <img src="/static/js/img/cars_06_10.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDEA%uD83C%uDDF8'/> 
            <img src="/static/js/img/cars_06_11.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDEE%uD83C%uDDF9'/> 
            <img src="/static/js/img/cars_07_01.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDF7%uD83C%uDDFA'/> 
            <img src="/static/js/img/cars_07_02.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDEC%uD83C%uDDE7'/> 
            <img src="/static/js/img/cars_07_03.png" border="0" width="23" height="23" class="emoji-item" emoji-val='%uD83C%uDDE9%uD83C%uDDEA'/> 
          </div> 
        </div>
      </div>
    </form>
    </div> 
   </div> 
  </div> 
  <script type="text/javascript">
  

  layui.use(['form', 'util', 'laydate','layer','jquery'], function(){
    var $ = layui.$;
    var form = layui.form;
    var layer = layui.layer;
    var jQuery = layui.jquery;
    var util = layui.util;
    var identifier = "{{.identifier}}";
    // 提交事件

    (function($){
        $.fn.insert=function(_m){
            var _o=$(this).get(0);
            if(document.selection){
                _o.focus();sel=document.selection.createRange();sel.text=_m;sel.select();
            }else if(_o.selectionStart || _o.selectionStart == '0'){
                var startPos=_o.selectionStart;var endPos=_o.selectionEnd;var restoreTop=_o.scrollTop;
                _o.value=_o.value.substring(0, startPos) + _m + _o.value.substring(endPos,_o.value.length);
                if (restoreTop>0){_o.scrollTop=restoreTop;}
                _o.focus();_o.selectionStart=startPos+_m.length;_o.selectionEnd=startPos+_m.length;
            }
        }
    })(jQuery);

    form.on('submit(ssf)', function(data){ 
      var postData = {'text':$('#content').val(),'identifier':identifier};  
      $.ajax({
          url:"/msgedit/doEditText?",
          async: false,
          type:"POST",
          data:postData,
          success: function(data){
            if(data.RetCode == 1){
              layer.msg(data.RetMsg);
            }else{
              layer.alert(data.RetMsg);
            }
            var endTime = (new Date()).getTime() + 2*1000;
            var serverTime = (new Date()).getTime();
            util.countdown(endTime, serverTime, function(date,serverTime,timer){
                var min = date[2];
                var sec = date[3];
                if(min == 0 && sec == 0){
                   window.location.href = "/im/task?"
                }
            });
          }
      })
      return false;
    });

    form.val('ssf',{
      'content':"{{.text}}"
    })
    form.render();
    
    $('#ssReset').on('click', function(){
       form.val('ssf',{
        'content':'',
       })
    });

    $('.emoji-group').on('click', function () {
      var dataid = $(this);
      var gref = dataid.attr("group-ref");
      $("#smiles_div").hide();
      $("#bells_div").hide();
      $("#animals_div").hide();
      $("#numbers_div").hide();
      $("#cars_div").hide();
      $("#smiles_ref").removeClass("layui-btn-primary");
      $("#bells_ref").removeClass("layui-btn-primary");
      $("#animals_ref").removeClass("layui-btn-primary");
      $("#numbers_ref").removeClass("layui-btn-primary");
      $("#cars_ref").removeClass("layui-btn-primary");
      $("#"+gref+"_ref").addClass("layui-btn-primary");
      $("#"+gref+"_div").show();
    });

    $("#smiles_ref").click();

    $('.emoji-item').on('click',function(){
       var em = $(this);
       var em_val = em.attr("emoji-val");
       $("#content").insert(unescape(em_val));
    })

  });
  

</script>  
 </body>
</html>