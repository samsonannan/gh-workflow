package main

import (
	"fmt"

	uuid "github.com/samsonannan/addon/pkg/models"
)

func main() {
	// u := model.UserModel{Name: "Gerald", Email: "gerald@yahoo.com"}
	u := uuid.UserModel{Name: "Gerald", Email: "geramd@yahoo.com"}
	fmt.Printf("%+v", u)
}
