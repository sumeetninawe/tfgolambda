/*
Basic Golang code to handle Lambda function trigger events.

https://letsdotech.dev
*/
package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"name"`
}

func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	//Code

	return fmt.Sprintf("Hello from Lambda by LDT!"), nil
}

func main() {
	lambda.Start(HandleRequest)
}
