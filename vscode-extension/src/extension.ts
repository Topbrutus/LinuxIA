import * as vscode from 'vscode';
import { openChatGPT } from './commands/openChatGPT';
import { sendFileContext } from './commands/sendFileContext';
import { sendGitDiff } from './commands/sendGitDiff';

export function activate(context: vscode.ExtensionContext): void {
  // Bouton permanent dans la barre de statut
  const btn = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  btn.text = '$(comment-discussion) ChatGPT';
  btn.tooltip = 'LinuxIA — Ouvrir ChatGPT';
  btn.command = 'linuxia.openChatGPT';
  btn.show();
  context.subscriptions.push(btn);

  context.subscriptions.push(
    vscode.commands.registerCommand('linuxia.openChatGPT', openChatGPT),
    vscode.commands.registerCommand('linuxia.sendFileContext', sendFileContext),
    vscode.commands.registerCommand('linuxia.sendGitDiff', sendGitDiff),
  );
}

export function deactivate(): void {}
