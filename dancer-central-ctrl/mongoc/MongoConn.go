package mongoc

import (
	"context"
	mycfg "dancer-central-ctrl/extcfg"
	"fmt"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

var (
	_database = initDatabase(mycfg.GetMongoURL(), mycfg.GetMongoBD(), 20*time.Second)
)

func initDatabase(url string, dbname string, timeout time.Duration) *mongo.Database {
	_client, err := mongo.NewClient(options.Client().ApplyURI(fmt.Sprintf("mongodb://%s", url)))
	if err != nil {
		panic(fmt.Sprintf("mongo init err:%s", err.Error()))
	}
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	err = _client.Connect(ctx)
	if err != nil {
		panic(fmt.Sprintf("mongo connect err:%s", err.Error()))
	}
	return _client.Database(dbname)
}
