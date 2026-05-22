# Functional Debt — Winnow

*Edge cases, improvements, and scenarios not yet handled by the current PRD spec. Each entry includes the PRD location it relates to.*

---

## 1. Confidence vs. Score Ambiguity in Ranking

**Relates to:** §4.4 FR-11, FR-12 (ranked table + review loop)

**Scenario:** Two items have near-identical weighted totals but divergent confidence profiles — Item A scores 85 with low confidence (thin evidence), Item B scores 78 with high confidence (strong evidence). The ranked table places A above B, but a decision-maker should be aware that B may be the safer bet.

**Current handling:** The PRD specifies tie rules (≤10% margin, confidence overlap) and the low-confidence guardrail (FR-13 triggers only when ALL items have low confidence). The recommendation narrative flags "confidence gaps" and "near-ties within margin of error."

**Gap:** There is no explicit rule or warning for *partial* confidence disparity — where one or a few items have low confidence while others don't. The ranked table could silently favor a high-score/low-confidence item over a slightly-lower-score/high-confidence item without alerting the user.

**Proposed resolution:** Add a confidence-disparity indicator in the review loop. When adjacent ranked items have a score within 10% of each other but one has lower confidence, highlight the pair and ask: "Item X scores higher but with lower confidence — do you want to treat these as tied?"

---

## 2. (placeholder)

*Add edge cases as they are identified.*
