module.exports = async ({ context, core, exec, github }) => {
  const limit = 1000 * 60 * 60 * 24; // 24hrs in milliseconds

  // Get the date and message body of the last commit
  const {
    data: {
      commit: {
        message,
        committer: { date: timestamp }
      }
    }
  } = await github.rest.repos.getCommit({
    ref: process.env.GITHUB_SHA,
    owner: context.repo.owner,
    repo: context.repo.repo
  });
  const forceDeploy =
    (process.env.FORCE_DEPLOY && process.env.FORCE_DEPLOY === 'true') ||
    message.startsWith('__deploy__');
  const date = new Date(timestamp).getTime();

  // Check if '__deploy__' prefix exists on commit message
  // or if process.env.FORCE_DEPLOY is set
  // And check if it hasn't been 24hrs since the last commit with '__deploy__' prefix,
  // to prevent multiple forced deployments, as this workflow runs every day at 12am UTC
  if (forceDeploy && Math.floor(Date.now() - date) < limit) {
    core.setOutput('force_deploy', 'true');
    core.warning('A forced deployment will occur');
  }

  // Try to update the telegram-api-bot submodule,
  // in order to deploy the Docker Container to Heroku or Fly.io
  await exec.exec('git', ['submodule', 'update', '--remote'], {
    listeners: {
      stdout: () => {
        core.setOutput('new_update', 'true');
      }
    }
  });
};
