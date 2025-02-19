import express from "express"
import { postgraphile } from "postgraphile"
import PostGraphileConnectionFilterPlugin from "postgraphile-plugin-connection-filter"
import dotenv from "dotenv"
const cors = require('cors');

dotenv.config()
const app = express()

const DATABASE_URL = process.env.DATABASE_URL
const PORT = process.env.PORT || 3002

if (!DATABASE_URL) {
  throw new Error("DATABASE_URL is missing")
}

const options = {
  origin: 'https://event-feed-eta.vercel.app',
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

app.use(cors(options));

// app.options('*', cors(options));

app.use(
  postgraphile(DATABASE_URL, "public", {
    graphqlRoute: "/graphql",
    graphiql: true,
    enhanceGraphiql: true,
    // exportGqlSchemaPath: './generated/graphql-schema.graphql', // Use the pre-generated schema
    // enableCors: true,
    allowExplain: true,
    appendPlugins: [PostGraphileConnectionFilterPlugin],
  })
)

app.listen(PORT, () => {
  console.log(`🚀 Server is running at http://localhost:${PORT}/graphql`)
})
