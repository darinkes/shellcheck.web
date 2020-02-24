# Shellcheck.Web

## Build your own

```bash
$ docker build . -t shellcheck.web
$ docker run --rm -p 8000:80 shellcheck.web:latest
```

## Use Pre-build Container
```bash
$ docker run --rm -p 8000:80 darinkes/shellcheck.web:latest
```

Visit http://$YOUR-IP:8000
