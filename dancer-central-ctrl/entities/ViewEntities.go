package entities

type IMMacroView struct {
	IMMacro
	Index       int
	IsUsing     bool
	UpdateAtStr string
}
type PhoneStatus struct {
	Free    int64
	Working int64
	Succ    int64
}

type IMessageView struct {
	IMessage
	PhoneStatus
	Index       int
	StatusAlias string
}
