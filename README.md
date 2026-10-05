# Olist Growth Analytics: Activation, AOV, Retention, and LTV in a Real Marketplace

**Tools:** SQL (BigQuery), Python (pandas, SciPy)
**Dataset:** Olist Brazilian E-Commerce (Kaggle), real marketplace orders, 2016 to 2018, ~99,441 orders

## Overview

This project traces a real marketplace's customer lifecycle end to end: activation, average order value, retention, and lifetime value, closing with a statistically tested recommendation. Three real data-quality issues were found and corrected along the way, including one (a misused customer identifier) that would have produced a completely wrong retention conclusion if left unchecked.

## 1. Funnel and Activation

Activation was explicitly defined before any calculation: a customer is activated when their first order is successfully delivered, not merely placed or paid. Across the order lifecycle (purchased, approved, handed to carrier, delivered), **97.02% of orders reach full delivery** (96,476 of 99,441), with small, consistent attrition at every stage rather than one dramatic bottleneck. Cross-checking the delivery timestamp against the order status field surfaced a small, genuine data gap: 8 orders are marked "delivered" with no actual delivery timestamp, isolated using a NULL-filtering query after an initial COUNT-based check silently (and incorrectly) returned zero.

## 2. AOV Decomposition

Blended AOV came to **R$154.10** across 99,440 orders. Breaking this down by payment method initially suggested credit card drove higher AOV (R$163.32 vs R$65.70 for vouchers), which supported a plausible hypothesis: installment-based credit card payments reduce checkout friction for larger purchases. Controlling for product category overturned this. Within the same category (pcs), AOV was nearly identical across credit card (R$1,511) and boleto (R$1,582), meaning payment method's apparent effect was a composition artifact: credit card happened to carry a disproportionate share of high-value categories, not a true driver of basket size on its own. **Category, not payment method, is the real AOV driver.**

## 3. Cohort Retention

Monthly cohorts were built to track repeat purchasing. An initial run returned an implausible result: a single row showing 100% of customers active only in their first month, with nothing afterward, across the entire dataset. Investigation revealed the cause: Olist assigns a new `customer_id` per order, with `customer_unique_id` as the true, reusable person-level identifier (confirmed directly: 99,441 `customer_id`s collapse to only 96,096 real unique people). Retention was rebuilt on the correct key.

The corrected result: **month-1 retention sits between 0.1% and 0.5%** across reliable cohorts (edge months with incomplete data, at the start and end of the dataset, were excluded). This is roughly 10 times lower than GA4's week-1 retention in an earlier project. Combined with the 97% activation rate, the story is specific: Olist serves first-time customers well but gives almost no one a reason to return.

## 4. Retention Drivers by Category

Testing whether first-purchase category predicts return behavior, using window functions to isolate each customer's first order and first item: return rates ranged from under 1% to 9.14% across categories. The highest return rate (eletrodomesticos, large appliances, 9.14%) sat on a thin sample (689 customers), too small to act on. Categories with both solid volume and a respectable return rate, including moveis_decoracao (6,047 customers, 4.56%), cama_mesa_banho (8,843, 4.55%), and relogios_presentes (5,446, strong return rate on real volume), were identified as more trustworthy signals than the single highest number.

## 5. LTV by Category and Significance Testing

Average LTV was calculated per customer (total lifetime payment value) and joined to each customer's first-purchase category. Among categories with meaningful volume, **relogios_presentes (watches and gifts) had the highest average LTV at R$238.41**, notably, the Day 4 return-rate leader (eletrodomesticos) had only middling LTV (R$137.96), confirming that return rate alone does not indicate customer value.

A two-sample t-test confirmed relogios_presentes customers (mean LTV R$238.41) have significantly higher LTV than all other customers combined (mean R$161.85): t = 23.90, p < 0.001. The gap, roughly 47% higher, is both statistically significant and practically meaningful, not a large-sample artifact of a trivial difference.

**relogios_presentes converges on four independent signals**: real volume (5,446 customers), above-average AOV, a respectable return rate, and the highest statistically confirmed LTV among high-volume categories. No single metric carries the recommendation alone, which is what makes it defensible against scrutiny.

## 6. CAC Context

Olist's dataset contains no real marketing spend data. A general global e-commerce CAC benchmark (approximately $68 to $84 in 2026, no Brazil-specific figure available) was used as an illustrative reference, converted at an approximate exchange rate. Even relogios_presentes' R$238.41 LTV sits below this general CAC estimate, suggesting paid acquisition economics may be challenging across the board under this benchmark, though a real Brazil-specific CAC figure would be needed to confirm this. This reframes the growth priority: with acquisition economics uncertain, maximizing value from already-acquired customers (via the categories above) is the more defensible lever than spending more to acquire.

## Strategic Recommendations

1. **Prioritize relogios_presentes for retention and upsell investment.** It is the only category where volume, AOV, return rate, and statistically confirmed LTV all clear a reasonable bar simultaneously.
2. **Treat return rate and LTV as separate questions, always check both.** eletrodomesticos looked like the best retention story by one metric and was mediocre by the metric that actually measures value.
3. **Do not assume payment method drives AOV.** The credit card effect disappeared once category was controlled for; category-level merchandising, not payment nudging, is the real AOV lever.
4. **Investigate paid acquisition economics with real, Brazil-specific CAC data before committing budget.** The general benchmark used here suggests acquisition may be marginal; this needs local confirmation, not assumption.

## Limitations and Assumptions

- `customer_id` is order-specific in this dataset; all retention and LTV analysis uses `customer_unique_id`, the corrected person-level identifier, after an initial measurement proved structurally broken on the wrong key.
- Edge-month cohorts (at the very start and end of the dataset's date range) were excluded as incomplete, not real small cohorts.
- First-purchase category is defined as the first-listed product on a customer's first order, a simplification for orders containing multiple categories at once.
- The CAC benchmark used is a general global e-commerce figure with an approximate currency conversion, not Olist- or Brazil-specific; treat the acquisition-economics conclusion as directional, not precise.
- 8 orders show a status/timestamp mismatch (marked delivered with no delivery date), a small, acknowledged data gap.
