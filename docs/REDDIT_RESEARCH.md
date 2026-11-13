# Reddit research notes

## Access route (honest status)

The intended route was Reddit’s official OAuth Data API, read-only, with a
descriptive user agent and rate-limit compliance. Reddit’s Data API Terms
require use of the provided OAuth credentials and allow Reddit to enforce
limits: https://redditinc.com/policies/data-api-terms

The public Data API wiki describes registered apps, OAuth and rate limits;
unauthenticated traffic is blocked or limited:
https://support.reddithelp.com/hc/en-us/articles/16160319875092-Reddit-Data-API-Wiki

**What actually happened:** no Reddit OAuth application/credentials were
available during the hackathon window. No scraping bypass, no unauthenticated
request flood, and no attempt to work around rate limits or blocks was made.
**Zero live threads were collected.** Instead, 13 manually paraphrased advice
samples were written from public preparedness-community themes and linked to
subreddit home pages, not invented thread permalinks. This is a sample, not the
“hundreds of threads” goal in the brief; that goal remains unimplemented.

## Pipeline that would be used with credentials

1. Register a read-only OAuth app with a descriptive user agent.
2. Search selected subreddits (r/preppers, r/EmergencyPreparedness, r/bugout,
   r/Ukraine, r/Lithuania, r/Ultralight, r/beyondthebump, r/AgingParents,
   r/diabetes, r/dogs) for: go bag, bug out bag, evacuation bag, 72 hour kit,
   bag for kids, bag for elderly, packing mistakes, what I wish I had packed.
3. Fetch posts and top comments within the enforced rate limit (commonly around
   100 queries/minute per OAuth client; ready72 would stay well below this and
   cache aggressively).
4. Strip usernames and personal data, deduplicate, and ask DeepSeek to extract
   atomic advice items with category, audience, confidence (upvotes + number of
   independent threads) and permalink.
5. Flag medical, legal or dangerous items for review; never show them.
6. Treat community content as opinion. LT72 always wins on conflict.

## What ships in the app

13 advice items in `lib/data/advice.dart`, paraphrased, each with:
- English and Lithuanian text;
- an audience (`all`, `child`, `toddler`, `senior`, `pet`);
- a confidence label;
- a subreddit source link (the subreddit, not a fabricated thread);
- a `safetyFlag` for medical content.

The Pack screen shows one safe advice line for the selected person and links to
the source. The medical/insulin sample is flagged and excluded from the visible
advice picker.

### Top advice themes (not ranked by a real scrape)

1. Put water, light and a rain layer at the top of the bag.
2. Pack a full change of clothes in a dry bag.
3. Use several small water bottles, not one heavy container.
4. Review the bag twice a year and rotate food.
5. Children need a comfort item and a laminated contact card.
6. Nappies and formula weigh more than expected; plan three days plus spares.
7. Keep a written medication list with the medicine.
8. Insulin needs a cool pack, not a freezer (flagged medical, not shown).
9. Carry a little cash in small notes.
10. Avoid military-looking gear (also stated by LT72).
11. A pet needs its own water, bowl, food, leash and vaccination record.
12. Label every bag with a name.
13. Do not fill a bag with forty identical cans; mix calories and food you
    will actually eat.

## Conflicts with LT72

- None of the visible samples contradict LT72. “Avoid military-looking gear”
  matches LT72’s own warning.
- The insulin/cooling advice is community opinion and is flagged; the app’s
  medical rule remains “bring your own prescribed medicine and talk to a
  pharmacist or doctor”.
- Community suggestions to carry a weapon or unprescribed antibiotics were
  deliberately excluded. They are medical/legal risk, not packing advice.

## Metrics

| Metric | Result |
| --- | --- |
| Live threads collected | 0 (no OAuth credentials) |
| Manually paraphrased advice items | 13 |
| Items flagged medical/legal and hidden | 1 |
| Conflicts with LT72 | 0 |
| Usernames or personal data stored | 0 |
