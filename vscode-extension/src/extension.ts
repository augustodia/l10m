import * as vscode from 'vscode';
import * as path from 'path';
import * as child_process from 'child_process';

export function activate(context: vscode.ExtensionContext) {
    const watcher = vscode.workspace.createFileSystemWatcher('**/*.arb');

    watcher.onDidChange(uri => {
        runTranslationGenerationCommand(uri.fsPath);
    });

    watcher.onDidCreate(uri => {
        runTranslationGenerationCommand(uri.fsPath);
    });

    watcher.onDidDelete(uri => {
        runTranslationGenerationCommand(uri.fsPath);
    });

    context.subscriptions.push(watcher);
}

function runTranslationGenerationCommand(filePath: string) {
    const workspaceFolder = vscode.workspace.workspaceFolders?.[0].uri.fsPath;
    if (!workspaceFolder) {
        vscode.window.showErrorMessage('No workspace folder found');
        return;
    }

    const command = `dart run l10m -m ${workspaceFolder}/lib/modules -o l10n/generated -r ${workspaceFolder}/lib -t intl_en.arb`;
    child_process.exec(command, (error, stdout, stderr) => {
        if (error) {
            vscode.window.showErrorMessage(`Error: ${stderr}`);
            return;
        }
        vscode.window.showInformationMessage('Translations generated successfully');
    });
}
