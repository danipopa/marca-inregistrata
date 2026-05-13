# API

Rails API for receiving website actions from the Nuxt frontend.

## Setup

```bash
bundle install
bin/rails db:migrate
```

## Development

```bash
bin/rails server -p 3001
```

## Test

```bash
bin/rails test
```

## Endpoints

```text
POST /api/v1/trademark_requests
```

Creates a trademark registration request from the website form.
