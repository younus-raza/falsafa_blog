#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"

ssh_key="${SSH_KEY:-$HOME/.ssh/moha0902}"
ssh_host="${SSH_HOST:-82.29.81.20}"
ssh_port="${SSH_PORT:-65002}"
ssh_user="${SSH_USER:-u553285586}"
remote_dir="${REMOTE_DIR:-~/domains/blog.falsafa.pro/public_html}"

usage() {
	cat <<'EOF'
Usage: ./scripts/deploy.sh

Builds the Hugo site and deploys it to Hostinger using SSH key authentication.
Optional environment overrides: SSH_KEY, SSH_HOST, SSH_PORT, SSH_USER, REMOTE_DIR.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
	usage
	exit 0
fi

if [[ "$#" -gt 0 ]]; then
	usage >&2
	exit 2
fi

for command_name in hugo rsync ssh; do
	if ! command -v "$command_name" >/dev/null 2>&1; then
		printf 'Required command not found: %s\n' "$command_name" >&2
		exit 1
	fi
done

if [[ ! -r "$ssh_key" ]]; then
	printf 'SSH private key is not readable: %s\n' "$ssh_key" >&2
	exit 1
fi

cd "$repo_dir"
hugo --minify

ssh_args=(-i "$ssh_key" -o BatchMode=yes -o IdentitiesOnly=yes -p "$ssh_port")
ssh "${ssh_args[@]}" "$ssh_user@$ssh_host" '
set -eu
web_root="$HOME/domains/blog.falsafa.pro/public_html"
if [ ! -d "$web_root" ]; then
	printf "Hostinger document root does not exist: %s\n" "$web_root" >&2
	exit 1
fi
for placeholder in "$web_root/default.php" "$web_root/default.php.hostinger-backup"; do
	if [ -f "$placeholder" ]; then
		backup="$HOME/$(basename "$placeholder").$(date +%Y%m%d%H%M%S).bak"
		mv "$placeholder" "$backup"
		printf "Moved Hostinger placeholder to %s\n" "$backup"
	fi
done
'

printf -v ssh_rsh 'ssh -i %q -o BatchMode=yes -o IdentitiesOnly=yes -p %q' "$ssh_key" "$ssh_port"
rsync -avz \
	--exclude='.DS_Store' \
	--exclude='images/Screenshot*' \
	-e "$ssh_rsh" \
	"$repo_dir/public/" \
	"$ssh_user@$ssh_host:$remote_dir/"

printf 'Deployed successfully: https://blog.falsafa.pro/\n'