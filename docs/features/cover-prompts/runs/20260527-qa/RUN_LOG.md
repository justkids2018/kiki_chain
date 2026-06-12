## Result
PASS

## Scope
- Regenerated and QA-validated 6 cover prompt files under `kiki_web/doc/image/prompts/`:
  - `01_daily_life_cover.md`
  - `02_playground_cover.md`
  - `03_number_recognition_cover.md`
  - `04_letter_recognition_cover.md`
  - `05_traditional_festivals_cover.md`
  - `06_school_commute_cover.md`

## Command
```bash
cd /Users/qisd/Documents/development/my_project/kiki_chain && fail=0
for f in kiki_web/doc/image/prompts/*_cover.md; do
  echo "[CHECK] $f"
  rg -n "必须具备前景 / 中景 / 后景分层" "$f" >/dev/null || { echo "  - missing depth layering rule"; fail=1; }
  rg -n "10 岁姐姐 \+ 4 岁双马尾妹妹" "$f" >/dev/null || { echo "  - missing sisters baseline"; fail=1; }
  rg -n "可爱白色小猫" "$f" >/dev/null || { echo "  - missing white kitten baseline"; fail=1; }
  rg -n "No \[cite:x\], \[ref:x\], \[source:x\]" "$f" >/dev/null || { echo "  - missing anti-citation rule"; fail=1; }
  rg -n "No big text title|无大标题" "$f" >/dev/null || { echo "  - missing no-title constraint"; fail=1; }
  if rg -n "No human characters|❌ 人物角色" "$f" >/dev/null; then
    echo "  - conflict: old 'no human characters' rule still present"
    fail=1
  fi
  if [[ "$fail" -eq 0 ]]; then echo "  - OK"; fi
done
if [[ "$fail" -eq 0 ]]; then
  echo "QA_RULE_CHECK: PASS"
else
  echo "QA_RULE_CHECK: FAIL"
  exit 1
fi
```

## Exit Code
0

## Stdout
```text
[CHECK] kiki_web/doc/image/prompts/01_daily_life_cover.md
  - OK
[CHECK] kiki_web/doc/image/prompts/02_playground_cover.md
  - OK
[CHECK] kiki_web/doc/image/prompts/03_number_recognition_cover.md
  - OK
[CHECK] kiki_web/doc/image/prompts/04_letter_recognition_cover.md
  - OK
[CHECK] kiki_web/doc/image/prompts/05_traditional_festivals_cover.md
  - OK
[CHECK] kiki_web/doc/image/prompts/06_school_commute_cover.md
  - OK
QA_RULE_CHECK: PASS
```

## Stderr / Traceback
```text
(none)
```

## Defects And Fixes
- Defect: 4 files lacked the exact anti-citation prohibition pattern `No [cite:x], [ref:x], [source:x]`, causing QA rule check failure.
- Fix: Added unified prohibition line to all missing files under each `Prohibitions:` block.
- Re-test: All 6 files passed after fix.

## UI Validation
- Target Page: N/A (this task only changes markdown prompt documents)
- Device/Runtime: N/A
- Screenshots: N/A
- Verdict: PASS (UI acceptance not applicable for doc-only changes)

## Remaining Risks
- This QA verifies document-rule consistency only.
- Actual image generation quality still depends on model behavior and should be spot-checked when producing final assets.
