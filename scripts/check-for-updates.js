module.exports = async ({ context, core, exec }) => {
  const limit = 1000 * 60 * 60 * 24; // 24hrs in milliseconds
  const { timestamp, message } = context.payload.head_commit;
  const forceDeploy = process.env.FORCE_DEPLOY || '';
  const date = new Date(timestamp).getTime();

  // Check if '__deploy__' prefix exists on commit message
  // or if process.env.FORCE_DEPLOY is set
  // And check if it hasn't been 24hrs since the last commit with '__deploy__' prefix,
  // to prevent multiple forced deployments, as this workflow runs every day at 12am UTC
  if (
    forceDeploy === 'true' || message.includes('__deploy__')
      && Math.floor(Date.now() - date) < limit
  ) {
    core.setOutput('force_deploy', 'true');
    core.warning('Forced deployment');
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
}
