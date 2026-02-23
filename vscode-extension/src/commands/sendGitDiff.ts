import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

/**
 * Exporte le git diff du workspace dans sessions/diff_*.md
 * avec métadonnées (commit hash, branche, agent actif).
 */
export async function sendGitDiff(): Promise<void> {
  const config = vscode.workspace.getConfiguration('linuxia');
  const sessionsDir = config.get<string>('sessionsDir', '/opt/linuxia/sessions');

  const workspaceRoot =
    vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? '/opt/linuxia';

  let diff: string;
  let branch: string;
  let commitHash: string;

  try {
    diff = execSync('git diff HEAD', { cwd: workspaceRoot }).toString();
    branch = execSync('git rev-parse --abbrev-ref HEAD', { cwd: workspaceRoot })
      .toString()
      .trim();
    commitHash = execSync('git rev-parse --short HEAD', { cwd: workspaceRoot })
      .toString()
      .trim();
  } catch (e) {
    vscode.window.showErrorMessage('LinuxIA: Impossible de lire le git diff. Êtes-vous dans un repo Git ?');
    return;
  }

  if (!diff.trim()) {
    vscode.window.showInformationMessage('LinuxIA: Aucune modification non commitée.');
    return;
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const diffFile = path.join(sessionsDir, `diff_${timestamp}.md`);

  const md = [
    `# Git Diff — ${branch} @ ${commitHash}`,
    `**Branche:** \`${branch}\``,
    `**Commit:** \`${commitHash}\``,
    `**Date:** ${new Date().toISOString()}`,
    `**Workspace:** \`${workspaceRoot}\``,
    '',
    '```diff',
    diff,
    '```',
  ].join('\n');

  fs.mkdirSync(sessionsDir, { recursive: true });
  fs.writeFileSync(diffFile, md, 'utf8');

  // Archive JSONL structuré pour l'orchestrateur LinuxIA
  const jsonlEntry = JSON.stringify({
    type: 'git_diff',
    timestamp: new Date().toISOString(),
    branch,
    commit: commitHash,
    workspace: workspaceRoot,
    file: diffFile,
  });
  fs.appendFileSync(path.join(sessionsDir, 'archive.jsonl'), jsonlEntry + '\n');

  await vscode.window.showInformationMessage(
    `LinuxIA: Diff exporté → ${diffFile}`,
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

  const uri = vscode.Uri.file(diffFile);
  await vscode.window.showTextDocument(uri, { preview: true, viewColumn: vscode.ViewColumn.Beside });
}
