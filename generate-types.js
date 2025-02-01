import { createPostGraphileSchema } from "postgraphile";
import connectionFilterPlugin from "postgraphile-plugin-connection-filter";
import PostgisPlugin from "@graphile/postgis"
import { printSchema } from "graphql";
import fs from "fs";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

async function generateSchema() {
  const DATABASE_URL = process.env.DATABASE_URL || "postgresql://postgres:password@db.xyz.supabase.co:5432/postgres";

  try {
    // Generate GraphQL schema from Postgres database with the connection filter plugin
    const schema = await createPostGraphileSchema(DATABASE_URL, "public", {
      dynamicJson: true,
      appendPlugins: [connectionFilterPlugin, PostgisPlugin.default],
    });

    // Convert schema to SDL (Schema Definition Language)
    const schemaSDL = printSchema(schema);

    // Save schema to a file
    fs.writeFileSync("generated/graphql-schema.graphql", schemaSDL);
    console.log("GraphQL schema exported successfully.");
  } catch (error) {
    console.error("Error generating schema:", error);
    process.exit(1);
  }
}

generateSchema()
  .then(() => {
    console.log("TypeScript type generation complete.");
    process.exit(0);
  });
