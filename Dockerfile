FROM ghcr.io/iv-org/youtube-trusted-session-generator:latest

# Patch extractor.py to add no_sandbox=True for Railway (runs as root)
RUN python3 - <<'EOF'
import re

path = "/app/potoken_generator/extractor.py"
with open(path, "r") as f:
    content = f.read()

# Replace the nodriver.start() call to add no_sandbox and browser_args
old = 'browser = await nodriver.start(headless=False,'
new = '''browser = await nodriver.start(
        headless=False,
        no_sandbox=True,
        browser_args=[
            "--no-sandbox",
            "--disable-setuid-sandbox",
            "--disable-dev-shm-usage",
            "--disable-gpu",
        ],'''

content = content.replace(old, new)

with open(path, "w") as f:
    f.write(content)

print("✓ extractor.py patched successfully")
EOF

# Verify patch was applied
RUN grep -n "no_sandbox" /app/potoken_generator/extractor.py && echo "✓ Patch verified" || echo "✗ Patch FAILED"
