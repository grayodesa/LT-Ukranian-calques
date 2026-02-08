#!/bin/bash
# Quick test for LanguageTool with UA-GEC fluency rules
# Usage: ./test.sh [server_url]

SERVER="${1:-http://localhost:8010}"

echo "Testing LanguageTool at: $SERVER"
echo ""

# Check if server is running
if ! curl -sf "$SERVER/v2/languages" > /dev/null 2>&1; then
    echo "❌ Server not reachable at $SERVER"
    echo "   Run: docker compose up -d"
    exit 1
fi

# Test texts — each should trigger at least one UA-GEC rule
declare -a TESTS=(
    "На протязі року ми працювали над проєктом."
    "Він являється головним спеціалістом відділу."
    "Слідуючий крок — розробка нової стратегії."
    "В цілому результати виявилися позитивними."
    "Потрібно прийняти міри для покращення ситуації."
    "Я рахую що це правильне рішення."
    "По крайній мірі десять людей підтримали ідею."
    "Він відноситься до роботи відповідально."
    "Потрібно задавати питання на лекціях."
    "Він грає роль важливу у цьому процесі."
    "Даний підхід є найбільш перспективним."
    "Як правило ми починаємо роботу о дев'ятій."
)

TOTAL=0
DETECTED=0

for text in "${TESTS[@]}"; do
    TOTAL=$((TOTAL + 1))

    RESULT=$(curl -sf "$SERVER/v2/check" \
        -d "language=uk" \
        --data-urlencode "text=$text" 2>/dev/null)

    MATCHES=$(echo "$RESULT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
matches = [m for m in data['matches']]
for m in matches:
    ctx = m['context']['text']
    offset = m['context']['offset']
    length = m['context']['length']
    word = ctx[offset:offset+length]
    repl = ', '.join(r['value'] for r in m['replacements'][:2])
    rule = m.get('rule', {}).get('id', '?')
    print(f'{word} → {repl} [{rule}]')
" 2>/dev/null)

    if [ -n "$MATCHES" ]; then
        DETECTED=$((DETECTED + 1))
        echo "✅ «$text»"
        echo "$MATCHES" | while read -r line; do
            echo "   ⚠  $line"
        done
    else
        echo "❌ «$text»"
        echo "   (no errors detected)"
    fi
    echo ""
done

echo "================================"
echo "Results: $DETECTED/$TOTAL texts triggered rules"
echo "================================"
