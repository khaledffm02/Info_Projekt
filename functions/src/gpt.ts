export type Message = {
  role: "system" | "user" | "assistant";
  content: (
    | { type: "text"; text: string }
    | { type: "image_url"; image_url: { url: string } }
  )[];
};

export async function gpt(
  messages: Message[],
  maxTokens: number,
  isJSON = false,
  model: "gpt-4o-mini" | "gpt-4o",
  bearerToken: string
) {
  return fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${bearerToken}`,
    },
    body: JSON.stringify({
      model,
      messages,
      response_format: isJSON ? {type: "json_object"} : undefined,
      temperature: 0,
      max_tokens: maxTokens,
    }),
  })
    .then(async (response) => response.json())
    .then((data: any) => {
      // console.log(data);
      if (!data || data.error) {
        return undefined;
      }
      // const costs = (data.usage.total_tokens / 1000) * 0.01;
      // console.debug(`Costs: $${costs}`);
      return data.choices[0].message?.content;
    });
}
