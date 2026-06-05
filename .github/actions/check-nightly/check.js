const repos = ["core", "redasm", "loaders", "processors", "commands", "analyzers", "kb"];
const owner = "redasm-dev";

// Get last nightly tag timestamp
let since = null;
try {
    const tag = await github.rest.repos.getReleaseByTag({
        owner,
        repo: "redasm",
        tag: "nightly"
    });
    since = tag.data.created_at;
    console.log(`Last nightly: ${since}`);
} catch (e) {
    console.log("No previous nightly found, building unconditionally");
}

if (!since) {
    core.setOutput("should_build", "true");
    core.setOutput("changelog", "Initial nightly build");
    return;
}

// Check each repo for new commits and build changelog
let hasChanges = false;
let changelog = "";

for (const repo of repos) {
    const commits = await github.rest.repos.listCommits({
        owner,
        repo,
        since,
        per_page: 20
    });

    if (commits.data.length > 0) {
        hasChanges = true;
        changelog += `\n**${repo}:**\n`;
        for (const commit of commits.data.reverse()) {
            changelog += `- \`${commit.sha.substring(0, 7)}\` ${commit.commit.message.split("\n")[0]}\n`;
        }
    }
}

if (!hasChanges) {
    console.log("No changes since last nightly, skipping build");
    core.setOutput("should_build", "false");
} else {
    core.setOutput("should_build", "true");
    core.setOutput("changelog", changelog);
}
