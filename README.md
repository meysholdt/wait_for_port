# "Wait for Port" Example

This repo holds the `wait-for-port.sh` script, which is a helper script that can be used in Gitpod automaitons and elsewhere to run your own code *after* a service has started to listen on a port.

### Example 1: Foreground Waiting
Use this if you start the service that opens the port in a different terminal or task
```bash
./wait-for-port.sh 8080
URL=$(gitpod env ports list -o json | jq -r '.[] | select(.port==8080).url')
[ -z "$URL" ] && echo "port 8080 not opened in Gitpod"
code --openExternal "$URL"
```

### Example 2: Background Waiting
Use this if you start the service that opens the port in a the same terminal or task

```bash
(
  ./wait-for-port.sh 8080
  URL=$(gitpod env ports list -o json | jq -r '.[] | select(.port==8080).url')
  [ -z "$URL" ] && echo "port 8080 not opened in Gitpod"
  code --openExternal "$URL"
) &   # background the whole subshell

# …then start the real server in the foreground
python3 -m http.server 8080
```