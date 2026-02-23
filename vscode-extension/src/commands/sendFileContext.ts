import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

/**
 * Exporte le contenu du fichier actif dans un fichier temporaire sessions/context_*.md
 * puis ouvre ChatGPT pour un collage propre.
 */
export async function sendFileContext(): Promise<void> {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage('LinuxIA: Aucun fichier actif.');
    return;
  }

  const doc = editor.document;
  const lang = doc.languageId;
  const filePath = doc.fileName;
  const content = doc.getText();

  const config = vscode.workspace.getConfiguration('linuxia');
  const sessionsDir = config.get<string>('sessionsDir', '/opt/linuxia/sessions');

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const contextFile = path.join(sessionsDir, `context_${timestamp}.md`);

  const md = [
    `# Context — ${path.basename(filePath)}`,
    `**Fichier:** \`${filePath}\``,
    `**Langage:** ${lang}`,
    `**Date:** ${new Date().toISOString()}`,
    '',
    '```' + lang,
    content,
    '```',
  ].join('\n');

  fs.mkdirSync(sessionsDir, { recursive: true });
  fs.writeFileSync(contextFile, md, 'utf8');

  await vscode.window.showInformationMessage(
    `LinuxIA: Contexte exporté → ${contextFile}`,
    'Ouvrir ChatGPT'
  ).then(async (action) => {
    if (action === 'Ouvrir ChatGPT') {
      const url = config.get<string>('chatgptUrl', 'https://chat.openai.com');
      try {
        await vscode.commands.executeCommand('simpleBrowser.show', url);
      } catch {
        await vscode.env.openExternal(vscode.Uri.parse(url));
      }
    }
  });

  // Ouvre aussi le fichier contexte dans l'éditeur
  const uri = vscode.Uri.file(contextFile);
  await vscode.window.showTextDocument(uri, { preview: true, viewColumn: vscode.ViewColumn.Beside });
}
