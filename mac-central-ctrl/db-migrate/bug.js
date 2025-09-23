use maccert

db.im_meta.updateOne({"Key":"SEND_FAILURE_SOTP"},{"$set":{"Key":"SEND_FAILURE_STOP"}});

db.cert_mbase.dropIndexes();
db.cert_mbase.createIndex({"Status":1,"IMRegTime":1})
db.cert_mbase.createIndex({"DispNum":-1,"DeviceBasic.CreateAt":1})

db.im_meta.insert({Key:"PROXY_SWITCH",Value:"1"})

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

//appleid_log
db.im_appleidlog.createIndex({"Email":1},{unique:true})