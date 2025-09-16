const getVersion = async exec => {
  let version = '0.0.0';

  try {
    // Try to get telegram-bot-api version
    await exec.exec(
      // eslint-disable-next-line unicorn/prefer-string-raw
      'sed -n "s/.*TelegramBotApi VERSION \\([^ ]*\\).*/\\1/p" telegram-bot-api/CMakeLists.txt',
      [],
      {
        listeners: {
          stdout: data => {
            version = data.toString();
          }
        }
      }
    );
  } catch {}

  return version.trim();
};

module.exports = async ({ core, exec }) => {
  const current_version = await getVersion(exec);
  // Set the current version of telegram-bot-api submodule before update
  core.setOutput('current_version', current_version);

  await exec.exec('git submodule update --remote', [], {
    listeners: {
      stdout: async () => {
        core.setOutput('new_update', 'true');
        // Set the new version of telegram-bot-api submodule after update
        const new_version = await getVersion(exec);
        core.setOutput('new_version', new_version);
      }
    }
  });
};
