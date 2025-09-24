package common

import (
	"sync"
	"time"
)

type TimeoutMap struct {
	m      map[string]interface{} // 存储实际数据
	expMap map[string]int64       // 存储key的超时时间
	mutex  sync.RWMutex           // 读写锁，保证并发安全
}

func NewTimeoutMap() *TimeoutMap {
	tm := &TimeoutMap{
		m:      make(map[string]interface{}),
		expMap: make(map[string]int64),
		mutex:  sync.RWMutex{},
	}
	go tm.cleanUp() // 启动清理过期键值对的协程
	return tm
}

// 设置键值对，并指定过期时间（秒）
func (tm *TimeoutMap) Set(key string, value interface{}, timeout int64) {
	tm.mutex.Lock()
	defer tm.mutex.Unlock()
	expireTime := time.Now().Unix() + timeout
	tm.m[key] = value
	tm.expMap[key] = expireTime
}

// 获取键值对，并判断是否过期。如果过期则删除并返回空值。
func (tm *TimeoutMap) Get(key string) interface{} {
	tm.mutex.RLock()
	defer tm.mutex.RUnlock()
	if val, ok := tm.m[key]; ok {
		if expireTime, ok := tm.expMap[key]; !ok || expireTime < time.Now().Unix() {
			delete(tm.m, key)
			delete(tm.expMap, key)
			return nil
		} else {
			return val
		}
	} else {
		return nil
	}
}

// 清理过期键值对的协程
func (tm *TimeoutMap) cleanUp() {
	for {
		<-time.After(1 * time.Second) // 每秒检查一次
		now := time.Now().Unix()
		keysToDelete := []string{}
		tm.mutex.Lock()
		for key, expTime := range tm.expMap {
			if expTime < now { // 如果已经过期，则记录需要删除的key
				keysToDelete = append(keysToDelete, key)
			}
		}
		// 删除需要删除的key
		for _, key := range keysToDelete {
			delete(tm.m, key)
			delete(tm.expMap, key)
		}
		tm.mutex.Unlock()
	}
}

func (tm *TimeoutMap) Delete(key string) {
	tm.mutex.RLock()
	defer tm.mutex.RUnlock()
	delete(tm.m, key)
	delete(tm.expMap, key)
}

func (tm *TimeoutMap) AllKeys() []string {
	tm.mutex.RLock()
	defer tm.mutex.RUnlock()
	keys := []string{}
	for key, _ := range tm.m {
		keys = append(keys, key)
	}
	return keys
}
