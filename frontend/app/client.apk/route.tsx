import { promises as fs } from 'fs';
import { join } from 'path';

export const dynamic = 'force-dynamic';

// The client_mobile service writes the APK into a volume shared with this container.
const APK_PATH = process.env.APK_PATH || join(process.cwd(), 'public', 'client.apk');

export async function GET() {
  let file: Buffer;
  try {
    file = await fs.readFile(APK_PATH);
  } catch {
    return Response.json(
      { error: 'The Android client has not been built. Run: docker compose --profile mobile up -d' },
      { status: 404 }
    );
  }

  return new Response(new Uint8Array(file), {
    status: 200,
    headers: {
      'Content-Type': 'application/vnd.android.package-archive',
      'Content-Length': file.length.toString(),
      'Content-Disposition': 'attachment; filename="client.apk"',
      'Cache-Control': 'no-store',
    },
  });
}
