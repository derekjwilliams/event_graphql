import express from "express"
import { postgraphile } from "postgraphile"
import dotenv from "dotenv"

dotenv.config()
const app = express()

// Load environment variables
const DATABASE_URL = process.env.DATABASE_URL
const PORT = process.env.PORT || 3002

if (!DATABASE_URL) {
  throw new Error("DATABASE_URL is not defined in environment variables")
}

// Path to the generated GraphQL schema
app.use(
  postgraphile(DATABASE_URL, "public", {
    graphqlRoute: "/graphql",
    graphiql: true, // Enable GraphiQL interface
    enhanceGraphiql: true,
    exportGqlSchemaPath: './generated/graphql-schema.graphql', // Use the pre-generated schema
    enableCors: true,
  })
)

app.listen(PORT, () => {
  console.log(`🚀 Server is running at http://localhost:${PORT}/graphql`)
})
