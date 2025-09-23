/*labeledit
 * @Author: 王洪刚
 * @Version:V1.0
 * @Date: 2020-11-6
 * @Last Modified: 2020-11-6 13:17:00
 * @Desc:
 * labeledit 是一个文本显示与编辑功能切换的组件，组件基于layui实现，编辑类型可以是文本 单选框 下拉选择框 勾选框 日期选择 时分选择 颜色选择
 * 使用方法
 * layui.config({
 *      base: '/lib/layui-v2.5.6/ext/' //本脚本所在路径
 *  }).use('labeledit'.function(){
 *      var labeledit=layui.labeledit;
 *      labeledit.render({
 *          elem:'#test1'//组件ID
 *      });
 *  });
 *  组件属性说明
 *  elem:必需项 使用jq选择器
 *  editType:编辑类型 默认为 text, 支持的类型有 text-文本输入框 radio-单选框 select-下拉选择框 checkbox-勾选框 date-日期选择框 time-时间选择框 color-颜色选择框
 *  value:初始化默认值 结构为{"id":"1","text":"显示内容"} id表示组件的值 text 表示组件显示的内容 editType为text,date,time,color时id与text相同
 *  items:选择项 结构为[{"id":"1","text":"选择1"},{"id":"2","text":"选择2"}] editType为radio,select,checkbox时的必需项,其中editType为checkbox时数组中第一项为未勾选的值 第二项为勾选的值
 *  savecallback:编辑完成保存的回调函数 有2个参数 value,text 分别是编辑控制返回的值和显示内容,保存成功返回true 保存失败返回false
 * */
