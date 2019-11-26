package main

import (
	"io"
	"net/http"
	"golang.org/x/net/context/ctxhttp"
	"fmt"
	"io/ioutil"
	"time"
	"errors"
	"strconv"

	_ "github.com/aws/aws-xray-sdk-go/plugins/ec2"
	_ "github.com/aws/aws-xray-sdk-go/plugins/ecs"
	"github.com/aws/aws-xray-sdk-go/xray"
)

func init() {
	xray.Configure(xray.Config{
		DaemonAddr:     "xray-service.default:2000",
		LogLevel:       "info",
	})
}

var tr = &http.Transport{
	MaxIdleConns: 20,
	IdleConnTimeout: 30 * time.Second,
}

func main() {

	http.Handle("/api", xray.Handler(xray.NewFixedSegmentNamer("x-ray-sample-front-k8s"), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		slow := param(r, "slow", "false")
		repeat := param(r, "repeat", "false")

		count := 1
		if repeat == "true" {
			count = 20
		}

		for idx := 0; idx < count; idx++ {
			if resp, err := backend(r, slow); err == nil {
				io.WriteString(w, fmt.Sprintf("%s<br>", resp))
			} else {
				io.WriteString(w, fmt.Sprintf("Unable to make request to: http://x-ray-sample-back-k8s.default.svc.cluster.local: %v<br>", err))
			}
		}
	})))

	// Write the landing page
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "text/html")
			io.WriteString(w, html)
	})

	http.ListenAndServe(":8080", nil)
}

func backend(r *http.Request, slow string) (string, error) {
	resp, err := ctxhttp.Get(
		r.Context(),
		xray.Client(&http.Client{Transport: tr}),
		fmt.Sprintf("http://x-ray-sample-back-k8s.default.svc.cluster.local?slow=%s", slow),
	)

	if err != nil {
		return "", err
	}

	defer resp.Body.Close()

	if resp.StatusCode == http.StatusOK {
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return "", err
		}
		return string(body), nil
	} else {
		return "", errors.New(fmt.Sprintf("Bad backend request - http status: %s", strconv.Itoa(resp.StatusCode)))
	}
}

func param(r *http.Request, name, base string) string {
	if vars, ok := r.URL.Query()[name]; ok && len(vars) > 0 && len(vars[0]) > 0 {
		return vars[0]
	}
	return base
}

var html = `<!DOCTYPE HTML><html>
<head><style>body { background-color: #000000; color: #00FF00; }</style></head>
<body><br><br>
<div style="display: block; margin: auto; width: 580px;">
<pre>
                          oooo$$$$$$$$$$$$oooo
                      oo$$$$$$$$$$$$$$$$$$$$$$$$o
                   oo$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$o         o$   $$ o$
   o $ oo        o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$o       $$ $$ $$o$
oo $ $ "$      o$$$$$$$$$    $$$$$$$$$$$$$    $$$$$$$$$o       $$$o$$o$
"$$$$$$o$     o$$$$$$$$$      $$$$$$$$$$$      $$$$$$$$$$o    $$$$$$$$
  $$$$$$$    $$$$$$$$$$$      $$$$$$$$$$$      $$$$$$$$$$$$$$$$$$$$$$$
  $$$$$$$$$$$$$$$$$$$$$$$    $$$$$$$$$$$$$    $$$$$$$$$$$$$$  """$$$
   "$$$""""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     "$$$
    $$$   o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     "$$$o
   o$$"   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$       $$$o
   $$$    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$""$$$$$$ooooo$$$$o
  o$$$oooo$$$$$  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  o$$$$$$$$$$$$$$$$$
  $$$$$$$$"$$$$   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     $$$$""""""""
 """"       $$$$    "$$$$$$$$$$$$$$$$$$$$$$$$$$$$"      o$$$
            "$$$o     """$$$$$$$$$$$$$$$$$$"$$"         $$$
              $$$o          "$$""$$$$$$""""           o$$$
               $$$$o                                o$$$"
                "$$$$o      o$$$$$$o"$$$$o        o$$$$
                  "$$$$$oo     ""$$$$o$$$$$o   o$$$$""
                     ""$$$$$oooo  "$$$o$$$$$$$$$"""
                        ""$$$$$$$oo $$$$$$$$$$
                                """"$$$$$$$$$$$
                                    $$$$$$$$$$$$
                                     $$$$$$$$$$"
                                      "$$$""""
</pre>
<br><br>
<div id="api-response">
</div>
<script>
function get() {
	var url = new URL(window.location.href);
	var repeat = url.searchParams.get('repeat');
	var slow = url.searchParams.get('slow');

	var xmlHttp = new XMLHttpRequest();
	xmlHttp.open( "GET", '/api?repeat='+ repeat + '&slow=' + slow, false );
	xmlHttp.send( null );
	return xmlHttp.responseText;
}
setInterval(function() { document.getElementById('api-response').innerHTML=get(); }, 1000);
</script>
</body></html>`

