# event_graphql

Simple graphQL server for events stored in a Postgres database

The server code is in src/server.js

## Install

```bash
pnpm install
```


## Run:

```bash
pnpm run start
```

## Generate New Graphql and Schema

```bash
pnpm run generate
```

## Query Example, typical for RSS

```gql
{
  allTags(filter: { name: { in: ["Housing", "PNCA"] } }){
    nodes {
      name
      eventsByEventTagTagIdAndEventId {
        nodes {
          title
          pubDate
          author
          description
          content
        }
      }
    }
  }
}
```

### With pubDate and Tags

...