import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { uuidv7 } from "@earendil-works/pi-ai";

function textOf(message: any): string {
  if (typeof message?.content === "string") return message.content;
  return (message?.content ?? [])
    .filter((part: any) => part?.type === "text")
    .map((part: any) => part.text)
    .join("\n");
}

export default function (pi: ExtensionAPI) {
  let named = false;
  let naming = false;

  pi.on("message_end", async (event, ctx) => {
    if (named || naming || event.message?.role !== "user") return;
    const prompt = textOf(event.message).trim();
    if (!prompt || !process.env.HERDR_ENV) return;

    naming = true;
    try {
      const model = ctx.model;
      if (!model || !ctx.modelRegistry.hasConfiguredAuth(model)) return;

      const response = await ctx.modelRegistry.complete(
        model,
        {
          messages: [{
            role: "user",
            content: [{
              type: "text",
              text: `Create a concise Herdr agent name for this coding request. Return only 2-4 lowercase words separated by hyphens. No punctuation, quotes, explanation, or generic names like main. Request:\n${prompt.slice(0, 2000)}`,
            }],
            timestamp: Date.now(),
          }],
        },
        { reasoningEffort: "minimal", cacheRetention: "none", sessionId: uuidv7() },
      );

      const raw = response.content
        .filter((part): part is { type: "text"; text: string } => part.type === "text")
        .map((part) => part.text)
        .join("")
        .trim()
        .toLowerCase();
      const name = raw
        .replace(/[`"'\.]/g, "")
        .replace(/[^a-z0-9_-]+/g, "-")
        .replace(/^-+|-+$/g, "")
        .slice(0, 32);
      if (!name || name === "main") return;

      const result = await pi.exec("herdr", ["agent", "rename", "--current", name], {
        timeout: 10000,
      });
      if (result.code === 0) {
        named = true;
        if (ctx.hasUI) ctx.ui.notify(`Herdr agent renamed: ${name}`, "info");
      }
    } catch {
      // Naming is best-effort and must not interrupt the user's turn.
    } finally {
      naming = false;
    }
  });
}
