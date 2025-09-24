package bussiness

import (
	"time"
)

var (
	formatter = "2006-01-02 15:04:05"
)

func nowTimeStr() string {
	now_time := time.Now()
	return now_time.Format(formatter)
}

func timeForOffset(dur string) time.Time {
	_dur, _ := time.ParseDuration(dur)
	_offeseted := time.Now().Add(_dur)
	return _offeseted
}

func fmt2Str(t time.Time) string {
	return time.Unix(t.Unix(), 0).Format(formatter)
}

func getHourInterval(e_t time.Time, l_t time.Time) int64 {
	time_stamp_diff := l_t.Unix() - e_t.Unix()
	hour_diff := time_stamp_diff / 3600
	return hour_diff
}
