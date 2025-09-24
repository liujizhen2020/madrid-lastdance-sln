use maccert

db.dropDatabase()

db.user.createIndex({"Username":1},{unique:true})
db.user.insert({Username:"admin",Password:"6N4ChUOrHC08LGnFKRv3hg==",FailNum:0})

db.im_macro.createIndex({"MsgId":1,"MacroValue":1},{unique:true})
db.im_macro.createIndex({"Identifier":1},{unique:true})

db.device_mbase.createIndex({"DeviceBasic.SN":1},{unique:true})
db.device_mbase.createIndex({"Status":1})

db.cert_mbase.createIndex({"DeviceBasic.SN":1},{unique:true})
db.cert_mbase.createIndex({"Status":1,"IMRegTime":1})

db.appleid_0.createIndex({"Email":1},{unique:true})
db.appleid_1.createIndex({"Email":1},{unique:true})
db.appleid_100.createIndex({"Email":1},{unique:true})
db.appleid_1.ensureIndex({"CreateAt":1,"DispNum":1})


db.im_meta.insert({Key:"CK_DISPATCH_INTERVAL",Value:"48"})
db.im_meta.insert({Key:"CK_REDISPATCH_INTERVAL",Value:"48"})
db.im_meta.insert({Key:"CK_REDISPATCH_NUM",Value:"3"})

db.im_meta.insert({Key:"SEND_MSG_INTERVAL",Value:"1"})
db.im_meta.insert({Key:"SEND_WAIT_AFTERSEND",Value:"30"})
db.im_meta.insert({Key:"SEND_FAILURE_STOP",Value:"5"})

db.im_meta.insert({Key:"PHONE_NUM_FETCHED_DEFAULT",Value:"50"})

db.im_meta.insert({Key:"CERTEXTRACT_SWITCH",Value:"1"})
db.im_meta.insert({Key:"CERTWORK_SWITCH",Value:"1"})

db.im_meta.insert({Key:"PHONE_RECYCLE_INTERVAL",Value:"6"});
db.im_meta.insert({Key:"APPLEID_RECYCLE_INTERVAL",Value:"6"});
db.im_meta.insert({Key:"MACCODE_RECYCLE_INTERVAL",Value:"6"});

db.im_meta.insert({Key:"RECYCLE_NUM_PHONE",Value:"3"})
db.im_meta.insert({Key:"RECYCLE_NUM_APPLEID",Value:"5"})

db.im_meta.insert({Key:"MACCODE_EXPIRE_INTERVAL",Value:"6"});

db.im_meta.createIndex({"Key":1},{unique:true})

db.im_meta.updateOne({Key:"SYSTEM_SWITCH"},{$set:{Key:"CERTEXTRACT_SWITCH"}})
db.im_meta.insert({Key:"EMULATOR_SWITCH",Value:"1"})


db.im_meta.updateOne({"Key":"SEND_FAILURE_SOTP"},{"$set":{"Key":"SEND_FAILURE_STOP"}});

db.cert_mbase.dropIndexes();
db.cert_mbase.createIndex({"Status":1,"IMRegTime":1})
db.cert_mbase.createIndex({"DispNum":-1,"DeviceBasic.CreateAt":1})

db.ipproxy.createIndex({"CreateAt": 1},{expireAfterSeconds: 180})

//2024.2.2

db.im_meta.insert({Key:"TRAILER_NUM_APPLEID",Value:"3"})
db.im_meta.insert({Key:"TRAILER_SWITCH",Value:"1"});
db.cert_mbase.dropIndexes();
db.cert_mbase.createIndex({"IMRegTime":1,"Status":1})

//2024.3.37
db.appleid_tag.createIndex({"Tag":1},{unique:true})

//2024.3.28
db.cert_mbase.dropIndexes()
db.cert_mbase.createIndex({"DeviceBasic.SN":1})
db.cert_mbase.createIndex({"IMEmail":1,"Status":1})
db.cert_mbase.createIndex({"CtrlTime":1,"Status":1})
db.maccode_mbase.createIndex({"DeviceBasic.ROM":1})
