package models

const (
	X_AccountFatal = -1
	X_AccountFree  = 0
	X_AccountLogin = 1
	X_IMReady      = 100

	S_MacFree      = 0
	S_MacInitilize = 1
	S_MacReady     = 10
	S_MacIMReg     = 11
	S_MacIMReady   = 100

	S_CertReady   = 200
	S_CertWorking = 201
	S_CertWorked  = 1000

	S_MacInitFatal = -10
	S_IMRegFatal   = -100
	S_CertFatal    = -1000

	X_PhoneNotApple = -1
	X_PhoneFree     = 0
	X_PhoneWorking  = 1
	X_PhoneSent     = 100
)
