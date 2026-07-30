/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Spark Image Generation Service
 *
 * Uses the GitHub Models image generation API (DALL-E 3) to produce
 * avatar assets for LinuxIA agents. Generated image URLs are real CDN
 * file URLs returned by the API; they are also fetched and converted to
 * object URLs so previews render reliably even after the CDN URL expires.
 */

const SPARK_IMAGE_ENDPOINT =
  "https://models.inference.ai.azure.com/images/generations";

export interface AvatarResult {
  /** Permanent object URL (blob:) created from the fetched image data */
  objectUrl: string;
  /** Original CDN file URL returned by the API */
  fileUrl: string;
  /** Prompt used to generate the image */
  prompt: string;
}

/**
 * Generate a single avatar image via the Spark image generation API.
 *
 * @param prompt  Descriptive prompt for the avatar image.
 * @param token   GitHub personal access token (or Codespaces token).
 * @returns       AvatarResult with both the raw API URL and a stable object URL.
 */
export async function generateAvatarImage(
  prompt: string,
  token: string
): Promise<AvatarResult> {
  if (!token) {
    throw new Error("GITHUB_TOKEN is required for Spark image generation.");
  }

  const response = await fetch(SPARK_IMAGE_ENDPOINT, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "dall-e-3",
      prompt,
      n: 1,
      size: "1024x1024",
      response_format: "url",
    }),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => response.statusText);
    throw new Error(`Spark image generation failed (${response.status}): ${body}`);
  }

  const json = await response.json();
  const fileUrl: string = json?.data?.[0]?.url;
  if (!fileUrl) {
    throw new Error("Spark API returned no image URL.");
  }

  // Fetch the image bytes and create a stable object URL so the <img>
  // preview does not break when the CDN URL expires.
  const imgResponse = await fetch(fileUrl);
  if (!imgResponse.ok) {
    throw new Error(`Failed to fetch generated image from CDN (${imgResponse.status}).`);
  }
  const blob = await imgResponse.blob();
  const objectUrl = URL.createObjectURL(blob);

  return { objectUrl, fileUrl, prompt };
}

/**
 * Release a previously created object URL to free browser memory.
 */
export function revokeAvatarUrl(objectUrl: string): void {
  if (objectUrl && objectUrl.startsWith("blob:")) {
    URL.revokeObjectURL(objectUrl);
  }
}
