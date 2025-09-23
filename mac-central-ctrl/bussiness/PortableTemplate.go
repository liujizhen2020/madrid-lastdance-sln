package bussiness

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"io"
	"mac-central-ctrl/mongoc"
	"mime/multipart"
	"reflect"
	"strings"
	"time"
)

type Portable interface {
	ImportParse(line string) (interface{}, error)
	ExportWrite(writer *csv.Writer, entity interface{}) error
}

type PortableTemplate struct {
	Impl Portable
}

func (t *PortableTemplate) LineImport(coll *mongoc.MongoColl, file multipart.File) int64 {
	affected := int64(0)
	buff := bufio.NewReader(file) //读入缓存
	for {
		aline, err := buff.ReadString('\n') //以'\n'为结束符读入一行
		if err != nil && io.EOF != err {
			break
		}
		if strings.TrimSpace(aline) != "" {
			aline = strings.Replace(aline, "\n", "", -1)
			aline = strings.Replace(aline, "\r", "", -1)
			e, err := t.Impl.ImportParse(aline)
			if err != nil {
				continue
			}
			err = coll.PushOne(e)
			if err == nil {
				affected++
			}
		}
		if io.EOF == err {
			break
		}
	}
	return affected
}

func (t *PortableTemplate) StringImport(coll *mongoc.MongoColl, body string) int64 {
	affected := int64(0)
	body = strings.Replace(body, "\n", "\r", -1)
	p_list := strings.Split(body, "\r")
	for _, line := range p_list {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		line = strings.Replace(line, "\n", "", -1)
		line = strings.Replace(line, "\r", "", -1)
		e, err := t.Impl.ImportParse(line)
		if err != nil {
			continue
		}
		err = coll.PushOne(e)
		if err == nil {
			affected++
		}
	}
	return affected
}

func (t *PortableTemplate) LineExport(coll *mongoc.MongoColl, writer *csv.Writer, filter interface{}, slicePtr interface{}) int64 {
	err := coll.Find(filter, slicePtr)
	lineCount := int64(0)
	if err == nil {
		resultsVal := reflect.ValueOf(slicePtr).Elem()
		if resultsVal.Kind() == reflect.Slice {
			l := resultsVal.Len()
			for i := 0; i < l; i++ {
				entity := resultsVal.Index(i).Interface()
				t.Impl.ExportWrite(writer, entity)
				lineCount++
			}
		} else {
			fmt.Println("parameter slicePtr is not a pointer to slice")
		}
	}
	writer.Write([]string{})
	writer.Flush()
	return lineCount
}

func (t *PortableTemplate) CollectionPorter(from *mongoc.MongoColl, to *mongoc.MongoColl, filter interface{}, valPtr interface{}, field string, bsonpath string) (int64, error) {
	concreteType := reflect.TypeOf(reflect.ValueOf(valPtr).Elem().Interface())
	slice := reflect.MakeSlice(reflect.SliceOf(concreteType), 0, 0)
	slicePtr := reflect.New(slice.Type()).Interface()
	err := from.Find(filter, slicePtr)
	if err != nil {
		fmt.Println("Porter Got Error:", err.Error())
	}
	lineCount := int64(0)
	if err == nil {
		resultsVal := reflect.ValueOf(slicePtr).Elem()
		if resultsVal.Kind() == reflect.Slice {
			l := resultsVal.Len()
			for i := 0; i < l; i++ {
				rval := resultsVal.Index(i)
				uval := rval.FieldByName(field).Interface()
				err := from.PopOne(bson.M{fmt.Sprintf("%s%s", bsonpath, field): uval}, valPtr)
				if err == nil {
					cf := reflect.ValueOf(valPtr).Elem().FieldByName("CreateAt")
					cf.Set(reflect.ValueOf(time.Now()))
					targetVal := reflect.ValueOf(valPtr).Elem().Interface()
					to.PushOne(targetVal)
					lineCount++
				}
			}
		} else {
			fmt.Println("parameter slicePtr is not a pointer to slice")
		}
	}
	return lineCount, nil
}
