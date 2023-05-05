# nQuake Server

This is the Docker version of nQuake Server, modified by [cu].

It adds Docker Compose, so all you have to do to bring up a server is create an
`.env` file in this directory containing two environment variables (please
don't use these, they are just examples):

```ini
RCON_PASSWORD=hunter2
HOSTNAME=q1.example.com
```

Other variables are available to customize if you wish, see
`docker-compose.yaml` for the full list.

Then bring up the server with:

```
docker compose up
```

[cu]: https://github.com/cu
