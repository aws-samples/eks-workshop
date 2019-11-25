package main

import (
	"encoding/json"
	"io"
	"math/rand"
	"net/http"
	"time"

	_ "github.com/aws/aws-xray-sdk-go/plugins/ec2"
	_ "github.com/aws/aws-xray-sdk-go/plugins/ecs"
	"github.com/aws/aws-xray-sdk-go/xray"
)

const appName = "x-ray-sample-back-k8s"

func init() {
	xray.Configure(xray.Config{
		DaemonAddr:     "xray-service.default:2000",
		LogLevel:       "info",
	})
}

func main() {

	http.Handle("/", xray.Handler(xray.NewFixedSegmentNamer(appName), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		slow := param(r, "slow", "false")

		res := &response{Message: "42 - The Answer to the Ultimate Question of Life, The Universe, and Everything.", Random: []int{}}

		count := time.Now().Second()
		gen := random(res)

		_, seg := xray.BeginSubsegment(r.Context(), appName + "-gen")

		for i := 0; i < count; i++ {
			gen()
			if slow == "true" {
				time.Sleep(10 * time.Millisecond)
			}
		}

		seg.Close(nil)

		// Beautify the JSON output - only for display
		out, _ := json.MarshalIndent(res, "", "  ")

		w.Header().Set("Content-Type", "application/json")
		io.WriteString(w, string(out))

	})))
	http.ListenAndServe(":8080", nil)
}

func param(r *http.Request, name, base string) string {
	if vars, ok := r.URL.Query()[name]; ok && len(vars) > 0 && len(vars[0]) > 0 {
		return vars[0]
	}
	return base
}

type response struct {
	Message string `json:"message"`
	Random  []int  `json:"random"`
}

func random(res *response) func() {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	return func() {
		res.Random = append(res.Random, r.Intn(42))
	}
}
