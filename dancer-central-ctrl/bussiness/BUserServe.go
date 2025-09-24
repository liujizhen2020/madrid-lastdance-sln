package bussiness

import (
	"dancer-central-ctrl/common"
	"dancer-central-ctrl/entities"
	"dancer-central-ctrl/mongoc"
	"errors"
	"go.mongodb.org/mongo-driver/bson"
	"time"
)

const (
	ACCOUNT_LOGINOK = 100
	ACCOUNT_LOCKED  = 409
	ACCOUNT_PWDERR  = 401
	ACCOUNT_NOEXIST = 405
	SYSTEM_ERROR    = 406
)

var (
	BUSER_SERVE = &BUserServe{}
	user_mbase  = mongoc.NewMongoColl("user", 20*time.Second)
)

type BUserServe struct {
}

func (s *BUserServe) UserLogin(username string, password string) (int, error) {
	user, err := s.QueryByUsername(username)
	if err != nil {
		return ACCOUNT_NOEXIST, err
	}
	if user.FailNum >= 5 {
		return ACCOUNT_LOCKED, errors.New("账号已被锁定")
	}
	enc_p, err := common.EncryptPackage(password)
	if err != nil {
		return SYSTEM_ERROR, errors.New("系统错误")
	}
	if user.Password != enc_p {
		return ACCOUNT_PWDERR, errors.New("密码错误")
	}
	s.ZeroFailNum(username)
	return ACCOUNT_LOGINOK, nil
}

func (s *BUserServe) QueryByUsername(username string) (entities.User, error) {
	var user entities.User
	err := user_mbase.FindOne(bson.M{"Username": username}, &user)
	if err != nil {
		return entities.User{}, err
	}
	return user, nil
}

func (s *BUserServe) IncFailNum(username string) error {
	var user entities.User
	err := user_mbase.FindOne(bson.M{"Username": username}, &user)
	if err != nil {
		return err
	}
	return user_mbase.UpdateOne(bson.M{"Username": username}, bson.M{"$set": bson.M{"FailNum": user.FailNum + 1}})
}

func (s *BUserServe) ZeroFailNum(username string) error {
	var user entities.User
	err := user_mbase.FindOne(bson.M{"Username": username}, &user)
	if err != nil {
		return err
	}
	return user_mbase.UpdateOne(bson.M{"Username": username}, bson.M{"$set": bson.M{"FailNum": int64(0)}})
}
