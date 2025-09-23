package models

import (
	"errors"
)

var (
	_questionMapping = make(map[string]string)
)

func init() {
	_questionMapping["130"] = "你少年时代最好的朋友叫什么名字？"
	_questionMapping["131"] = "你的第一个宠物叫什么名字？"
	_questionMapping["132"] = "你学会做的第一道菜是什么？"
	_questionMapping["133"] = "你第一次去电影院看的是哪一部电影？"
	_questionMapping["134"] = "你第一次坐飞机是去哪里？"
	_questionMapping["135"] = "你上小学时最喜欢的老师姓什么？"

	_questionMapping["136"] = "你的理想工作是什么？"
	_questionMapping["137"] = "你小时候最喜欢哪一本书？"
	_questionMapping["138"] = "你拥有的第一辆车是什么型号？"
	_questionMapping["139"] = "你童年时代的绰号是什么？"
	_questionMapping["140"] = "你在学生时代最喜欢哪个电影明星或角色？"
	_questionMapping["141"] = "你在学生时代最喜欢哪个歌手或乐队？"

	_questionMapping["142"] = "你的父母是在哪里认识的？"
	_questionMapping["143"] = "你的第一个上司叫什么名字？"
	_questionMapping["144"] = "您从小长大的那条街叫什么？"
	_questionMapping["145"] = "你去过的第一个海滨浴场是哪一个？"
	_questionMapping["146"] = "你购买的第一张专辑是什么？"
	_questionMapping["147"] = "您最喜欢哪个球队？"

}

func GetQuestionID(in string) (string, error) {
	for k, v := range _questionMapping {
		if k == in || v == in {
			return k, nil
		}
	}
	return "", errors.New("Not Matched Question")
}
