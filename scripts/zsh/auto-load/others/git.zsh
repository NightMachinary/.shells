### Aliases
alias gdc='git diff --name-only --diff-filter=U' # List conflicted files in git
alias grm='git rm --cached'
###
function gsync() {
  git add .
  git commit -a -m .
  git pull
  git push
}
ghttp() { git remote -v |awk '{print $2}'|inargsf git2http| gsort -u > >(pbcopy) | cat }
guc() {
  mdoc "$0 [<how-many>=1]
Undoes last commits without changing files." MAGIC

  git reset --soft HEAD~"${1:-1}"
}
_git2http() {
  mdoc "Usage: git2http <git-ssh-url> ...
cat <file-with-ssh-urls> | git2http

 -> <git-https-url> ...
This function is idempotent (it passes http URLs through)." MAGIC

  if [[ "$*" =~ '^http' ]]
then
  ec "$*"
  else
    <<<"$*" gsed -e 's|:|/|' -e 's|git@|https://|'
  fi
}
alias git2http='noglob inargsEf "re _git2http"'
git-resolve() {
  local git=("${=gitbinary:-git}")
  STRATEGY="$1"
  FILE_PATH="$2"

  if [ -z "$FILE_PATH" ] || [ -z "$STRATEGY" ]; then
  echo "Usage:   <strategy> <file>"
  echo ""
  echo "Example: --ours package.json"
  echo "Example: --union package.json"
  echo "Example: --theirs package.json"
  return
  fi

  if [ ! -e "$FILE_PATH" ]; then
  echo "$FILE_PATH does not exist; aborting."
  return
  fi

  # remove leading ./ if present, to match the output of $git[@] diff --name-only
  # (otherwise if user input is './filename.txt' we would not match 'filename.txt')
  FILE_PATH_FOR_GREP=${FILE_PATH#./}
  # grep -Fxq: match string (F), exact (x), quiet (exit with code 0/1) (q)
  if ! $git[@] diff --name-only --diff-filter=U | grep -Fxq "$FILE_PATH_FOR_GREP"; then
  echo "$FILE_PATH is not in conflicted state; aborting."
  return
  fi

  $git[@] show :1:"$FILE_PATH" > ./tmp.common
  $git[@] show :2:"$FILE_PATH" > ./tmp.ours
  $git[@] show :3:"$FILE_PATH" > ./tmp.theirs

  $git[@] merge-file "$STRATEGY" -p ./tmp.ours ./tmp.common ./tmp.theirs > "$FILE_PATH"
  $git[@] add "$FILE_PATH"

  rm ./tmp.common
  rm ./tmp.ours
  rm ./tmp.theirs
}
git-listblobs() {
  mdoc List blobs sorted by size. MAGIC
  git rev-list --objects --all \
    | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
    | sed -n 's/^blob //p' \
    | sort --numeric-sort --key=2 \
    | cut -c 1-12,41- \
    | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}
