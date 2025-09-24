package mongoc

import (
	"context"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/x/bsonx"
	"time"
)

type MongoColl struct {
	name    string
	mcoll   *mongo.Collection
	timeout time.Duration
}

func NewMongoColl(collname string, timeout time.Duration) *MongoColl {
	_, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	collRef := _database.Collection(collname)
	return &MongoColl{name: collname, mcoll: collRef, timeout: timeout}
}

func (self *MongoColl) PushOne(doc interface{}, opts ...*options.InsertOneOptions) error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	_, err := self.mcoll.InsertOne(ctx, doc, opts...)
	return err
}

func (self *MongoColl) DocumentSize(filter interface{}, opts ...*options.CountOptions) (int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	return self.mcoll.CountDocuments(ctx, filter, opts...)
}

func (self *MongoColl) EstimatedSize() (int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	return self.mcoll.EstimatedDocumentCount(ctx)
}

func (self *MongoColl) PopOne(filter interface{}, objPtr interface{}, opts ...*options.FindOneAndDeleteOptions) error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	result := self.mcoll.FindOneAndDelete(ctx, filter, opts...)
	return result.Decode(objPtr)
}

func (self *MongoColl) Find(filter interface{}, slicePtr interface{}, opts ...*options.FindOptions) error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	cur, err := self.mcoll.Find(ctx, filter, opts...)
	if err != nil {
		return err
	}
	return cur.All(ctx, slicePtr)
}

func (self *MongoColl) FindOne(filter interface{}, objPtr interface{}, opts ...*options.FindOneOptions) error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	result := self.mcoll.FindOne(ctx, filter, opts...)
	return result.Decode(objPtr)
}

func (self *MongoColl) UpdateOne(filter interface{}, update interface{}, opts ...*options.UpdateOptions) error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	_, err := self.mcoll.UpdateOne(ctx, filter, update, opts...)
	return err
}

func (self *MongoColl) DeleteOne(filter interface{}, opts ...*options.DeleteOptions) error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	_, err := self.mcoll.DeleteOne(ctx, filter, opts...)
	return err
}

func (self *MongoColl) UpdateMany(filter interface{}, update interface{}, opts ...*options.UpdateOptions) (int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	result, err := self.mcoll.UpdateMany(ctx, filter, update, opts...)
	return result.ModifiedCount, err
}

func (self *MongoColl) DeleteMany(filter interface{}, opts ...*options.DeleteOptions) (int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	result, err := self.mcoll.DeleteMany(ctx, filter, opts...)
	return result.DeletedCount, err
}

func (self *MongoColl) Aggregate(pipeline interface{}, slicePtr interface{}, opts ...*options.AggregateOptions) error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	cur, err := self.mcoll.Aggregate(ctx, pipeline, opts...)
	if err != nil {
		return err
	}
	return cur.All(ctx, slicePtr)
}

func (self *MongoColl) Destory() error {
	ctx, cancel := context.WithTimeout(context.Background(), self.timeout)
	defer cancel()
	return self.mcoll.Drop(ctx)
}

func (self *MongoColl) CreateIndex(idxModel mongo.IndexModel) error {
	_, err := self.mcoll.Indexes().CreateOne(context.Background(), idxModel)
	return err
}

type MongoExpirableColl struct {
	MongoColl
	expireSecond int32
	expireCol    string
}

func NewMongoExpirableColl(collname string, timeout time.Duration, expireSecond int32, expireCol string, ukey string) *MongoExpirableColl {
	_, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	collRef := _database.Collection(collname)
	ret := &MongoExpirableColl{MongoColl: MongoColl{name: collname, mcoll: collRef, timeout: timeout}, expireSecond: expireSecond, expireCol: expireCol}
	if ukey != "" {
		ret.CreateIndex(mongo.IndexModel{
			Keys:    bsonx.Doc{{ukey, bsonx.Int32(1)}},
			Options: options.Index().SetUnique(true),
		})
	}
	return ret
}

func (self *MongoExpirableColl) RegisterExpirable() error {
	idx := mongo.IndexModel{
		Keys:    bsonx.Doc{{self.expireCol, bsonx.Int32(1)}},
		Options: options.Index().SetExpireAfterSeconds(self.expireSecond),
	}
	return self.CreateIndex(idx)
}

type MongoFIFOColl struct {
	MongoColl
	capacity int64
}

func NewMongoFIFOColl(collname string, timeout time.Duration, capacity int64) *MongoFIFOColl {
	_, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	collRef := _database.Collection(collname)
	return &MongoFIFOColl{MongoColl: MongoColl{name: collname, mcoll: collRef, timeout: timeout}, capacity: capacity}
}

func (self *MongoFIFOColl) FIFOPushOne(in interface{}, out interface{}) error {
	err := self.PushOne(in)
	if err != nil {
		return err
	}
	size, err := self.EstimatedSize()
	if err == nil && size > self.capacity {
		err = self.PopOne(bson.M{}, out)
	}
	return nil
}
