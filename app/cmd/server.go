package main

import (
	"fmt"

	uuid "github.com/samsonannan/utili/pkg/model"
)

func main() {
	// u := model.UserModel{Name: "Gerald", Email: "gerald@yahoo.com"}
	u := uuid.PhoneModel{Phone: "0204248210", Address: "GA-3480-1834"}
	fmt.Printf("%+v", u)
}
