Looking at the performance cost of chaining multiple web servers versus having a single one.

We have 3 scenarios we're looking at:

1. nginx -> haproxy -> backend – `docker-compose up nginx-haproxy`
2. haproxy -> backend – `docker-compose up haproxy`
3. nginx -> backend – `docker-compose up nginx`

And we want to understand the performance differences (if any).

```sh
> wrk2 -t 50 -c 100 -d 60s -R 200 http://localhost:8080
```

nginx -> haproxy -> backend . This is something like the existing setup.

      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    47.65ms   12.69ms  98.37ms   70.26%
        Req/Sec     3.88      6.35    22.00     75.35%
      12008 requests in 1.00m, 3.03MB read
    Requests/sec:    200.02
    Transfer/sec:     51.76KB

haproxy -> backend . This is a proposed optimisation to move session ID concerns out of nginx and just use haproxy.

      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    14.21ms    8.74ms  66.94ms   70.99%
        Req/Sec     4.11     13.36   100.00     90.51%
      12015 requests in 1.00m, 2.98MB read
    Requests/sec:    200.17
    Transfer/sec:     50.82KB

nginx -> backend . This is the other proposed optimisation to move routing concerns out of haproxy and just use nginx.

      Thread Stats   Avg      Stdev     Max   +/- Stdev
      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency    27.82ms    7.61ms  56.22ms   73.75%
        Req/Sec     3.97      9.25    36.00     85.30%
      12026 requests in 1.00m, 3.04MB read
    Requests/sec:    200.32
    Transfer/sec:     51.83KB

You will get different numbers when you run this. I got different numbers each time!

This was an interesting exercise. Using Lua in haproxy and openresty nginx is a different
experience. Openresty comes with lots out of the box, whereas haproxy needed more work – see
[the Dockerfile](haproxy/Dockerfile) for how I installed a library to get openssl functionality
available in Lua in haproxy.