layui.define(["laydate", "laytpl", "form", "colorpicker"], function (exports) {
    "use strict";
    var moduleName = 'labeledit', _layui = layui, laytpl = _layui.laytpl
        , $ = _layui.$, laydate = _layui.laydate, form = _layui.form, colorpicker = _layui.colorpicker;
    var configs = {
        elem: '',//组件
        editType: 'text',//组件编辑类型 text 文本输入 radio 单选 select 选择框 checkbox 单选框 date 日期选择框  time 时间选择框 color
        items: [
            { "id": "1", "text": "选择项1" },
            { "id": "2", "text": "选择项2" }
        ],
        value: { "id": "", "text": "" },
        savecallback: function (value, text) {
            return true;
        }
    };
    var showlable = function ($this, thiscfg) {
        $this.attr('lay-data', JSON.stringify(thiscfg));
        $this.empty();
        var context = '<div class="layui-form-label" style="text-align:left;"><span>' + thiscfg.value.text + '</span>';
        if (thiscfg.editType == 'color') {
            context += '<div class="layui-inline" style="width:26px;height:26px; margin-left:5px; background-color:' + thiscfg.value.text + ';"></div>';
        }
        context += '</div > <div class="layui-form-label" style="float:right;"><i class="layui-icon layui-icon-edit" title="修改" style="margin-left:5px;text-decoration:underline; cursor:grab;"></i></div>';
        $this.append(context);
        var divi = $this.find('i');
        divi.on('click', function () {
            showedit($this, thiscfg);
        });
    };
    var showedit = function ($this, thiscfg) {
        $this.empty();
        // var pwidth = $this.width();
        // var cwidth = pwidth - 130;
        var cwidth = 120;
        var context = '<div class="layui-inline layui-form" lay-filter="' + thiscfg.elem + '_eidtform" style="width:' + cwidth + 'px;">';
        if (thiscfg.editType == 'text') {
            context += '<input type="text" class="layui-input" value="' + thiscfg.value.text + '" />';
        }
        else if (thiscfg.editType == 'radio') {
            for (var i = 0; i < thiscfg.items.length; i++) {
                context += '<input type="radio" name="' + thiscfg.elem + '_radio" value="' + thiscfg.items[i].id + '" title="' + thiscfg.items[i].text + '"';
                if (thiscfg.items[i].id == thiscfg.value.id) {
                    context += ' checked';
                }
                context += ' />';
            }
        }
        else if (thiscfg.editType == 'select') {
            context += '<select class="layui-select">';
            for (var i = 0; i < thiscfg.items.length; i++) {
                context += '<option value="' + thiscfg.items[i].id + '" title="' + thiscfg.items[i].text + '" ';
                if (thiscfg.items[i].id == thiscfg.value.id) {
                    context += ' selected';
                }
                context += '>' + thiscfg.items[i].text + '</option>';
            }
            context += '</select>';
        }
        else if (thiscfg.editType == 'checkbox') {
            context += '<input type="checkbox" lay-skin="switch" value="' + thiscfg.items[1].id + '" lay-text="' + thiscfg.items[1].text + '|' + thiscfg.items[0].text + '" ';
            if (thiscfg.value.id == thiscfg.items[1].id) {
                context += ' checked';
            }
            context += '>';
        }
        else if (thiscfg.editType == 'date' || thiscfg.editType == 'time') {
            context += '<input type="text" class="layui-input" id="' + thiscfg.elem.replace('#', '') + '_date">';
        }
        else if (thiscfg.editType == 'color') {
            context += '<div id="' + thiscfg.elem.replace('#', '') + '_color"></div>';
        }
        else {
            throw new Error('不支持编辑类型');
        }
        context += '</div><div class="layui-inline" style="float:right;"><button type="button" class="layui-btn layui-btn-primary" title="保存" style="width:30px;padding:0px;"><i class="layui-icon layui-icon-ok" style="color:blue;"></i></button></div>';
        $this.append(context);
        form.render(null, thiscfg.elem + '_eidtform');
        if (thiscfg.editType == 'date') {
            laydate.render({
                elem: '#' + thiscfg.elem.replace('#', '') + '_date',
                type: 'date',
                format: 'yyyy-MM-dd',
                value: thiscfg.value.text
            });
        }
        else if (thiscfg.editType == 'time') {
            laydate.render({
                elem: '#' + thiscfg.elem.replace('#', '') + '_date',
                type: 'time',
                format: 'HH:mm',
                value: thiscfg.value.text
            });
        }
        else if (thiscfg.editType == 'color') {
            colorpicker.render({
                elem: '#' + thiscfg.elem.replace('#', '') + '_color',
                color: thiscfg.value.text,
                size: 'sm',
                done: function (color) {
                    thiscfg.tempvalue = color;
                }
            });
        }
        $this.find('button').on('click', function () {
            var nval = '';
            var ntext = '';
            if (thiscfg.editType == 'text' || thiscfg.editType == 'date' || thiscfg.editType == 'time') {
                nval = $this.find('input').val();
                ntext = nval;
            }
            else if (thiscfg.editType == 'radio') {
                var radios = $this.find('input[type="radio"]');
                for (var i = 0; i < radios.length; i++) {
                    if (radios[i].checked) {
                        nval = radios[i].value;
                        ntext = radios[i].title;
                        break;
                    }
                }
            }
            else if (thiscfg.editType == 'select') {
                //var curitem = $this.find("select").find("option:eq(0)").prop("selected", true);
                var opts = $this.find('select').find('option');
                for (var i = 0; i < opts.length; i++) {
                    if (opts[i].selected) {
                        nval = opts[i].value;
                        ntext = opts[i].title;
                        break;
                    }
                }
            }
            else if (thiscfg.editType == 'checkbox') {
                var chkbox = $this.find('input[type="checkbox"]');
                if (chkbox[0].checked) {
                    nval = thiscfg.items[1].id;
                    ntext = thiscfg.items[1].text;
                }
                else {
                    nval = thiscfg.items[0].id;
                    ntext = thiscfg.items[0].text;
                }
            }
            else if (thiscfg.editType == 'color') {
                nval = thiscfg.tempvalue;
                ntext = nval;
            }

            if (thiscfg.savecallback(nval, ntext)) {
                thiscfg.value.id = nval;
                thiscfg.value.text = ntext;
                showlable($this, thiscfg);
            }

        });
    };
    var active = {


        render: function (config) {
            //初始化配置项
            var thiscfg = {};
            if (config != null) {
                thiscfg.elem = config.elem != null ? config.elem : configs.elem;
                thiscfg.editType = config.editType != null ? config.editType : configs.editType;
                thiscfg.items = config.items != null ? config.items : configs.items;
                thiscfg.savecallback = config.savecallback != null ? config.savecallback : configs.savecallback;
                thiscfg.value = config.value != null ? config.value : configs.value;
            }
            else {
                thiscfg = configs;
            }
            var $this = $(thiscfg.elem);
            showlable($this, thiscfg);
        }
    };
    exports(moduleName, active);
});
