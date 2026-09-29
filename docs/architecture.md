# Architecture

## Components

```mermaid
flowchart LR
    browser([Browser]) --> web
    phone([Android app]) --> server

    subgraph compose [docker compose]
        web["client_web<br/>Next.js :8081"]
        mobile["client_mobile<br/>Flutter build"]
        server["server<br/>FastAPI :8080"]
        db[(PostgreSQL)]
        services["17 microservices<br/>Go :8000"]
        mobile -- "client.apk<br/>(shared volume)" --> web
        web -- "REST" --> server
        server --> db
        server -- "HTTP: actions / reactions" --> services
        services -- "webhook events" --> server
    end

    services --> apis([Third-party APIs:<br/>GitHub, Discord, Spotify, Google...])
```

- **server** holds all the business logic: users, OAuth tokens, the catalog of services, the applets and the
  scheduler (the *hook*) that runs them. It is the only component talking to the database.
- **client_web** and **client_mobile** are pure user interfaces on top of the server REST API.
- **microservices** are stateless workers, one per service. The server calls them with the user inputs, the
  saved state of the action and, when needed, the user's OAuth token; they call the third-party API and answer.

## Data model

```mermaid
classDiagram
    direction LR
    class User {
        UUID id
        str name
        str surname
        str email
        str password
        Gender gender
        date birthdate
        Role role
        bool is_activated
    }
    class Credentials {
        <<Google / GitHub / Discord / Spotify / Twitch>>
        str token
        str refresh_token
        datetime expires_at
    }
    class Service {
        UUID id
        str name
        str color
    }
    class Action {
        UUID id
        str title
        str description
        str route
        Provider provider
        int polling_interval
        bool webhook
        list~str~ output_fields
    }
    class Reaction {
        UUID id
        str title
        str description
        str route
        Provider provider
    }
    class InputField {
        <<ActionInputField / ReactionInputField>>
        str name
        str regex
        str example
    }
    class Applet {
        UUID id
        str title
        str description
        list~str~ tags
        dict action_inputs
        dict action_state
        bool active
    }
    class AppletReaction {
        UUID id
        dict reaction_inputs
    }

    User "1" -- "0..1" Credentials : per provider
    User "0..1" -- "*" Applet : owns (none = public template)
    Service "1" -- "*" Action
    Service "1" -- "*" Reaction
    Action "1" -- "*" InputField
    Reaction "1" -- "*" InputField
    Applet "*" -- "1" Action
    Applet "1" -- "1..*" AppletReaction
    AppletReaction "*" -- "1" Reaction
```

An **applet** is an AREA: one action and one or more reactions, each with the values the user typed for its
input fields. `action_state` is opaque data the action microservice returns to remember what it already saw
(last message id, last price...). Reaction inputs may contain `{field}` placeholders, replaced by the action
output fields when the reactions run.

## Hook: polling actions

Most actions are polled. Enabling an applet schedules a job (APScheduler, persisted in the database) that runs
every `polling_interval` minutes.

```mermaid
sequenceDiagram
    participant S as Scheduler (server)
    participant DB as PostgreSQL
    participant A as Action microservice
    participant R as Reaction microservice

    S->>DB: load applet, action inputs and state
    opt action needs an OAuth account
        S->>DB: get the user's token (refreshed if expired)
    end
    S->>A: POST route {inputs, state, token}
    A-->>S: {triggered, state, output fields}
    S->>DB: save the new state
    alt triggered
        loop each reaction of the applet
            S->>S: replace {field} placeholders with the action outputs
            S->>R: POST route {inputs, token}
            R-->>S: 2xx
        end
    end
```

## Hook: webhook actions

GitHub actions are pushed by GitHub instead of being polled.

```mermaid
sequenceDiagram
    participant U as Client
    participant S as Server
    participant G as github microservice
    participant GH as GitHub

    U->>S: create (POST /users/me/applets) or enable (PATCH {active: true}) an applet
    S->>G: POST <route>/create_webhook {applet_id, inputs, token}
    G->>GH: create repository webhook to <GITHUB_WEBHOOK_URL>/.../callback/{applet_id}
    G-->>S: {state: {webhook_id}}
    Note over GH,G: later, on a push / issue / pull request...
    GH->>G: POST callback/{applet_id} (event payload)
    G->>S: POST /applets/trigger_reactions/{applet_id} {output fields}
    S->>S: run the applet reactions (same loop as polling)
```

## Linking an OAuth account

```mermaid
sequenceDiagram
    participant W as Web client
    participant S as Server
    participant P as Provider (Google, Discord...)

    W->>S: GET /auth/{provider}/link?device=browser (bearer token)
    S-->>W: provider authorization URL (state = short-lived link token)
    W->>P: user consents
    P->>S: GET /auth/{provider}/callback?code&state
    S->>P: exchange code for access + refresh tokens
    S->>S: store the credentials on the user
    S-->>W: redirect to WEB_CLIENT_URL/auth/callback
```
