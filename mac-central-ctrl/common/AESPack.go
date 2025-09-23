package common

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
)

type AesCrypt struct {
	Key []byte
	Iv  []byte
}

func (a *AesCrypt) Encrypt(data []byte) ([]byte, error) {
	aesBlockEncrypt, err := aes.NewCipher(a.Key)
	if err != nil {
		println(err.Error())
		return nil, err
	}

	content := pKCS5Padding(data, aesBlockEncrypt.BlockSize())
	cipherBytes := make([]byte, len(content))
	aesEncrypt := cipher.NewCBCEncrypter(aesBlockEncrypt, a.Iv)
	aesEncrypt.CryptBlocks(cipherBytes, content)
	return cipherBytes, nil
}

func (a *AesCrypt) Decrypt(src []byte) (data []byte, err error) {
	decrypted := make([]byte, len(src))
	var aesBlockDecrypt cipher.Block
	aesBlockDecrypt, err = aes.NewCipher(a.Key)
	if err != nil {
		println(err.Error())
		return nil, err
	}
	aesDecrypt := cipher.NewCBCDecrypter(aesBlockDecrypt, a.Iv)
	aesDecrypt.CryptBlocks(decrypted, src)
	return pKCS5Trimming(decrypted), nil
}

func pKCS5Padding(cipherText []byte, blockSize int) []byte {
	padding := blockSize - len(cipherText)%blockSize
	padText := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(cipherText, padText...)
}

func pKCS5Trimming(encrypt []byte) []byte {
	padding := encrypt[len(encrypt)-1]
	return encrypt[:len(encrypt)-int(padding)]
}

func AesBaseEncryptObject(data []byte) ([]byte, error) {
	var aesCrypt = AesCrypt{
		Key: []byte("ABCDEFGHIJKLMNOP"),
		Iv:  []byte{0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0},
	}
	return aesCrypt.Encrypt(data)
}

func AesBaseDecryptObject(data []byte) ([]byte, error) {
	var aesCrypt = AesCrypt{
		Key: []byte("ABCDEFGHIJKLMNOP"),
		Iv:  []byte{0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0},
	}
	return aesCrypt.Decrypt(data)
}

func EncryptPackage(rowData interface{}) (string, error) {
	var origData []byte
	switch rowData.(type) {
	case string:
		origData = []byte(rowData.(string))
	default:
		origData, _ = json.Marshal(rowData)
	}
	if origData == nil {
		return "", errors.New(fmt.Sprintf("orig data error"))
	}
	encData, err := AesBaseEncryptObject(origData)
	if err != nil {
		return "", errors.New(fmt.Sprintf("encrypt data error[%s]", err.Error()))
	}
	pack64 := base64.StdEncoding.EncodeToString(encData)
	return pack64, nil
}

func EncryptIMPackage(brightObject interface{}) (interface{}, error) {
	return brightObject, nil
}
