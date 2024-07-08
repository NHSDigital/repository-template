# GitHub

## Branch Protection Rules

This will create the default branch protection rules using GitHub API.

```sh
./branch-protection.sh $reponame $PAT
```

PAT must have `administration:write`. [Create a repository rule set](https://docs.github.com/en/rest/repos/rules?apiVersion=2022-11-28#create-a-repository-ruleset)
