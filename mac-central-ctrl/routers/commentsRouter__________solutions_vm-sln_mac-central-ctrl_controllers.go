package routers

import (
	"github.com/astaxie/beego"
	"github.com/astaxie/beego/context/param"
)

func init() {

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "InitTag",
            Router: "/appleId/initTag",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "SaveTagInterval",
            Router: "/appleId/saveTagInterval",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "Tag",
            Router: "/appleId/tag",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "TagData",
            Router: "/appleId/tagData",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "TagDel",
            Router: "/appleId/tagDel",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "DisabledStatus",
            Router: "/id/disabledStatus",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "DoImport",
            Router: "/id/doImport",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "Export",
            Router: "/id/export",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "Fetch",
            Router: "/id/fetch",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "ToImport",
            Router: "/id/toImport",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AppleIdController"],
        beego.ControllerComments{
            Method: "Truncate",
            Router: "/id/truncate",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AuthorizationController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AuthorizationController"],
        beego.ControllerComments{
            Method: "DoLogin",
            Router: "/auth/doLogin",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:AuthorizationController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:AuthorizationController"],
        beego.ControllerComments{
            Method: "ToLogin",
            Router: "/auth/toLogin",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:DefaultController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:DefaultController"],
        beego.ControllerComments{
            Method: "Get",
            Router: "/",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMController"],
        beego.ControllerComments{
            Method: "Task",
            Router: "/im/task",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMController"],
        beego.ControllerComments{
            Method: "TaskData",
            Router: "/im/taskData",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"],
        beego.ControllerComments{
            Method: "Delete",
            Router: "/macro/delete",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"],
        beego.ControllerComments{
            Method: "DoImport",
            Router: "/macro/doImport",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"],
        beego.ControllerComments{
            Method: "Export",
            Router: "/macro/export",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"],
        beego.ControllerComments{
            Method: "ResetStatus",
            Router: "/macro/resetStatus",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"],
        beego.ControllerComments{
            Method: "Status",
            Router: "/macro/status",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"],
        beego.ControllerComments{
            Method: "ToMain",
            Router: "/macro/toMain",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IMMacroController"],
        beego.ControllerComments{
            Method: "Truncate",
            Router: "/macro/truncate",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IPProxyController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IPProxyController"],
        beego.ControllerComments{
            Method: "Put",
            Router: "/ipproxy/put",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IPProxyController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IPProxyController"],
        beego.ControllerComments{
            Method: "Sync",
            Router: "/ipproxy/sync",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"],
        beego.ControllerComments{
            Method: "BatchBindingCert",
            Router: "/imexport/batchBindingCert",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"],
        beego.ControllerComments{
            Method: "ExportHistory",
            Router: "/imexport/batchExportHistory",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"],
        beego.ControllerComments{
            Method: "ExportTask",
            Router: "/imexport/exportTask",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImExportController"],
        beego.ControllerComments{
            Method: "ReBatchExport",
            Router: "/imexport/reBatchExport",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImLogController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImLogController"],
        beego.ControllerComments{
            Method: "AppleIdLog",
            Router: "/imlog/appleIdLog",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImLogController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImLogController"],
        beego.ControllerComments{
            Method: "SerialLog",
            Router: "/imlog/serialLog",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"],
        beego.ControllerComments{
            Method: "PullMultiTask",
            Router: "/imessage/pullMultiTask",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"],
        beego.ControllerComments{
            Method: "PushTaskStatus",
            Router: "/imessage/pushTaskStatus",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"],
        beego.ControllerComments{
            Method: "SaveItemMeta",
            Router: "/imessage/saveItemMeta",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"],
        beego.ControllerComments{
            Method: "SwitchStatus",
            Router: "/imessage/switchStatus",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ImessageController"],
        beego.ControllerComments{
            Method: "InitializeNewTask",
            Router: "/imessage/taskInit",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:IndexController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:IndexController"],
        beego.ControllerComments{
            Method: "Index",
            Router: "/index",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "Cert",
            Router: "/macCode/cert",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "CertData",
            Router: "/macCode/certData",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "DoImport",
            Router: "/macCode/doImport",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "Export",
            Router: "/macCode/export",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "Fetch",
            Router: "/macCode/fetch",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "FindByROM",
            Router: "/macCode/findByROM",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "IMRegFatal",
            Router: "/macCode/imRegFatal",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "MacFatalByROM",
            Router: "/macCode/macFatalByROM",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "MacSuccByROM",
            Router: "/macCode/macSuccByROM",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "RegisterSuccess",
            Router: "/macCode/registerSuccess",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "ToImport",
            Router: "/macCode/toImport",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MacCodeController"],
        beego.ControllerComments{
            Method: "Truncate",
            Router: "/macCode/truncate",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"],
        beego.ControllerComments{
            Method: "DoAddText",
            Router: "/msgedit/doAddText",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"],
        beego.ControllerComments{
            Method: "DoDelete",
            Router: "/msgedit/doDelete",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"],
        beego.ControllerComments{
            Method: "DoEditText",
            Router: "/msgedit/doEditText",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"],
        beego.ControllerComments{
            Method: "ToAddText",
            Router: "/msgedit/toAddText",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:MsgEditController"],
        beego.ControllerComments{
            Method: "ToEditText",
            Router: "/msgedit/toEditText",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:PhoneNoController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:PhoneNoController"],
        beego.ControllerComments{
            Method: "DoImport",
            Router: "/phoneNo/doImport",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:PhoneNoController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:PhoneNoController"],
        beego.ControllerComments{
            Method: "ToImport",
            Router: "/phoneNo/toImport",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:PhoneNoController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:PhoneNoController"],
        beego.ControllerComments{
            Method: "Truncate",
            Router: "/phoneNo/truncate",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"],
        beego.ControllerComments{
            Method: "Discard",
            Router: "/serverNode/discard",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"],
        beego.ControllerComments{
            Method: "HeartBeat",
            Router: "/serverNode/heartBeat",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"],
        beego.ControllerComments{
            Method: "List",
            Router: "/serverNode/list",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"],
        beego.ControllerComments{
            Method: "ListData",
            Router: "/serverNode/listData",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:ServerNodeController"],
        beego.ControllerComments{
            Method: "SyncCMD",
            Router: "/serverNode/syncCMD",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:SpecialSendController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:SpecialSendController"],
        beego.ControllerComments{
            Method: "Apply",
            Router: "/specialSend/apply",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:SpecialSendController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:SpecialSendController"],
        beego.ControllerComments{
            Method: "ToConfig",
            Router: "/specialSend/toConfig",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:SystemMetaController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:SystemMetaController"],
        beego.ControllerComments{
            Method: "GetAll",
            Router: "/systemMeta/getMap",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:SystemMetaController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:SystemMetaController"],
        beego.ControllerComments{
            Method: "SaveConfig",
            Router: "/systemMeta/saveConfig",
            AllowHTTPMethods: []string{"post"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

    beego.GlobalControllerRouter["mac-central-ctrl/controllers:SystemMetaController"] = append(beego.GlobalControllerRouter["mac-central-ctrl/controllers:SystemMetaController"],
        beego.ControllerComments{
            Method: "ToConfig",
            Router: "/systemMeta/toConfig",
            AllowHTTPMethods: []string{"get"},
            MethodParams: param.Make(),
            Filters: nil,
            Params: nil})

}
