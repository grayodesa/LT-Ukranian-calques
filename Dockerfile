FROM erikvl87/languagetool:latest

USER root

# Copy everything from rules/ into temp
COPY rules/ /tmp/custom-rules/

# Inject all custom XML rules into grammar-barbarism.xml
RUN RULES_FILE="/LanguageTool/org/languagetool/rules/uk/grammar-barbarism.xml" && \
    \
    # Extract categories from all custom XML files
    echo "" > /tmp/all_categories.xml && \
    for CUSTOM in /tmp/custom-rules/*.xml; do \
        if [ -f "$CUSTOM" ]; then \
            FILENAME=$(basename "$CUSTOM") && \
            echo "" >> /tmp/all_categories.xml && \
            echo "<!-- ============================================================ -->" >> /tmp/all_categories.xml && \
            echo "<!-- Rules from: $FILENAME -->" >> /tmp/all_categories.xml && \
            echo "<!-- ============================================================ -->" >> /tmp/all_categories.xml && \
            sed -n '/<category /,/<\/category>/p' "$CUSTOM" >> /tmp/all_categories.xml && \
            echo "✅ Extracted categories from $FILENAME"; \
        fi; \
    done && \
    \
    # Inject into grammar-barbarism.xml if we have rules
    if [ -s /tmp/all_categories.xml ] && [ -f "$RULES_FILE" ]; then \
        LINE=$(grep -n '</rules>' "$RULES_FILE" | tail -1 | cut -d: -f1) && \
        head -n $((LINE - 1)) "$RULES_FILE" > /tmp/rules_top.xml && \
        { \
            cat /tmp/rules_top.xml; \
            echo ''; \
            echo '<!-- ============================================================ -->'; \
            echo '<!-- CUSTOM RULES (auto-injected at build time)                   -->'; \
            echo '<!-- ============================================================ -->'; \
            cat /tmp/all_categories.xml; \
            echo ''; \
            echo '</rules>'; \
        } > "$RULES_FILE" && \
        RULE_COUNT=$(grep -c '<rule ' /tmp/all_categories.xml || echo 0) && \
        CAT_COUNT=$(grep -c '<category ' /tmp/all_categories.xml || echo 0) && \
        echo "✅ Injected $RULE_COUNT rules in $CAT_COUNT categories into grammar-barbarism.xml"; \
    else \
        echo "⚠️  No custom rules found or target file missing, skipping injection"; \
    fi && \
    \
    # Optional: custom spelling words (place spelling_uk.txt in rules/)
    SPELLING_FILE="/LanguageTool/org/languagetool/resource/uk/hunspell/spelling.txt" && \
    if [ -f /tmp/custom-rules/spelling_uk.txt ] && [ -f "$SPELLING_FILE" ]; then \
        grep -v '^#' /tmp/custom-rules/spelling_uk.txt | grep -v '^$' >> "$SPELLING_FILE" && \
        echo "✅ Added custom spelling words"; \
    fi && \
    \
    # Cleanup
    rm -rf /tmp/custom-rules /tmp/all_categories.xml /tmp/rules_top.xml

USER languagetool