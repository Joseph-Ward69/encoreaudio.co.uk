#!/bin/sh
# Builds the site: wraps each src/<page>.html in the shared header and footer.
# The first line of each source file is: Title | Description | nav key (home, beta, faq or blank)
set -e
cd "$(dirname "$0")"
LOGO='<svg viewBox="0 0 64 64" aria-hidden="true"><rect x="1" y="1" width="62" height="62" rx="16" fill="#4C8DFF"/><rect x="14" y="16" width="8" height="32" rx="2.8" fill="#0A1A3A"/><rect x="25" y="16" width="10" height="7" rx="2.6" fill="#0A1A3A"/><rect x="25" y="28.5" width="7" height="7" rx="2.6" fill="#0A1A3A"/><rect x="25" y="41" width="10" height="7" rx="2.6" fill="#0A1A3A"/><path d="M40 24 A11 11 0 0 1 40 40" fill="none" stroke="#0A1A3A" stroke-width="4" stroke-linecap="round"/><path d="M45 18 A18 18 0 0 1 45 46" fill="none" stroke="#0A1A3A" stroke-width="4" stroke-linecap="round"/></svg>'
# Beta page: beta-state holds "open" (applications, with the form link from apply-url) or "closed" (the beta is full).
STATE=$(tr -d '\r\n ' < beta-state 2>/dev/null || echo open)
APPLY=$(tr -d '\r\n ' < apply-url 2>/dev/null)
# form-url: the Formspree endpoint that the contact and beta application forms post to.
FORM=$(tr -d '\r\n ' < form-url 2>/dev/null)
for src in src/*.html; do
  case "$(basename "$src")" in _*) continue;; esac
  name=$(basename "$src")
  # When the beta is closed, the beta and application pages both say so.
  case "$name" in beta.html|apply.html) [ "$STATE" = closed ] && src=src/_beta-closed.html;; esac
  meta=$(head -n 1 "$src")
  title=$(echo "$meta" | cut -d'|' -f1 | sed 's/ *$//')
  desc=$(echo "$meta" | cut -d'|' -f2 | sed 's/^ *//; s/ *$//')
  key=$(echo "$meta" | cut -d'|' -f3 | sed 's/^ *//; s/ *$//')
  cur() { [ "$key" = "$1" ] && printf ' aria-current="page"'; }
  {
    cat <<EOF
<!doctype html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title</title>
<meta name="description" content="$desc">
<link rel="icon" href="/assets/logo.svg" type="image/svg+xml">
<link rel="stylesheet" href="/assets/site.css">
</head>
<body>
<header class="site"><div class="wrap">
  <a class="brand" href="/">$LOGO<span>Encore Audio&trade;</span></a>
  <nav class="main">
    <a href="/"$(cur home)>Home</a>
    <a href="/beta.html"$(cur beta)>Beta</a>
    <a href="/roadmap.html"$(cur roadmap)>Roadmap</a>
    <a href="/milestones.html"$(cur milestones)>Milestones</a>
    <a href="/faq.html"$(cur faq)>Questions</a>
    <a href="/contact.html"$(cur contact)>Contact</a>
  </nav>
</div></header>
<main>
EOF
    tail -n +2 "$src"
    cat <<EOF
</main>
<footer class="site"><div class="wrap">
  <div>&copy; 2026 Winston Joseph-Ward. Encore Audio is a trade mark of Winston Joseph-Ward.<br>
  <a href="mailto:contact@encoreaudio.co.uk">contact@encoreaudio.co.uk</a></div>
  <nav><a href="/beta.html">Beta</a><a href="/roadmap.html">Roadmap</a><a href="/milestones.html">Milestones</a><a href="/faq.html">Questions</a><a href="/contact.html">Contact</a><a href="/privacy.html">Privacy</a><a href="/licence.html">Licence agreement</a></nav>
</div></footer>
</body>
</html>
EOF
  } | sed "s|APPLY_URL|$APPLY|g; s|FORM_URL|$FORM|g" > "$name"
done
echo "Built (beta $STATE): $(ls src | grep -v '^_' | tr '\n' ' ')"
