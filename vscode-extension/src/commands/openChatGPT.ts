import * as vscode from 'vscode';

/**
 * Ouvre l'assistant IA dans le Simple Browser intégré.
 * L'URL est configurable via `linuxia.chatgptUrl`.
 */
export async function openChatGPT(): Promise<void> {
  const config = vscode.workspace.getConfiguration('linuxia');
  let url = config.get<string>('chatgptUrl', 'https://chat.openai.com');

  const input = await vscode.window.showInputBox({
    prompt: 'URL de ton assistant IA',
    value: url,
    ignoreFocusOut: true,
  });

  if (input === undefined) return;

  if (input !== url) {
    await config.update('chatgptUrl', input, vscode.ConfigurationTarget.Global);
    url = input;
  }

  try {
    await vscode.commands.executeCommand('simpleBrowser.show', url);
  } catch {
    await vscode.env.openExternal(vscode.Uri.parse(url));
  }
}
