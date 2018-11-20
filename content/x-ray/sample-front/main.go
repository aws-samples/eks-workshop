package main

import (
	"io"
	"net/http"
	"golang.org/x/net/context/ctxhttp"
	"fmt"
	"io/ioutil"
	"time"

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

func main() {

	tr := &http.Transport{
		MaxIdleConns:       10,
		IdleConnTimeout:    30 * time.Second,
	}

	http.Handle("/api", xray.Handler(xray.NewFixedSegmentNamer("x-ray-sample-front-k8s"), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		resp, err := ctxhttp.Get(r.Context(), xray.Client(&http.Client{Transport: tr}), "http://x-ray-sample-back-k8s.default.svc.cluster.local")

		if err != nil {
			fmt.Println(err)
			io.WriteString(w, "Unable to make request to: http://x-ray-sample-back-k8s.default.svc.cluster.local")
			return
		}

		defer resp.Body.Close()

		if resp.StatusCode == http.StatusOK {
			body, err := ioutil.ReadAll(resp.Body)
			if err != nil {
				fmt.Println(err)
				return
			}
			w.Header().Set("Content-Type", "application/json")
			io.WriteString(w, string(body))
		}

	})))

	// Write the landing page
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "text/html")
			io.WriteString(w, html)
	})

	http.ListenAndServe(":8080", nil)
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
	var xmlHttp = new XMLHttpRequest();
	xmlHttp.open( "GET", "/api", false );
	xmlHttp.send( null );
	return xmlHttp.responseText;
}
setInterval(function() { document.getElementById("api-response").innerHTML=get(); }, 1000);
</script>
</body></html>`

