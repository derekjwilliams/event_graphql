import express from "express"
import { postgraphile } from "postgraphile"
import PostGraphileConnectionFilterPlugin from "postgraphile-plugin-connection-filter"
import PostgisPlugin from "@graphile/postgis"

import dotenv from "dotenv"

dotenv.config()
const app = express()

const DATABASE_URL = process.env.NEXT_PUBLIC_DATABASE_URL
const PORT = 3002

if (!DATABASE_URL) {
  throw new Error("NEXT_PUBLIC_DATABASE_URL is missing")
}

app.use(
  postgraphile(DATABASE_URL, "public", {
    // @ts-ignore
    appendPlugins: [PostGraphileConnectionFilterPlugin, PostgisPlugin.default],
    graphqlRoute: "/graphql",
    graphiql: true,
    enhanceGraphiql: true,
    dynamicJson: true,
    // exportGqlSchemaPath: './graphql-schema.graphql', // Use the pre-generated schema
    enableCors: true,
    allowExplain: true,
  })
)

app.listen(PORT, () => {
  console.log(`🚀 Server is running at http://localhost:3002/graphql`)
})