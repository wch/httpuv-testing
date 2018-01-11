Testing httpuv
==============


## Installation

Currently, we want to test the `background-thread` branch of httpuv. To install it:

```R
devtools::install_github("rstudio/httpuv@background-thread")
```

## A basic test application

Here's a basic web server application for testting:

```R
library(httpuv)

app_handle <- startServer("0.0.0.0", 5000,
  list(
    call = function(req) {
      list(
        status = 200L,
        headers = list(
          'Content-Type' = 'text/html'
        ),
        body = paste0('The request path was "', req$PATH_INFO, '"')
      )
    }
  )
)
```


To stop the server, use `stopServer()` or `stopAllServers()`:


```R
stopServer(app_handle)

# stopAllServers doesn't require a handle:
stopAllServers()
```


### Basic interactions


When the application is running, you can use `curl` or `wget` to send requests:

```
$ curl -i http://127.0.0.1:5000/some-path
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 33

The request path was "/some-path"


$ wget -q -S --tries=1 --content-on-error http://localhost:5000/some-path -O -
  HTTP/1.1 200 OK
  Content-Type: text/html
  Content-Length: 33
The request path was "/some-path"
```

(The `--tries=1` and `--content-on-error` flags to `wget` aren't necessary to for this demonstration, but they are helpful for other situations.)



For lower-level diagnostics, you can also use `nc` (netcat), and give it a request string -- in this case `GET /some-path HTTP/1.1`, followed by two newlines:

```
$ nc 127.0.0.1 5000
GET /some-path HTTP/1.1

HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 33

The request path was "/some-path"^C
```

Because this request was made with HTTP 1.1, which defaults to keeping the connection alive, you need to press Ctrl-C to close the connection. If you use HTTP 1.0 or give it a `Connection: close` request header, then the connection will be closed automatically by the server after it sends its response.


### Testing with load

The tool I have used to test with significant load is Apachebench. On macOS, I believe this is installed by default. In Ubuntu Linux, it can be installed with:

```
apt-get install apache2-utils
```

Here is a basic test. It will send 1000 requests to the specified URL, with 50 concurrent connections:

```
$ ab -n 1000 -c 50 http://127.0.0.1:5000/some-path
This is ApacheBench, Version 2.3 <$Revision: 1807734 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        
Server Hostname:        127.0.0.1
Server Port:            5000

Document Path:          /some-path
Document Length:        33 bytes

Concurrency Level:      50
Time taken for tests:   0.546 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      116000 bytes
HTML transferred:       33000 bytes
Requests per second:    1830.22 [#/sec] (mean)
Time per request:       27.319 [ms] (mean)
Time per request:       0.546 [ms] (mean, across all concurrent requests)
Transfer rate:          207.33 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.4      0       3
Processing:     7   27  24.8     22     139
Waiting:        7   27  24.8     22     139
Total:          9   27  25.1     22     140

Percentage of the requests served within a certain time (ms)
  50%     22
  66%     23
  75%     24
  80%     24
  90%     26
  95%    129
  98%    136
  99%    139
 100%    140 (longest request)
```

**NOTE:** On macOS, if about 16000 requests are made within a short amount of time, subsequent requests will simply fail, until the computer does some housecleaning. This can take somewhere from 10 seconds to one minute. This problem does not seem to occur on Linux.

