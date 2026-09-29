# How to contribute

This guide explains how to extend AREA: add a service, an action, a reaction or an OAuth provider.
Read [docs/architecture.md](docs/architecture.md) first for the big picture, and the [README](README.md) to run
the project.

## How the pieces fit

| Piece | Where | Role |
| --- | --- | --- |
| Microservice | `services/images/<name>/` | Stateless HTTP worker talking to one third-party API |
| Catalog | `backend/services_catalog.yaml` | Declares the services, actions and reactions the server exposes |
| Server | `backend/` | Stores applets, runs the hook, calls the microservices |
| Compose | `docker-compose.yml` | Builds and wires every container |

The server never contains service-specific code: an action or a reaction is only a catalog entry pointing to a
microservice route. Adding one is therefore mostly about writing the microservice endpoint.

## Microservice contract

Every microservice listens on port `8000`, prefixes its routes with `/<service>/` and exposes
`GET /<service>/health`. All payloads are JSON.

### Polling action

The server calls the action every `polling_interval` minutes:

```http
POST /<service>/<action>
{
  "<input field>": "value typed by the user",
  "state": {},
  "token": "OAuth access token of the user, only when the action has a provider"
}
```

and expects a `2xx` answer:

```json
{
  "triggered": true,
  "state": {"last_id": "42"},
  "<output field>": "string value"
}
```

- `state` is stored by the server and sent back on the next call: use it to remember what was already seen,
  so the action only triggers once per event.
- Output fields must be **strings**. They can be used in the reaction inputs as `{output_field}`.

### Webhook action

For services that push events, the server calls `POST <route>/create_webhook` when the applet is enabled and
`POST <route>/delete_webhook` when it is disabled, with `applet_id`, `state`, the inputs and the token.
`create_webhook` may return `{"state": {...}}` (e.g. the webhook id, needed to delete it later).

When the event happens, the microservice sends the output fields to the server:

```http
POST <SERVER_URL>/applets/trigger_reactions/<applet_id>
{"<output field>": "string value"}
```

See `services/images/github/` for a complete example.

### Reaction

```http
POST /<service>/<reaction>
{"<input field>": "value, with {placeholders} already replaced", "token": "..."}
```

Any `2xx` status means success.

## Add a service

1. **Write the microservice** in `services/images/<service>/`. Any language works as long as it follows the
   contract above; the existing ones are small Go servers you can copy, Dockerfile included.
2. **Add it to `docker-compose.yml`**, named `<service>-service` so the server can reach it at
   `http://<service>-service:8000`:

   ```yaml
   weather-service:
     <<: *microservice
     build: ./services/images/weather
     environment:
       API_KEY: ${WEATHER_API_KEY:-}
   ```

   Declare the new variables in `.env.example`.
3. **Declare it in `backend/services_catalog.yaml`**:

   ```yaml
   - name: Weather
     service: weather          # the <service> of the compose name and of the routes
     color: "#1E88E5"
     actions:
       - title: It rains
         description: It is raining in a city.
         route: /weather/rain
         polling_interval: 30
         input_fields:
           - {name: city, regex: '^.+$', example: Paris}
         output_fields: [temperature]
     reactions: []
   ```

   `provider` (`google`, `github`, `discord`, `spotify` or `twitch`) makes the server send the user's OAuth token
   and prevents enabling the applet until the user linked that account.
4. **Add an icon** (optional): `backend/services_icons/<slug>.svg`, the slug being the service name in lower case
   with non-alphanumeric characters replaced by `_` (`Google Calendar` gives `google_calendar.svg`).
5. **Document it** in `docs/services/<Name>/README.md`.

The catalog is loaded only into an **empty** database, so admin edits are never overwritten. To reload it
locally, reset the database with `docker compose down -v && docker compose up -d --build`, or create the entries
through the admin API (`POST /services`, `POST /services/{id}/actions`, `POST /services/{id}/reactions`, see
http://localhost:8080/docs, logged in as `admin` / `admin`).

## Add an action or a reaction to an existing service

1. Add the handler and its route to the microservice.
2. Add the entry under `actions` or `reactions` of the service in `backend/services_catalog.yaml`.
3. Reload the catalog as explained above.

Input field regexes are checked by the clients and by the server (Python `re.match`). Keep them compatible with
both JavaScript and Python, and accept the `{placeholder}` syntax for free-text reaction inputs (`'^.+$'`).

## Add an OAuth provider

1. `backend/database_orm/`: add a `<Provider>Credentials` model linked to `User`, and the provider to the
   `Provider` enum in `action.py`.
2. `backend/config.py`: read `<PROVIDER>_CLIENT_ID`, `<PROVIDER>_CLIENT_SECRET` and the redirect URI, and register
   the pair in `_OAUTH_CLIENTS`.
3. `backend/routes/<provider>_auth_routes.py`: copy an existing module (e.g. `spotify_auth_routes.py`) for the
   link, callback, unlink and link-status endpoints, and include its router in `main.py`.
4. `backend/runner.py`: handle the provider in `manage_token_retrieval` (token refresh).
5. `docker-compose.yml` and `.env.example`: pass the new variables to the `server` service.
6. `frontend/components/account/linked-accounts-section.tsx`: add the account to the linked accounts list.

## Before opening a pull request

- `docker compose up -d --build` starts, and `http://localhost:8080/about.json` lists your changes.
- Backend tests pass: `docker compose exec server pytest tests.py` (they run against the compose database).
- The frontend builds: `cd frontend && npm run build`.
